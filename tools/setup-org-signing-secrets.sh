#!/usr/bin/env bash
# ==============================================================================
# setup-org-signing-secrets.sh
# Unified Release Signing Key Generation & GitHub Org Secrets Provisioning
#
# Target Organizations:
#   - project-dorado (https://github.com/project-dorado)
#   - Heretek-Games  (https://github.com/Heretek-Games)
#   - Heretek-AI     (https://github.com/Heretek-AI)
#
# Generated Credentials:
#   - GPG Signing Key (RSA 4096, 3-year validity)
#   - Android Keystore (PKCS12, RSA 4096, 10,000-day validity)
#
# Organizational Secrets Created:
#   - GPG_PRIVATE_KEY
#   - GPG_PASSPHRASE
#   - GPG_KEY_ID
#   - ANDROID_KEYSTORE_BASE64
#   - ANDROID_KEYSTORE_PASSWORD
#   - ANDROID_KEY_ALIAS
#   - ANDROID_KEY_PASSWORD
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITHUB_REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BACKUP_DIR="${HERETEK_BACKUP_DIR:-${HOME}/.heretek-signing-backup}"

TARGET_ORGS=("project-dorado" "Heretek-Games" "Heretek-AI")

KEY_NAME="${HERETEK_KEY_NAME:-Heretek Release Signing}"
KEY_EMAIL="${HERETEK_KEY_EMAIL:-releases@heretek.net}"
KEY_COMMENT="${HERETEK_KEY_COMMENT:-Heretek & Dorado Unified Release Signing Key}"
KEY_VALIDITY="${HERETEK_KEY_VALIDITY:-3y}"

KEYSTORE_ALIAS="${HERETEK_KEYSTORE_ALIAS:-heretek-release}"
KEYSTORE_VALIDITY="${HERETEK_KEYSTORE_VALIDITY:-10000}"
KEYSTORE_DNAME="${HERETEK_KEYSTORE_DNAME:-CN=Heretek Release Signing, OU=Engineering, O=Heretek, C=US}"

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    local missing=()
    for cmd in gpg keytool openssl base64 gh; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "Missing required utilities: ${missing[*]}"
        log_error "Please install them before continuing."
        exit 1
    fi
    log_success "All prerequisites are installed."
}

init_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        chmod 700 "$BACKUP_DIR"
        log_info "Created secure backup directory: $BACKUP_DIR (permissions 0700)"
    else
        chmod 700 "$BACKUP_DIR"
    fi
}

generate_credentials() {
    init_backup_dir
    local gpg_key_file="${BACKUP_DIR}/heretek-gpg-private.asc"
    local jks_file="${BACKUP_DIR}/heretek-release.jks"
    local env_file="${BACKUP_DIR}/secrets.env"

    if [ -f "$gpg_key_file" ] && [ -f "$jks_file" ] && [ -f "$env_file" ]; then
        log_warn "Credentials already exist in $BACKUP_DIR."
        log_warn "Skipping generation. Using existing credentials."
        return 0
    fi

    log_info "Generating new cryptographic keys..."

    # 1. Passphrases
    local gpg_passphrase="${HERETEK_GPG_PASSPHRASE:-$(openssl rand -base64 24)}"
    local keystore_pass="${HERETEK_KEYSTORE_PASSWORD:-$(openssl rand -base64 24)}"
    local key_pass="$keystore_pass"

    # 2. GPG Key Generation in isolated GNUPGHOME
    log_info "Generating 4096-bit RSA GPG release signing key..."
    local gpg_temp_home
    gpg_temp_home="$(mktemp -d)"
    chmod 700 "$gpg_temp_home"

    cat <<EOF > "$gpg_temp_home/gen-key.conf"
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: ${KEY_NAME}
Name-Email: ${KEY_EMAIL}
Name-Comment: ${KEY_COMMENT}
Expire-Date: ${KEY_VALIDITY}
Passphrase: ${gpg_passphrase}
%commit
EOF

    GNUPGHOME="$gpg_temp_home" gpg --batch --generate-key "$gpg_temp_home/gen-key.conf" >/dev/null 2>&1

    local gpg_key_id
    gpg_key_id="$(GNUPGHOME="$gpg_temp_home" gpg --with-colons --list-secret-keys "$KEY_EMAIL" | awk -F: '$1 == "sec" {print $5; exit}')"
    local gpg_fingerprint
    gpg_fingerprint="$(GNUPGHOME="$gpg_temp_home" gpg --with-colons --fingerprint "$KEY_EMAIL" | awk -F: '$1 == "fpr" {print $10; exit}')"

    log_success "Generated GPG Key: $gpg_key_id (Fingerprint: $gpg_fingerprint)"

    # Export ASCII-armored private and public keys
    GNUPGHOME="$gpg_temp_home" gpg --armor --batch --pinentry-mode loopback --passphrase "$gpg_passphrase" --export-secret-keys "$gpg_key_id" > "$gpg_key_file"
    GNUPGHOME="$gpg_temp_home" gpg --armor --export "$gpg_key_id" > "${BACKUP_DIR}/heretek-gpg-public.asc"
    chmod 600 "$gpg_key_file" "${BACKUP_DIR}/heretek-gpg-public.asc"
    rm -rf "$gpg_temp_home"

    # Also place public key into repo for distribution
    cp "${BACKUP_DIR}/heretek-gpg-public.asc" "${GITHUB_REPO_DIR}/HERETEK_RELEASE_SIGNING_KEY.asc"
    log_success "Published public key to ${GITHUB_REPO_DIR}/HERETEK_RELEASE_SIGNING_KEY.asc"

    # 3. Android Keystore Generation
    log_info "Generating 4096-bit RSA PKCS12 Android release keystore..."
    keytool -genkeypair -v \
        -keystore "$jks_file" \
        -storetype PKCS12 \
        -alias "$KEYSTORE_ALIAS" \
        -keyalg RSA \
        -keysize 4096 \
        -validity "$KEYSTORE_VALIDITY" \
        -storepass "$keystore_pass" \
        -keypass "$key_pass" \
        -dname "$KEYSTORE_DNAME" >/dev/null 2>&1

    chmod 600 "$jks_file"
    local keystore_base64
    keystore_base64="$(base64 -w 0 "$jks_file")"
    echo "$keystore_base64" > "${BACKUP_DIR}/android-keystore.base64"
    chmod 600 "${BACKUP_DIR}/android-keystore.base64"
    log_success "Generated Android Keystore: $jks_file (Alias: $KEYSTORE_ALIAS)"

    # 4. Write secrets dotenv file for backup and gh secret import
    cat <<EOF > "$env_file"
GPG_KEY_ID=${gpg_key_id}
GPG_FINGERPRINT=${gpg_fingerprint}
GPG_PASSPHRASE=${gpg_passphrase}
ANDROID_KEYSTORE_PASSWORD=${keystore_pass}
ANDROID_KEY_ALIAS=${KEYSTORE_ALIAS}
ANDROID_KEY_PASSWORD=${key_pass}
EOF
    chmod 600 "$env_file"

    log_success "All credentials generated and safely stored in $BACKUP_DIR"
}

check_gh_org_permissions() {
    log_info "Verifying GitHub CLI authentication and organization access..."
    if ! gh auth status >/dev/null 2>&1; then
        log_error "GitHub CLI is not authenticated. Please run 'gh auth login'."
        return 1
    fi

    # Test access to org secrets API on project-dorado
    local test_res
    if ! test_res="$(gh secret list --org project-dorado 2>&1)"; then
        if echo "$test_res" | grep -q "403"; then
            log_warn "GitHub token does not currently have 'admin:org' permission to manage org secrets."
            echo ""
            echo -e "${YELLOW}Please run the following command in your terminal to grant org secret permissions:${NC}"
            echo -e "  ${BOLD}gh auth refresh -s admin:org${NC}"
            echo ""
            return 2
        fi
        log_error "Error checking organization secrets: $test_res"
        return 1
    fi

    log_success "GitHub CLI has required 'admin:org' permissions."
    return 0
}

deploy_org_secrets() {
    local gpg_key_file="${BACKUP_DIR}/heretek-gpg-private.asc"
    local jks_file="${BACKUP_DIR}/heretek-release.jks"
    local env_file="${BACKUP_DIR}/secrets.env"

    if [ ! -f "$gpg_key_file" ] || [ ! -f "$jks_file" ] || [ ! -f "$env_file" ]; then
        log_error "Missing credentials in $BACKUP_DIR. Run '$0 generate' first."
        exit 1
    fi

    # Source parameters
    # shellcheck disable=SC1090
    source "$env_file"
    local gpg_private_key
    gpg_private_key="$(cat "$gpg_key_file")"
    local keystore_base64
    keystore_base64="$(cat "${BACKUP_DIR}/android-keystore.base64")"

    log_info "Deploying secrets across organizations: ${TARGET_ORGS[*]}"

    for org in "${TARGET_ORGS[@]}"; do
        echo ""
        log_info "=== Setting secrets for organization: $org ==="

        # GPG Secrets
        echo -n "$gpg_private_key" | gh secret set GPG_PRIVATE_KEY --org "$org" --visibility all
        gh secret set GPG_PASSPHRASE --org "$org" --visibility all --body "$GPG_PASSPHRASE"
        gh secret set GPG_KEY_ID --org "$org" --visibility all --body "$GPG_KEY_ID"

        # Android Keystore Secrets
        gh secret set ANDROID_KEYSTORE_BASE64 --org "$org" --visibility all --body "$keystore_base64"
        gh secret set ANDROID_KEYSTORE_PASSWORD --org "$org" --visibility all --body "$ANDROID_KEYSTORE_PASSWORD"
        gh secret set ANDROID_KEY_ALIAS --org "$org" --visibility all --body "$ANDROID_KEY_ALIAS"
        gh secret set ANDROID_KEY_PASSWORD --org "$org" --visibility all --body "$ANDROID_KEY_PASSWORD"

        log_success "Successfully configured 7 release secrets for organization: $org"
        gh secret list --org "$org"
    done
}

show_status() {
    echo ""
    echo -e "${BOLD}Heretek & Dorado Release Signing Status${NC}"
    echo "--------------------------------------------------"
    if [ -d "$BACKUP_DIR" ] && [ -f "${BACKUP_DIR}/secrets.env" ]; then
        # shellcheck disable=SC1090
        source "${BACKUP_DIR}/secrets.env"
        echo -e "Backup Directory:     ${GREEN}${BACKUP_DIR}${NC} (chmod 0700)"
        echo -e "GPG Key ID:           ${BOLD}${GPG_KEY_ID}${NC}"
        echo -e "GPG Fingerprint:      ${BOLD}${GPG_FINGERPRINT}${NC}"
        echo -e "Android Key Alias:    ${BOLD}${ANDROID_KEY_ALIAS}${NC}"
        echo -e "Public Key Artifact:  ${GREEN}${GITHUB_REPO_DIR}/HERETEK_RELEASE_SIGNING_KEY.asc${NC}"
    else
        echo -e "Status:               ${YELLOW}No credentials generated yet.${NC}"
        echo "Run '$0 generate' to create them."
    fi
    echo ""
}

print_manual_instructions() {
    local env_file="${BACKUP_DIR}/secrets.env"
    if [ ! -f "$env_file" ]; then
        return
    fi
    # shellcheck disable=SC1090
    source "$env_file"
    echo ""
    echo -e "${BOLD}Manual GitHub Settings Web UI Links:${NC}"
    for org in "${TARGET_ORGS[@]}"; do
        echo "  - https://github.com/organizations/${org}/settings/secrets/actions"
    done
    echo ""
    echo -e "Required Secrets to enter if not using CLI:"
    echo "  1. GPG_PRIVATE_KEY         -> File content of ${BACKUP_DIR}/heretek-gpg-private.asc"
    echo "  2. GPG_PASSPHRASE          -> From ${BACKUP_DIR}/secrets.env"
    echo "  3. GPG_KEY_ID              -> ${GPG_KEY_ID}"
    echo "  4. ANDROID_KEYSTORE_BASE64 -> File content of ${BACKUP_DIR}/android-keystore.base64"
    echo "  5. ANDROID_KEYSTORE_PASSWORD -> From ${BACKUP_DIR}/secrets.env"
    echo "  6. ANDROID_KEY_ALIAS       -> ${ANDROID_KEY_ALIAS}"
    echo "  7. ANDROID_KEY_PASSWORD    -> From ${BACKUP_DIR}/secrets.env"
    echo ""
}

# Main Command Dispatch
cmd="${1:-all}"

case "$cmd" in
    generate)
        check_prerequisites
        generate_credentials
        show_status
        ;;
    deploy)
        check_prerequisites
        if check_gh_org_permissions; then
            deploy_org_secrets
        else
            print_manual_instructions
        fi
        ;;
    status)
        show_status
        ;;
    all)
        check_prerequisites
        generate_credentials
        show_status
        if check_gh_org_permissions; then
            deploy_org_secrets
        else
            print_manual_instructions
        fi
        ;;
    *)
        echo "Usage: $0 [generate|deploy|status|all]"
        exit 1
        ;;
esac

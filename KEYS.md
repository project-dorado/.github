# Release Signing & Cryptographic Verification

This document describes how to verify official releases, binaries, and packages published by:
- [project-dorado](https://github.com/project-dorado)
- [Heretek-Games](https://github.com/Heretek-Games)
- [Heretek-AI](https://github.com/Heretek-AI)

All official release artifacts are signed using **Heretek Release Signing** GPG key and authenticated with **GitHub Artifact Attestations (Sigstore SLSA Provenance)**.

---

## 1. GPG Public Key

The ASCII-armored public key is available at:
- Repository file: [`HERETEK_RELEASE_SIGNING_KEY.asc`](./HERETEK_RELEASE_SIGNING_KEY.asc)
- Direct URL: `https://raw.githubusercontent.com/project-dorado/.github/main/HERETEK_RELEASE_SIGNING_KEY.asc`

### Key Details
- **User ID**: `Heretek Release Signing (Heretek & Dorado Unified Release Signing Key) <releases@heretek.net>`
- **Key ID**: `BCBC85E3B15DC872`
- **Algorithm**: `RSA 4096-bit`
- **Fingerprint**:
  ```text
  11EE 4B06 9B95 02EB E5EF  6531 BCBC 85E3 B15D C872
  ```

### Importing the Public Key

```bash
# Direct import from GitHub:
curl -sSL https://raw.githubusercontent.com/project-dorado/.github/main/HERETEK_RELEASE_SIGNING_KEY.asc | gpg --import

# Or via keyserver (once synchronized):
gpg --keyserver keys.openpgp.org --recv-keys 11EE4B069B9502EBE5EF6531BCBC85E3B15DC872
```

---

## 2. Verifying Release Assets with GPG

Every release publishes a `SHA256SUMS` file and an ASCII-armored detached signature `SHA256SUMS.asc`.

### Step-by-Step Verification

```bash
# 1. Download the release asset(s), SHA256SUMS, and SHA256SUMS.asc
curl -LO https://github.com/project-dorado/dorado/releases/download/<tag>/Dorado-Linux-x64.tar.gz
curl -LO https://github.com/project-dorado/dorado/releases/download/<tag>/SHA256SUMS
curl -LO https://github.com/project-dorado/dorado/releases/download/<tag>/SHA256SUMS.asc

# 2. Verify the GPG detached signature on the checksum file
gpg --verify SHA256SUMS.asc SHA256SUMS

# Expected output includes:
# gpg: Good signature from "Heretek Release Signing ... <releases@heretek.net>"
# Primary key fingerprint: 11EE 4B06 9B95 02EB E5EF  6531 BCBC 85E3 B15D C872

# 3. Verify the checksum of the downloaded file
sha256sum --check --ignore-missing SHA256SUMS
```

---

## 3. Verifying with GitHub Artifact Attestations (Sigstore)

Releases are also signed with GitHub's native Sigstore infrastructure using OpenID Connect (OIDC). This provides cryptographically verifiable build provenance linking the artifact directly to the exact workflow run, repository, and git commit.

### Verification using GitHub CLI (`gh`):

```bash
# Verify binary against project-dorado repository
gh attestation verify Dorado-Linux-x64.tar.gz --owner project-dorado

# Or verify against Heretek-Games or Heretek-AI
gh attestation verify <game-package.zip> --owner Heretek-Games
gh attestation verify <package.tar.gz> --owner Heretek-AI
```

---

## 4. Verifying Android APK Signatures

Android application packages (`.apk`) are signed with the official Heretek release keystore (APK Signature Scheme v1, v2, v3, and v4).

To verify on any machine with the Android SDK installed:

```bash
apksigner verify --verbose --print-certs dorado-hd-<sha>.apk
```

Expected signer:
- **Owner**: `CN=Heretek Release Signing, OU=Engineering, O=Heretek, C=US`
- **Key Algorithm**: `4096-bit RSA`

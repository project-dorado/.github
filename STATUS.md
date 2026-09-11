# Dorado — Program Status

**Last updated:** 2026-09-10

A consolidated view of what has been completed and what remains across the
organization. Legend: ✅ done · 🚧 in progress · ⏳ pending

All figures below were **re-verified against `origin/main` and executed test
suites on 2026-09-10** (commands in [Verification](#verification)). Every
repository has a clean working tree and is **0 ahead / 0 behind** its remote.

## Repositories

| Repository | Purpose | State |
|---|---|---|
| [dorado](https://github.com/project-dorado/dorado) | Zune 4.8 desktop re-creation (.NET 8 / Avalonia) | ✅ pushed · 382/382 tests · ~88% weighted parity |
| [dorado-hd](https://github.com/project-dorado/dorado-hd) | Zune HD Android client (Kotlin / Compose) | ✅ pushed · 148/148 tests (JDK 21) · M9 done |
| [dorado-cloud](https://github.com/project-dorado/dorado-cloud) | Community cloud services (.NET 8) | ✅ pushed · M0–M5 done · 61/61 tests · M6 legal-gated |
| [dorado-emu](https://github.com/project-dorado/dorado-emu) | Zune HD `.zcp`/`.ccgame` XNA emulator core | ✅ pushed · M0–M1 done · 27/27 tests |
| [project-dorado.github.io](https://github.com/project-dorado/project-dorado.github.io) | Organization website (dorado.org.uk) | ✅ published |
| [.github](https://github.com/project-dorado/.github) | Org profile + community health files | ✅ published |

## Completed

### Repository migration & rebrand
- `Heretek-AI/not-zune` → **project-dorado/dorado** and
  `Heretek-AI/xune-HD` → **project-dorado/dorado-hd**; histories preserved,
  MIT licensing retained, original author copyrights preserved.
- Remaining `Heretek` references are **provenance/attribution only**
  (`Directory.Build.props` authors, `LICENSE`, `NOTICE.md`,
  `AppInfo.CopyrightLine`, a `SyncProtocol` doc cross-reference, PR template).
  The HD application id is intentionally kept as `com.heretek.dorado_hd`.
- No submodules in any repository.

### P0 — IP remediation ✅ complete
- Decompiled Microsoft Zune desktop corpus removed from `dorado` (3,953
  files) and kept **external** at `../zune-disassembly/` (reference only).
- Zune HD firmware/asset corpus kept **external** at
  `../zune-hd-disassembly/` (never committed).
- Bundled UI assets remediated: the only fonts in `dorado` are **OFL
  Selawik** (no SegoeZ/Zegoe in source), and the bundled Zune assets were
  recreated/renamed (`DORADO-BACKGROUND-*`, `DORADO-CHIME-*`).
- `NOTICE.md` states the clean-room posture: no Microsoft fonts, artwork,
  firmware, or code are redistributed.

### Dorado Cloud (M0–M5)
- 8 modules mounted at `/v1/{module}`: `identity`, `catalog`, `artwork`,
  `directory`, `recs`, `social`, `updates`, `media` (stub, legal-gated).
- OpenIddict OIDC, device registry + versioned settings sync, RS256-signed
  update feed, MusicBrainz catalog + artwork CDN, podcast/radio directory,
  social graph/Zune Card/badges/moderation, heuristic QuickMix.
- CI green; images published to `ghcr.io/project-dorado/dorado-cloud-{api,gateway}`.
- See [`dorado-cloud/ROADMAP.md`](https://github.com/project-dorado/dorado-cloud/blob/main/ROADMAP.md).

### Client ↔ Cloud integration ✅ (Phase 1)
- **SDK auth (centralized):** `DoradoCloud.Client` now ships
  `ICloudCredentialStore` + `DoradoCloudAuthHandler`, which attaches the bearer
  token, proactively refreshes it via the OIDC `refresh_token` grant, and
  replays once after a 401. Wired through `AddDoradoCloudAuth(...)`.
- **dorado:** refresh token is persisted on PKCE sign-in (`CloudRefreshToken`);
  a settings-backed credential store feeds the handler; `CloudClientProvider`
  rebuilds the client when the base URL changes (fixing the stale singleton);
  the fabricated `dorado-cloud.example` artwork URL is gone; `CloudPreferCloud`
  is honored (inner-first when false); an opt-in, signature-verified update
  check now runs at startup and surfaces through the in-shell dialog.
- **dorado-hd:** `CloudUpdateService` + a Settings "check for updates" row
  (verifies the RS256 manifest before reporting).
- **Live smoke test:** local API boot on a fresh SQLite DB returned
  `catalog/ping` ok, the signing key PEM, a client-credentials token, a
  principal on `/v1/identity/me`, and a well-formed `updates/dorado-hd/stable`.

## In progress / pending

| Item | Owner area | Notes |
|---|---|---|
| **Client ↔ Cloud E2E (interactive)** | dorado / dorado-hd | The server half is smoke-tested; the browser PKCE sign-in round-trip still needs a desktop/mobile session to exercise end to end. |
| **HD M9.2b — play counts** | dorado-hd | `playCounts` is injected but has no producer/persistence, so *Top Played* degrades to title order. Add a `play_counts` table + recording at the scrobble transition + a UI entry. |
| **HD M10 — always-on surfaces** | dorado-hd | No widget/Glance infrastructure yet; add a zero-corner-radius Now Playing widget + richer lock screen. |
| **HD M8.2b — live sync** | dorado-hd / dorado | The desktop endpoint now exists (`SyncEndpointHost`/`SyncTcpServer`); the HD LAN mDNS + TLS client is the remaining side. |
| **M6 — Media (PD/CC only)** | dorado-cloud | Legal-gated; endpoint is a `501` stub. Requires legal sign-off. |
| **Cloud hardening** | dorado-cloud | EF Core migrations (`EnsureCreated` only today — a stale dev DB missing domain tables produced a live `no such table: UpdateReleases`), identity hardening (rate-limit, CSRF, consent, verification/reset, GDPR), pgvector QuickMix, fail-closed admin policy, tighten CORS, remove dev secret. |
| **Desktop fidelity leftovers** | dorado | Mixview external related-artist satellites, MusicBrainz + AcoustID scan-time metadata/acoustic dedup, real DSP analysis, MPRIS/SMTC + media keys, remaining i18n locales. |
| **RE corpus export** | dorado-hd | The Ghidra project is imported but never exported — `zune-hd-disassembly/ghidra/decompiled/` is empty. |
| **Manual GitHub steps** | org | Confirm the org avatar and pin repositories (profile name, description, and website are already set). |

## Verification

Executed 2026-09-10:

```bash
# git — every repo: clean tree, 0 ahead / 0 behind after fetch
for d in dorado dorado-cloud dorado-emu dorado-hd .github project-dorado.github.io; do
  git -C "$d" fetch -q origin && git -C "$d" rev-list --left-right --count origin/HEAD...HEAD
done

# .NET suites
dotnet test                          # dorado     → 382 passed (14 Domain + 368 Application)
dotnet test DoradoCloud.sln          # cloud      → 61 passed  (44 integration + 17 client)
dotnet test Dorado.sln               # dorado-emu → 27 passed

# Android suite (JDK 21 required; JDK 26 breaks Robolectric)
JAVA_HOME=/home/linuxbrew/.linuxbrew/opt/openjdk@21/libexec ./gradlew testDebugUnitTest   # → 148 passed
```

> **Toolchain note:** `dorado-hd` unit tests require **JDK 21**. Running
> Robolectric on JDK 26 fails with "Some resetters failed"; this is an
> environment issue, not a code regression.

## Security & legal posture

- No Microsoft code, binaries, fonts, firmware, or artwork are redistributed.
- No DRM circumvention and no license-server emulation.
- No copyrighted media hosted; streaming is restricted to public-domain / CC content.
- Zune, Zegoe, Zune HD and Microsoft are trademarks of Microsoft Corporation.
  Dorado is an independent, non-affiliated homage.

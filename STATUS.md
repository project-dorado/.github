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
| [dorado](https://github.com/project-dorado/dorado) | Zune 4.8 desktop re-creation (.NET 8 / Avalonia) | ✅ pushed · 375/375 tests · ~88% weighted parity |
| [dorado-hd](https://github.com/project-dorado/dorado-hd) | Zune HD Android client (Kotlin / Compose) | ✅ pushed · 143/143 tests (JDK 21) · M9 done |
| [dorado-cloud](https://github.com/project-dorado/dorado-cloud) | Community cloud services (.NET 8) | ✅ pushed · M0–M5 done · 55/55 tests · M6 legal-gated |
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

### Client ↔ Cloud integration (partially landed)
Both clients already ship cloud layers (this is **not** greenfield):
- **dorado:** `CloudBackedMetadataService`, `CloudUpdateService`,
  `CloudSignInService` (OAuth PKCE), `CloudSocialService`,
  `CloudDirectoryService`, plus `AppSettings.Cloud*`.
- **dorado-hd:** `cloud/` (`CloudContracts`, `CloudHttp`,
  `CloudMetadataSource`, `CloudSignIn`, `CloudMixSource`) with tests.

## In progress / pending

| Item | Owner area | Notes |
|---|---|---|
| **Client ↔ Cloud completion** | dorado / dorado-hd | Finish remaining surfaces; fix the desktop `DoradoCloudClient` DI singleton (built once, does not rebuild on sign-in/base-URL change), remove the `dorado-cloud.example` placeholder, honor `CloudPreferCloud`, trigger `ICloudUpdateService` checks (currently tests-only), add an update UI; end-to-end against `docker compose`. |
| **HD M9.2b — play counts** | dorado-hd | `playCounts` is injected but has no producer/persistence, so *Top Played* degrades to title order. Add a `play_counts` table + recording at the scrobble transition + a UI entry. |
| **HD M10 — always-on surfaces** | dorado-hd | No widget/Glance infrastructure yet; add a zero-corner-radius Now Playing widget + richer lock screen. |
| **HD M8.2b — live sync** | dorado-hd / dorado | LAN mDNS + TLS pairing transport; blocked on a desktop-side sync endpoint. |
| **M6 — Media (PD/CC only)** | dorado-cloud | Legal-gated; endpoint is a `501` stub. Requires legal sign-off. |
| **Cloud hardening** | dorado-cloud | EF Core migrations (`EnsureCreated` only today), identity hardening (rate-limit, CSRF, consent, verification/reset, GDPR), pgvector QuickMix, fail-closed admin policy, tighten CORS, remove dev secret. |
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
dotnet test                          # dorado     → 375 passed (14 Domain + 361 Application)
dotnet test DoradoCloud.sln          # cloud      → 55 passed  (44 integration + 11 client)
dotnet test Dorado.sln               # dorado-emu → 27 passed

# Android suite (JDK 21 required; JDK 26 breaks Robolectric)
JAVA_HOME=/home/linuxbrew/.linuxbrew/opt/openjdk@21/libexec ./gradlew testDebugUnitTest   # → 143 passed
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

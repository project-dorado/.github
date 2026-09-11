# Dorado — Program Status

**Last updated:** 2026-09-10

A consolidated view of what has been completed and what remains across the
organization. Legend: ✅ done · 🚧 in progress · ⏳ pending

> **Single source of truth.** This file is the canonical program status for the
> organization; repository READMEs and the website link here. Figures are as of
> the date above.

All figures below were **re-verified against `origin/main` and executed test
suites on 2026-09-10** (commands in [Verification](#verification)). Every
repository has a clean working tree and is **0 ahead / 0 behind** its remote.

## Repositories

| Repository | Purpose | State |
|---|---|---|
| [dorado](https://github.com/project-dorado/dorado) | Zune 4.8 desktop re-creation (.NET 8 / Avalonia) | ✅ pushed · 393/393 tests · ~88% weighted parity |
| [dorado-hd](https://github.com/project-dorado/dorado-hd) | Zune HD Android client (Kotlin / Compose) | ✅ pushed · 157/157 tests (JDK 21) · M4, M7–M9 done; M10 widget shipped |
| [dorado-cloud](https://github.com/project-dorado/dorado-cloud) | Community cloud services (.NET 8) | ✅ pushed · M0–M5 done · 63/63 tests · M6 legal-gated |
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

### HD Device Link (M8.2b) ✅
- **Desktop:** hosts the LAN JSON-RPC socket (`SyncTcpServer`) and advertises
  `_dorado-sync._tcp` over mDNS (Makaretu); Settings exposes the enable toggle,
  port, and pairing code (generate/regenerate).
- **HD:** discovers desktops via `NsdManager` (`NsdLanSyncDiscovery`), pairs with
  a plain-TCP `sync.hello`/`sync.pair` session (`LanSync`/`TcpSyncConnector`),
  and offers a manual "connect by address" fallback. TLS remains a hardening
  item — the desktop endpoint is plain TCP today.

### Dorado-HD modern listening + always-on (M9/M10) ✅
- **M9 — Modern Listening:** on-device DSP audio features, Dynamic Mix, **Top
  Played** from persisted per-track play counts (Room DB v5), Last.fm scrobbling
  with a durable offline queue, and LRCLIB lyrics.
- **M10 — Always-on:** a Glance **Now Playing widget** with transport driven by
  the shared Media3 session. Richer lock-screen art/controls and a sleep timer
  remain.
- **Still pending:** M5 (share/Zune-Card export, podcast search), M6 (EQ presets,
  crossfade, live-radio cache, richer lock screen).

## In progress / pending

| Item | Owner area | Notes |
|---|---|---|
| **Client ↔ Cloud E2E (interactive)** | dorado / dorado-hd | The server half is smoke-tested; the browser PKCE sign-in round-trip still needs a desktop/mobile session to exercise end to end. |
| **HD M10 — always-on surfaces** | dorado-hd | Glance Now Playing widget done; richer lock-screen art/controls and a sleep timer pending. |
| **M6 — Media (PD/CC only)** | dorado-cloud | Legal-gated; endpoint is a `501` stub. Requires legal sign-off. |
| **Cloud hardening** | dorado-cloud | ✅ EF Core Postgres migrations (verified against a real Postgres), auth rate limiting, fail-closed admin, tightened CORS, dev-only smoke client, GDPR export + erasure (revokes tokens). ⏳ Remaining: consent screen, CSRF/antiforgery on HTML forms, email verification/password reset, pgvector QuickMix. |
| **Desktop fidelity leftovers** | dorado | ✅ Mixview external related-artist satellites; ✅ real DSP audio analysis (PCM/STFT); ✅ AcoustID scan-time metadata + acoustic dedup. ⏳ Remaining: MPRIS/SMTC + media keys, remaining i18n locales. |
| **RE corpus** | dorado-hd | ✅ Full corpus built: **109/109** modules, **66,598** functions decompiled, **4,169** exports applied, **22,479** strings indexed (`ghidra_corpus.py`). Synthesized docs: `zune-hd-module-inventory.md`, `zune-hd-api-reference.md`, `zune-hd-assets.md`. ⏳ Mine for canon/behavior gaps. |
| **HD on-device parity audit** | dorado-hd | ✅ `docs/zune-hd-parity-audit.md` + `docs/zune-hd-parity-gaps.json` (16 gaps + N-A list); resolved the kinetic `0.95` provenance (integrator is dt-scaled at 62.5 Hz, reads `[0x08]/[0x0C]`). ⏳ Follow-ups in `parity-roadmap.md`. |
| **Manual GitHub steps** | org | Confirm the org avatar and pin repositories (profile name, description, and website are already set). |

## Verification

Executed 2026-09-10:

```bash
# git — every repo: clean tree, 0 ahead / 0 behind after fetch
for d in dorado dorado-cloud dorado-emu dorado-hd .github project-dorado.github.io; do
  git -C "$d" fetch -q origin && git -C "$d" rev-list --left-right --count origin/HEAD...HEAD
done

# .NET suites
dotnet test                          # dorado     → 393 passed (14 Domain + 379 Application)
dotnet test DoradoCloud.sln          # cloud      → 63 passed  (46 integration + 17 client)
dotnet test Dorado.sln               # dorado-emu → 27 passed

# Android suite (JDK 21 required; JDK 26 breaks Robolectric)
JAVA_HOME=/home/linuxbrew/.linuxbrew/opt/openjdk@21/libexec ./gradlew testDebugUnitTest   # → 157 passed
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

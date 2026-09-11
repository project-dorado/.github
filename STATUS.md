# Dorado — Program Status

**Last updated:** 2026-09-11

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
| [dorado-hd](https://github.com/project-dorado/dorado-hd) | Zune HD Android client (Kotlin / Compose) | ✅ pushed · **1,410/1,410 tests** (JDK 21) · **M16: all 62 official apps implemented** + engine3d core · **UI-parity program complete** (audit + gap register, 63-app smoke/layout/back/golden suites, emulator crawl 63/63) · M4, M7–M9, M12–M14 done; M15 partial; M10 widget · UI/UX deep audit done ([audit](https://github.com/project-dorado/dorado-hd/blob/main/docs/ui-ux-audit.md)) |
| [dorado-cloud](https://github.com/project-dorado/dorado-cloud) | Community cloud services (.NET 8) | ✅ pushed · M0–M5 + M7 done · 123/123 tests · M6 legal-gated |
| [dorado-emu](https://github.com/project-dorado/dorado-emu) | Zune HD `.zcp`/`.ccgame` XNA emulator core | ✅ pushed · M0–M1 + ZCSTFS volume reader + extracted-app directories · 43/43 tests · DRM key seam (no keys shipped) |
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

### Dorado Cloud (M0–M5, M7)
- 8 modules mounted at `/v1/{module}`: `identity`, `catalog`, `artwork`,
  `directory`, `recs`, `social`, `updates`, `media` (stub, legal-gated).
- OpenIddict OIDC, device registry + versioned settings sync, RS256-signed
  update feed, MusicBrainz catalog + artwork CDN, podcast/radio directory,
  social graph/Zune Card/badges/moderation, heuristic QuickMix.
- CI green; images published to `ghcr.io/project-dorado/dorado-cloud-{api,gateway}`.
- See [`dorado-cloud/ROADMAP.md`](https://github.com/project-dorado/dorado-cloud/blob/main/ROADMAP.md).

### Legacy Zune compatibility (M7) ✅
- **Host-routed `*.zune.net` Atom/XML services** for hosts-patched Zune 4.8
  desktop and Zune HD clients, dispatched by the request `Host`
  (`LegacyModuleBase` + `RequireHost`); the modern `/v1` JSON API is unchanged.
- Hosts: `catalog.zune.net`, `image.catalog.zune.net`, `resources.zune.net`
  (firmware manifest + baseline CABs with range streaming), `mix.zune.net`,
  `socialapi.zune.net`, `inbox.zune.net` (new `InboxMessage` store + Postgres
  migration), `tiles.zune.net`, `tuners.zune.net`,
  `fai.music.metaservices.microsoft.com`, and a **gated** `login.zune.net`
  WS-Trust bridge.
- `DoradoCloud.Legacy` library (Atom writer + legacy id mapping); catalog and
  image hosts reuse MusicBrainz/Cover Art Archive; mix/social reuse QuickMix and
  the social graph.
- **Legal floor:** firmware CABs, `.zcp` app packages and PC-client resources
  stream only from external, untracked corpora and fail closed (`404`) when
  unset; `commerce.zune.net` purchase and Zune-Pass DRM/license endpoints are
  **not** implemented (no DRM circumvention); login is disabled by default.
- 123/123 tests; Release build 0 warnings (`/warnaserror`).

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

### Dorado-HD official-app reimplementation (M16) ✅
- **All 62 official Zune HD marketplace packages** now have launchable native
  implementations (was 21): W1 utilities/music fidelity, W2 card/board + AI,
  W3/W4 23 casual/puzzle/word titles, W5 touch/toy/physics, W6 six big
  engines (racing, skating, marble, bowling, AudioFeatures surf, arena),
  W7 pixel-faithful offline UIs for the dead services.
- Documentation-first: a behavioral spec per package with
  `Assembly!Type.Method` citations (`dorado-hd/docs/apps/`), a 62-row register
  + generated audit (`docs/official-apps-{json,audit.md,gaps.json}`), and a
  register⇔catalog⇔registry⇔spec test gate.
- Dependency-free OpenGL ES 3.0 core (`ui/apps/engine3d/`) with pure-JVM math
  and picking tests; all artwork/levels/word lists/audio re-authored in code.
- Corpus (external, untracked): whole Zune Archive mirrored (70 items,
  51.4 GB, per-file MD5); decompiled app tree verifies **7,843/7,844** files
  (one upstream gap); `color-spill` remains corpus-blocked (GUID collision
  with Reversi) with provisional genre constants.
- Gates: `assembleDebug` + `testDebugUnitTest` (1,410) + `lintDebug` green;
  `DesignInvariantTest` 0 violations.

### Dorado-HD modern listening + always-on (M9/M10) ✅
- **M9 — Modern Listening:** on-device DSP audio features, Dynamic Mix, **Top
  Played** from persisted per-track play counts (Room DB v5), Last.fm scrobbling
  with a durable offline queue, and LRCLIB lyrics.
- **M10 — Always-on:** a Glance **Now Playing widget** with transport driven by
  the shared Media3 session. Richer lock-screen art/controls and a sleep timer
  remain.
- **Still pending:** M5 (share/Zune-Card export, podcast search), M6 (EQ presets,
  crossfade, live-radio cache, richer lock screen).

## Builds & releases

Builds run automatically on GitHub Actions. The two user-facing builds publish a
per-commit **prerelease tagged with the short commit hash** (first 7 chars of
`github.sha`), so every `main` commit has a stable download URL.

| Component | Workflow | Auto release | Assets |
|---|---|---|---|
| **dorado** (desktop) | `dorado/.github/workflows/build.yml` | `dorado-<sha7>` prerelease on every `main` push | `Dorado-Linux-x64.tar.gz`, `Dorado-Linux-arm64.tar.gz`, `Dorado-Windows-x64.zip`, `Dorado-Windows-arm64.zip` |
| **dorado-hd** (Android) | `dorado-hd/.github/workflows/ci.yml` | `dorado-hd-<sha7>` prerelease on every `main` push | `dorado-hd-<sha7>.apk` (debug, sideloadable) |

- **Versioned desktop releases:** push a `dorado-v*` tag to publish a normal,
  non-prerelease `dorado` release with the same assets.
- **Retention:** only the newest **10** per-commit prereleases per component are
  kept; older ones have their tags removed automatically. Versioned `dorado-v*`
  releases are never pruned.
- **Android build type:** the published APK is the **debug** build (unsigned but
  installable); release signing is not yet configured.
- `dorado-cloud` continues to publish GHCR images tagged by `sha` (plus branch /
  semver) via `docker/metadata-action`; `dorado-emu` produces no distributable.

## In progress / pending

| Item | Owner area | Notes |
|---|---|---|
| **Client ↔ Cloud E2E (interactive)** | dorado / dorado-hd | The server half is smoke-tested; the browser PKCE sign-in round-trip still needs a desktop/mobile session to exercise end to end. |
| **HD M10 — always-on surfaces** | dorado-hd | Glance Now Playing widget done; richer lock-screen art/controls and a sleep timer pending. |
| **M6 — Media (PD/CC only)** | dorado-cloud | Legal-gated; endpoint is a `501` stub. Requires legal sign-off. |
| **Legacy Zune compat (M7) follow-ups** | dorado-cloud | ✅ Phases 0–4 shipped (host-routed `*.zune.net` Atom/XML). ⏳ Interactive E2E on real hosts-patched Zune 4.8 / HD; legacy login token trust model (bridge still gated); keyless artist imagery for `image.catalog.zune.net`. |
| **Cloud hardening** | dorado-cloud | ✅ EF Core Postgres migrations (verified against a real Postgres), auth rate limiting, fail-closed admin, tightened CORS, dev-only smoke client, GDPR export + erasure (revokes tokens). ⏳ Remaining: consent screen, CSRF/antiforgery on HTML forms, email verification/password reset, pgvector QuickMix. |
| **Desktop fidelity leftovers** | dorado | ✅ Mixview external related-artist satellites; ✅ real DSP audio analysis (PCM/STFT); ✅ AcoustID scan-time metadata + acoustic dedup. ⏳ Remaining: MPRIS/SMTC + media keys, remaining i18n locales. |
| **RE corpus** | dorado-hd | ✅ Full corpus built: **114/114** modules (incl. kernel-only `zcstfs.dll`, `keyvault.dll`, `DwXfer.dll`, `zcblock.dll`, `zpartstream.dll`), **67,399** functions decompiled, **4,236** exports applied, **22,610** strings indexed (`ghidra_corpus.py`). Synthesized docs: `zune-hd-module-inventory.md`, `zune-hd-api-reference.md`, `zune-hd-assets.md`. ⏳ Mine for canon/behavior gaps. |
| **HD on-device parity audit** | dorado-hd | ✅ `docs/zune-hd-parity-audit.md` + `docs/zune-hd-parity-gaps.json`. ✅ **M12–M14** shipped: NP scrubber, queue/showlist, library search, fling cap+snap, kinetic provenance, dimmer + battery/clock status OSD, picture pinch-zoom, EQ presets, sort keys; string-parity + font-import declined with rationale. 🟡 **M15** partial: share + marketplace discovery done; inbox/user card + audiobooks remain (long-term). |
| **Official app XNA surface** | dorado-emu | ✅ Decrypted official app trees located (external corpus, now fully mirrored + MD5-verified by dorado-hd tooling) and loaded as directory packages; `32BITREQ` loader fix landed. ⏳ Implement the remaining `Microsoft.Xna.Framework` surface (primitives → `GameComponent` tree → content readers → audio/storage stubs). Gap list: `dorado-emu/docs/official-app-corpus.md`. |
| **Manual GitHub steps** | org | Confirm the org avatar and pin repositories (profile name, description, and website are already set). |

## Verification

Executed 2026-09-11:

```bash
# git — every repo: clean tree, 0 ahead / 0 behind after fetch
for d in dorado dorado-cloud dorado-emu dorado-hd .github project-dorado.github.io; do
  git -C "$d" fetch -q origin && git -C "$d" rev-list --left-right --count origin/HEAD...HEAD
done

# .NET suites
dotnet test                          # dorado     → 393 passed (14 Domain + 379 Application)
dotnet test DoradoCloud.sln          # cloud      → 123 passed (106 integration + 17 client)
dotnet test Dorado.sln               # dorado-emu → 43 passed

# Android suite (JDK 21 required; JDK 26 breaks Robolectric)
JAVA_HOME=/home/linuxbrew/.linuxbrew/opt/openjdk@21/libexec ./gradlew testDebugUnitTest        # → 1,410 passed (unit + UI parity suites)
JAVA_HOME=/home/linuxbrew/.linuxbrew/opt/openjdk@21/libexec ./gradlew assembleDebug lintDebug   # → green

# official-app corpus (external, untracked; never committed)
python3 dorado-hd/tools/zune_archive_mirror.py --dry-run   # 70 items, 51.4 GB
python3 dorado-hd/tools/zune_app_corpus.py --verify-only   # 7,843/7,844 MD5 verified
```

> **Toolchain note:** `dorado-hd` unit tests require **JDK 21**. Running
> Robolectric on JDK 26 fails with "Some resetters failed"; this is an
> environment issue, not a code regression.

## Security & legal posture

- No Microsoft code, binaries, fonts, firmware, or artwork are redistributed.
- No DRM circumvention: the device key-wrapping scheme is documented, and Dorado only applies user-supplied keys for owned content.
- No copyrighted media hosted; streaming is restricted to public-domain / CC content.
- Zune, Zegoe, Zune HD and Microsoft are trademarks of Microsoft Corporation.
  Dorado is an independent, non-affiliated homage.

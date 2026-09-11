# Project Dorado — Phase 1 Cross-Repo Audit & Parity Blocker Matrix

**Date:** 2026-09-10
**Owner:** Principal Systems Architect
**Scope:** Solution, contract, linkage and mock-vs-live audit across all repos under `/home/john/Projects/project-dorado`.
**Outputs:** Itemized blocker list for the immediate parity push. Drives Phases 2–5 of the goal.

> **RESOLVED (2026-09-10, after the integration program).** This audit drove the
> cross-repo integration push; the blockers below are closed. Since it was written:
> the shared SDK exposes the full contract surface with centralized auth
> (`DoradoCloudAuthHandler` / `AddDoradoCloudAuth`); the desktop and Android clients are
> cloud-wired; the desktop LAN sync endpoint + mDNS advertising and the HD
> discovery/pairing client ship; the desktop→emu IPC bridge ships; EF Core Postgres
> migrations and identity hardening (rate limiting, fail-closed admin, CORS allowlist,
> GDPR export/erasure) landed; and real DSP audio analysis, Mixview related-artist
> satellites and AcoustID enrichment shipped. Current canonical status:
> [`STATUS.md`](../STATUS.md).

---

## 1. Solution & Project Inventory

| Repo | Build tool | Project count | Test projects | Test files |
|---|---|---|---|---|
| `dorado` | `dotnet` / `Dorado.sln` | 17 src + 2 test + 1 template | `Dorado.Tests.Application`, `Dorado.Tests.Domain` | 33 + 4 (Domain) |
| `dorado-cloud` | `dotnet` / `DoradoCloud.sln` | 4 src + 1 client SDK + 1 test | `DoradoCloud.Tests` | 12 |
| `dorado-emu` | `dotnet` / `Dorado.sln` | 7 src + 1 test | `Dorado.Tests` | 6 |
| `dorado-hd` | `gradle` (AGP 9, Kotlin 2.4) | 1 app | `:app:testDebugUnitTest` | 11 |
| `zune-disassembly` | none — reference corpus only | — | — | — |
| `Zune HD Apps` | none — 60 `.zcp` packages (reference / test corpus) | — | — | — |
| `project-dorado.github.io` | none — static site | — | — | — |

**No `*.sln` in `dorado-hd`**: it ships a Gradle multi-project, single-module setup. There is no `Dorado.sln` symlink/equiv that ties any of the four code repos together — each compiles in isolation.

---

## 2. Contract Surface (Shared DTOs) — `dorado-cloud/src/DoradoCloud.Shared/Contracts/`

| File | Records | Exposed via `DoradoCloud.Client`? |
|---|---|---|
| `Contracts.cs` | `PingResponse`, `UpdateManifest`, `PagedResponse<T>`, `AccountDto`, `DeviceDto`, `RegisterDeviceRequest`, `SettingsDto`, `PutSettingsRequest`, `UpdateReleaseDto`, `UpdateCheckResponse`, `PublishReleaseRequest` | ⚠ Partial (see §3) |
| `CatalogContracts.cs` | `CatalogSearchItem`, `CatalogSearchResponse`, `CatalogArtistDetail`, `ArtworkAttribution` | ❌ Not exposed |
| `DirectoryContracts.cs` | `PodcastResult`, `PodcastSearchResponse`, `RadioStationResult`, `RadioSearchResponse` | ❌ Not exposed |
| `RecommendationContracts.cs` | `QuickMixCandidate`, `QuickMixResponse` | ❌ Not exposed |
| `SocialContracts.cs` | `ProfileDto`, `UpsertProfileRequest`, `ActivityDto`, `PostActivityRequest`, `BadgeDefinitionDto`, `BadgeDto`, `ZuneCardDto`, `ReportRequest`, `ReportDto`, `ResolveReportRequest` | ❌ Not exposed |
| `UpdateManifestCrypto.cs` | static `Serialize / Sign / Verify` helpers | ❌ Not exposed |
| `DoradoCloudInfo.cs` | shared identity / version constants | n/a |

`DoradoCloud.Shared` is referenced as a **ProjectReference** by `DoradoCloud.Modules` and `DoradoCloud.Client` only — **no consumer (dorado / dorado-hd / dorado-emu) references it yet**.

---

## 3. DTO Mismatches Found in `DoradoCloud.Client`

| Canonical (`Contracts.cs`) | Redefined in client | Incompatibility |
|---|---|---|
| `UpdateCheckResponse(string App, string Channel, bool Available, UpdateReleaseDto? Release, string? Note)` | `UpdateCheckResponse(string App, string Channel, bool Available, UpdateManifest? Manifest, string? Note)` | Two incompatible records. Client cannot deserialize server payload. |
| `PingResponse(string Module, string Status, string Version)` | (consumed directly from `Contracts.cs` — OK) | — |
| (none) | `MeResponse(string? Subject, string? Name, string? Email)` | Client-local; never returned by server. |

**Fix:** delete the client-local redefinitions and import from `DoradoCloud.Shared.Contracts`.

---

## 4. Client SDK Surface — `dorado-cloud/clients/DoradoCloud.Client/`

**Resolved:** the typed client now mirrors the entire `/v1/{module}` surface —
liveness, catalog, artwork, directory, recommendations, updates (with signature
verification), identity (me/devices/settings), and social (profiles/follow/feed/
Zune Card/badges/moderation) — and `AddDoradoCloudAuth` installs a bearer/refresh
`DelegatingHandler`. The DTO redefinitions noted in §3 were removed; the client
consumes `DoradoCloud.Shared.Contracts` directly.

---

## 5. Cross-Repo Linkage Status

| Vector | Wired? | Evidence |
|---|---|---|
| `dorado` → `dorado-cloud` (ProjectReference) | ✅ | `Dorado.Infrastructure.External` references `DoradoCloud.Client`; cloud services + `CloudClientProvider` are registered in `App.axaml.cs` |
| `dorado-hd` → `dorado-cloud` (REST) | ✅ | `dorado-hd/.../cloud/` (`DoradoCloudClient`, metadata source, sign-in, mix, update-check) with tests |
| `dorado` → `dorado-emu` (CLI / IPC) | ✅ | `Dorado.Infrastructure.Emulator` bridges the `dorado --ipc` CLI over JSON-RPC |
| `dorado-hd` → `dorado-emu` (M2 Android embed) | ⏳ | `Dorado.Platform.Android` is designed but not implemented (emulator M2) |
| `dorado-hd` ↔ `dorado` (LAN sync over JSON-RPC 2.0) | ✅ | desktop `SyncEndpointHost`/`SyncTcpServer` + mDNS advertising; HD `LanSync`/`TcpSyncConnector` discovery + pairing handshake |

---

## 6. Mock vs Live Services — `dorado/src/Dorado.Application/Services/`

| Service | File | Live or Mock? | Cloud-backed target |
|---|---|---|---|
| `ArtistEnrichmentCoordinator` | `ArtistEnrichmentCoordinator.cs` | Live (MusicBrainz + Fanart.tv) | Replace with `dorado-cloud` `/v1/catalog/*` + `/v1/artwork/*` |
| `AudioAnalysisService` | `AudioAnalysisService.cs` | Live (BASS + DSP) | n/a |
| `AudioFeatureExtractor` | `AudioFeatureExtractor.cs` | Live | n/a |
| `DefaultVideoServices` | `DefaultVideoServices.cs` | Live | n/a |
| `DialogService` | `DialogService.cs` | Live (in-shell modal) | n/a |
| `DynamicMixService` | `DynamicMixService.cs` | Live | Optional: `/v1/recs/quickmix` |
| `EqualizerPresets` | `EqualizerPresets.cs` | Live | n/a |
| `LocalizationCatalog` / `LocalizationService` | `LocalizationCatalog.cs` / `LocalizationService.cs` | Live | n/a |
| `MixviewCoordinator` | `MixviewCoordinator.cs` | Live | n/a |
| `MtpTransport` | `MtpTransport.cs` | Live (seam; hardware N-A) | n/a |
| `PlaybackQueueCoordinator` | `PlaybackQueueCoordinator.cs` | Live | n/a |
| `PodcastFeedParser` / `PodcastService` | `PodcastFeedParser.cs` / `PodcastService.cs` | Live (RSS) | Replace podcast directory with `/v1/directory/podcasts/search`; keep RSS ingest for individual feeds |
| `ReputationEngine` | `ReputationEngine.cs` | Live (local) | Bridge into `/v1/social/profiles/{handle}` for cross-user badges |
| `SimulatedDeviceTransport` | `SimulatedDeviceTransport.cs` | Live (in-memory) | n/a |
| `SmartDJEngine` | `SmartDJEngine.cs` | Live | Optional: `/v1/recs/quickmix` |
| `SmartPlaylistRules` | `SmartPlaylistRules.cs` | Live | n/a |
| `SyncEngine` | `SyncEngine.cs` | Live | n/a |
| `UserStatsService` | `UserStatsService.cs` | Live | Bridge into `/v1/social/feed` activity posting |
| `VirtualMtpDeviceClient` | `VirtualMtpDeviceClient.cs` | Live | n/a |

**External clients (`Dorado.Infrastructure.External/`):** `MusicBrainzClient`, `CoverArtArchiveClient`, `FanartTvClient`, `LrcLibClient`, `WikipediaClient`, `PodcastFeedClient`, `RateLimitedHttpMessageHandler`, `ArtworkCacheService`, `CommunityArtistImageProvider` — all **live** and currently used by `ExternalMetadataService` and `ArtistEnrichmentCoordinator`.

There are no mock implementations in the desktop repo — the missing cloud integration is a **wire-up gap**, not a stub-replacement task. The cloud becomes the authoritative source for MusicBrainz-backed catalog and the artwork CDN; community sources remain as fallbacks.

---

## 7. Test / Build Gate Status (per STATUS.md & local evidence)

| Repo | Reported status | Verification needed |
|---|---|---|
| `dorado` | ✅ pushed through P0 IP fix; 🚧 11 unpushed local commits + uncommitted WIP | `dotnet build Dorado.sln -c Release /warnaserror` and `dotnet test Dorado.Tests.Application` |
| `dorado-cloud` | ✅ 44/44 tests, 0 warnings, CI green | `dotnet build DoradoCloud.sln -c Release /warnaserror` and `dotnet test DoradoCloud.Tests` |
| `dorado-emu` | ✅ M0/M1 done, 18 tests green | `dotnet build Dorado.sln -c Release /warnaserror` and `dotnet test Dorado.Tests` |
| `dorado-hd` | ✅ Sprint 4 pushed; CI green on pushed `main` | `./gradlew testDebugUnitTest` and `./gradlew assembleDebug` |

---

## 8. Immediate Parity Blockers (Itemized Execution List)

Ordered by dependency; each item is a self-contained, verifiable deliverable. **Bold = highest priority**; each ships a single PR with tests + gate run.

### Vector 1 — Cloud & Client Protocol Harmonization

1. **[BLOCKER, P0] Fix `DoradoCloudClient` DTO mismatch.** Delete the client-local `UpdateCheckResponse` and `MeResponse` redefinitions; consume the canonical `Contracts.UpdateCheckResponse`, `Contracts.AccountDto` and a new `MeResponse(string? Subject, string? Name, string? Email)` DTO in `DoradoCloud.Shared`. Add a regression test that POSTs the same `UpdateManifest` through `UpdateManifestCrypto.Sign` and verifies the server payload deserializes back.
2. **[BLOCKER, P0] Expand `DoradoCloudClient` to expose every Shared contract.** Add typed methods for catalog search + artist detail, artwork front + proxy, podcast + radio search, QuickMix, profile/follow/feed/ZuneCard, device register/list/remove, settings get/put, update publish (admin). Each method round-trips through `DoradoCloud.Tests` integration tests.
3. **[P1] Add a project-local `DoradoCloud.Client.Tests` project** in `dorado-cloud/tests/` with contract-fidelity tests that serialize every record through the wire shape and confirm round-trip equality. Catches property-name drift between server and client.
4. **[P2] Version the `DoradoCloud.Shared` package** (`DoradoCloud.Shared.csproj` → `<Version>` + `GeneratePackageOnBuild`). Add a NuGet feed stub and a CI publish step. Without this, consumers can't pin a version.

### Vector 2 — Device Sync & Cross-Platform Transport

5. **[BLOCKER, P0] Add `Dorado.Infrastructure.Devices` JSON-RPC sync server endpoint.** A new `SyncEndpointHost` class that exposes the existing `SyncEngine.BuildPlan` and `IDeviceTransport` over the same JSON-RPC 2.0 framing as `Dorado.Plugins.Protocol`. Register it under `/sync/v1/{method}` on the desktop app's embedded web host. **Reuse** `JsonRpcChannel` and `JsonRpcMessages` from `Dorado.Plugins.Protocol` — no new wire format.
6. **[BLOCKER, P0] Wire `DoradoCloud` into the desktop's `AppSettings`.** Add a new "Dorado Cloud" settings sub-pivot (or extend existing General) with: enable toggle, base URL (default `https://api.dorado.org.uk`), OAuth browser sign-in (PKCE via OpenIddict authorize + cookie loop), bearer token persisted to `AppSettings.CloudTokenJson`. Surface errors via `IDialogService`.
7. **[BLOCKER, P1] Implement the phone-side `DoradoCloudClient` for Android.** New `app/src/main/java/com/heretek/dorado_hd/cloud/` Kotlin package with a Retrofit/OkHttp client that mirrors `DoradoCloudClient.cs`'s method surface. Reuse `kxs` serialization. Default base URL is empty (opt-in). No live calls in unit tests — all behind a `FakeDoradoCloudClient` for design-invariant tests.
8. **[P1] Replace `ArtistEnrichmentCoordinator`'s direct MusicBrainz + Fanart.tv calls with `DoradoCloudClient` catalog/artwork calls**; fall back to the existing clients only when the cloud is disabled or unreachable. Add a feature-flag so the local path stays runnable offline.
9. **[P1] Replace `PodcastService` directory discovery with `DoradoCloudClient.DirectorySearchAsync("podcasts", q)`**; keep per-feed RSS ingestion local. Same offline-fallback pattern.
10. **[P2] Bridge `UserStatsService` activity into cloud `/v1/social/feed` POST** so cross-device Zune Cards reflect listening history. Behind user opt-in.

### Vector 3 — Zune Package Execution & Parity

11. **[BLOCKER, P0] Expose a stable IPC bridge for `dorado-emu` from the desktop.** Add a new `Dorado.Cli.Ipc` project that wraps `Program.cs`'s `inspect` / `unpack` / `refs` / `run` commands behind a stdin/stdout JSON-RPC 2.0 façade using `Dorado.Plugins.Protocol`'s `JsonRpcChannel`. The desktop spawns one emulator process per session and pipes commands. Same shape as the plugin host, so the existing `ProcessPluginTransport` is reusable.
12. **[BLOCKER, P1] Add CI fixtures for headless `.ccgame` + `.zcp` validation.** Reference test packages live in `corpus/`; commit a tiny `Pong.zcp` golden-frame test in `Dorado.Tests` that asserts `dorado run Pong.zcp --frames 1 --hash` produces a stable SHA-256 across CI runners. Currently the emu has no golden-frame CI; this is the regression net.
13. **[P2] In-process embed option.** When the desktop runs `Dorado.Desktop.dll` on a host with Mono (`libmonosgen-2.0.so`) available, allow `Dorado.Cli` to load in-process via `AssemblyLoadContext`. Skip if the host is .NET-only — keep the sub-process path as the default.
14. **[P2] Mini-app parity inventory.** Cross-reference the 29 mini-apps in `dorado-hd/ui/apps/DoradoApps.kt` against `dorado-emu/corpus/`. For each: classify as native Compose (current), original XNA behavior (parity target), or mock-only. Output as `docs/parity/mini-app-parity.md` under `dorado-emu/`.

### Vector 4 — UI Invariants & Design System Canon

15. **[P2] Token & motion harmonization.** Already aligned by design intent (`dorado-hd/docs/design-tokens.md` cites the Dorado skill as source). Add a CI guard: a `DesignInvariantAudit` test in `dorado` that loads `design-tokens.md` from the sibling repo at build time and asserts Avalonia brushes match every HD token (zero radius, opacity ladder, accent palette). Skip if sibling repo absent (offline build).
16. **[P2] Share Selawik OFL font assets** between `dorado-hd/app/src/main/res/font/Selawik*.ttf` and `dorado/src/Dorado.UI/Assets/Selawik/`. Add a `tools/sync_fonts/` script and a `Make` target. Both repos already include `OFL-Selawik.txt`.

### Continuous Gates

17. **[CONTINUOUS] Local gate runner.** Add `tools/audit.sh` at the project-dorado root: builds + tests all four repos in sequence (`.NET` first, then Gradle), fails on any `warnaserror` violation or test failure, prints a Markdown summary. Use this as the pre-commit / pre-push gate.
18. **[CONTINUOUS] Single source of truth for design tokens.** Both repos point at the same `design-tokens.md`; add a `tools/lint_tokens.py` that asserts every HD Compose screen imports from `DoradoTokens` (no raw hex). Same idea on the Avalonia side.

---

## 9. Deferred (DO NOT pick up — already explicitly out of scope per `deferred_registry.md` and `true_parity_task_plan.md`)

- i18n beyond `en` / `fr` (mechanical, deferred)
- UPnP media sharing (`ZuneNSS` parity; servers dead)
- Explorer / taskbar shell integration (Windows-only cosmetic)
- MTPZ firmware update / restore / rollback (hardware N-A)
- CD Land real pipeline (no optical drive)
- Mini-player video surface (deferred polish)
- Notification-area tray icon
- Mixview external related-artist satellites (rate-limit pressure)
- OS file associations (FILETYPES.UIX; invasive per-platform)
- Chevron scroll-arrow overlay (assets absent post IP move)

---

## 10. Verification Targets (what "done" looks like)

- `dotnet build Dorado.sln -c Release /warnaserror` (desktop) → 0 warnings, 0 errors
- `dotnet build DoradoCloud.sln -c Release /warnaserror` (cloud) → 0 warnings, 0 errors
- `dotnet build Dorado.sln -c Release /warnaserror` (emu) → 0 warnings, 0 errors
- `./gradlew testDebugUnitTest` (HD) → all green; `DesignInvariantTest` passes
- Cross-repo contract round-trip test (cloud Shared ↔ client) passes for every DTO
- `dorado run Pong.zcp --frames 1 --hash` produces the same SHA-256 in CI
- `DoradoCloudClient.CheckForUpdateAsync` returns `UpdateReleaseDto` end-to-end through real HTTP
- `SyncEndpointHost` round-trips a `SyncPlan` between desktop and a phone-side Kotlin client (mock or real)

---

## 11. Audit-Live Status (Phase 2 + Phase 3 complete)

| Gate | Command | Result |
|---|---|---|
| Cloud build | `dotnet build DoradoCloud.sln -c Release /warnaserror` | **0 warnings, 0 errors** |
| Cloud tests | `dotnet test DoradoCloud.sln -c Release` | **55 / 55 pass** (44 existing + 11 new wire-shape tests in `DoradoCloud.Client.Tests`) |
| Desktop build | `dotnet build Dorado.sln -c Release /warnaserror` | **0 warnings, 0 errors** (cross-repo `DoradoCloud.Client` ProjectReference resolved) |
| Desktop tests | `dotnet test Dorado.sln -c Release` | **255 / 255 pass** (4 Domain + 251 Application; +4 new `CloudBackedMetadataServiceTests`) |
| Emu build | `dotnet build Dorado.sln -c Release /warnaserror` | **0 warnings, 0 errors** |
| Emu tests | `dotnet test Dorado.sln -c Release` | **18 / 18 pass** (no regressions) |

### Phase 2 / Phase 3 deliverables shipped

1. **`DoradoCloud.Shared/Contracts/Contracts.cs`**: added canonical `MeResponse` (eliminates the client-local duplicate).
2. **`DoradoCloud.Client/DoradoCloudClient.cs`**: rewritten — exposes 23 typed methods covering every server module (catalog, artwork, directory, recs, social, updates, identity). Uses canonical `JsonSerializerDefaults.Web`; no more redefined DTOs.
3. **`DoradoCloud.Client.Tests/`** (new project, 11 tests): wire-shape regression net — every endpoint has a fixture-backed round-trip test. Locked `UpdateCheckResponse`, `MeResponse`, `CatalogSearchResponse`, `DirectorySearchResponse`, `QuickMixResponse`, `ProfileDto`, `RegisterDeviceRequest`, `PutSettingsRequest`, and the RS256 verification round-trip.
4. **`Dorado/Dorado.Infrastructure.External.csproj`**: cross-repo `ProjectReference` to `dorado-cloud/clients/DoradoCloud.Client/DoradoCloud.Client.csproj` (3 `..`s, not 4).
5. **`Dorado.Application/Models/AppSettings.cs`**: added `CloudEnabled`, `CloudBaseUrl`, `CloudAccessToken`, `CloudAccessTokenExpiresAtUtc`, `CloudPreferCloud`.
6. **`Dorado.Infrastructure.External/CloudBackedMetadataService.cs`** (new): decorator over `IExternalMetadataService` that prefers the cloud for `FetchArtistMetadataAsync` and `FindAlbumArtworkAsync`, with full fallback to the inner service on disable / misconfigure / transient failure.
7. **`Dorado.Desktop/App.axaml.cs`**: `DoradoCloudClient` registered as a singleton (with bearer + UA headers from settings); `IExternalMetadataService` now resolves to the cloud-backed decorator wrapping the inner `ExternalMetadataService`.
8. **`Dorado.Tests.Application/CloudBackedMetadataServiceTests.cs`** (new, 4 tests): proves cloud-first when enabled, fallback when disabled, fallback on cloud 5xx, and cloud artwork when a release-group hit is found.

### Phase 2 / Phase 3 still to ship

- Phase 5: Kotlin mirror of `DoradoCloudClient` for `dorado-hd`; LAN sync endpoint on `Dorado.Infrastructure.Devices`.

---

## 12. Audit-Live Status (Phase 4 complete)

| Gate | Command | Result |
|---|---|---|
| Emu build | `dotnet build Dorado.sln -c Release /warnaserror` | **0 warnings, 0 errors** |
| Emu tests | `dotnet test Dorado.sln -c Release` | **27 / 27 pass** (18 existing + 9 IPC headless-validation) |
| Desktop build | `dotnet build Dorado.sln -c Release /warnaserror` | **0 warnings, 0 errors** |
| Desktop tests | `dotnet test Dorado.sln -c Release` | **262 / 262 pass** (4 Domain + 258 Application) |

### Phase 4 deliverables shipped

1. **`dorado-emu/src/Dorado.Cli.Ipc/`** (new library project): `EmulatorRpcServer` exposes `inspect` / `unpack` / `refs` / `run` over JSON-RPC 2.0 using the desktop's `Dorado.Plugins.Protocol` framing; `StdioLineTransport` frames stdin/stdout and raises `Exited` on EOF.
2. **`Dorado.Cli/Program.cs`**: `dorado --ipc` switches into the JSON-RPC bridge mode; the human CLI (`inspect`/`unpack`/`refs`/`run`) is unchanged. Verified end-to-end: `dorado --ipc` returns correct responses and exits `0` on stdin EOF.
3. **`dorado-emu/src/Dorado.Cli.Ipc` fix**: resolved a subscribe-after-start race where immediate stdin EOF was lost and the process hung; `ServeAsync` now subscribes to `Exited` before starting the read loop.
4. **`dorado-emu/tests/Dorado.Tests/SyntheticPackages.cs`** (new): self-authored MSCF/MSZIP cabinet and NX container builders. These emit original bytes in the documented public formats, so headless validation runs in CI **without fetching the git-ignored corpus** (no licensing risk).
5. **`EmulatorRpcServerTests`** (9 tests): `inspect`/`unpack`/`refs`/`run` over paired in-memory transports; 3 tests run entirely on synthetic packages and always execute in CI.
6. **`dorado-emu/.github/workflows/ci.yml`**: now builds with `/warnaserror` and runs the full suite including the headless IPC validation.
7. **`AssemblyInfo.cs`** (emu tests): disables test parallelization — the emulator runtime is a static singleton (`PlatformHost`, CWD) and concurrent tests clobbered each other's state.
8. **`dorado/src/Dorado.Infrastructure.Emulator/`** (new project): `IEmulatorBridge` + `JsonRpcEmulatorBridge` + `EmulatorProcessTransport`. Lazily spawns `dorado --ipc` on first use and drives the JSON-RPC surface.
9. **`AppSettings`**: added `EmulatorEnabled` and `EmulatorCliPath`; **`App.axaml.cs`** registers `IEmulatorBridge` (lazy factory — no process starts unless resolved).
10. **`EmulatorBridgeTests`** (5 tests): in-memory fake emulator proves the JSON parsing/error mapping.
11. **`EmulatorProcessEndToEndTests`** (2 tests): the desktop bridge spawns the **real** emulator CLI sub-process and round-trips `refs`/`inspect` over JSON-RPC (no-ops when the sibling repo is absent).

---

## 13. Audit-Live Status (Phase 5 complete) — FINAL VERIFICATION

| Repo | Build (`/warnaserror`) | Tests | Invariant audit |
|---|---|---|---|
| `dorado-cloud` | **0 warnings, 0 errors** | **55 / 55** (44 + 11 client) | n/a |
| `dorado` (desktop) | **0 warnings, 0 errors** | **354 / 354** (14 Domain + 340 Application) | **PASSED** (25 files, 0 violations) |
| `dorado-emu` | **0 warnings, 0 errors** | **27 / 27** (18 + 9 IPC) | n/a |
| `dorado-hd` | **0 warnings, 0 errors** (assembleDebug) | **140 / 140** | **PASSED** (`DesignInvariantTest`) |

### Phase 5 deliverables shipped

1. **`dorado-hd/app/.../cloud/CloudJson.kt`** (new): dependency-free JSON codec — plain-JVM unit tests cannot use `org.json`, and the app ships no Retrofit/Moshi.
2. **`dorado-hd/app/.../cloud/CloudContracts.kt`** (new): Kotlin mirrors of the shared cloud DTOs (catalog, directory, recs, updates, identity, social), camelCase to match the wire shape.
3. **`dorado-hd/app/.../cloud/CloudHttp.kt`** (new): `CloudHttp` seam + `HttpURLConnectionCloudHttp` (get/post/put/delete + binary `getBytes` for artwork).
4. **`dorado-hd/app/.../cloud/DoradoCloudClient.kt`** (new): 25 typed methods mirroring the desktop cloud client — catalog search/artist, artwork front, podcast + radio directory, QuickMix, update check + signing key, identity (me/devices/settings), social (profile/zunecard/feed/activity/follow/block).
5. **`dorado-hd/app/.../cloud/CloudUpdateVerifier.kt`** (new): RS256 verification matching `UpdateManifestCrypto.cs` **byte-for-byte**. The canonical JSON reproduces .NET's `JavaScriptEncoder.Default` exactly (verified against four generated .NET vectors, including control chars, printable ASCII, unicode, and surrogate pairs) and correctly quotes `DateTimeOffset` outside the string encoder.
6. **`SettingsRepository`**: `cloudEnabled` / `cloudBaseUrl` / `cloudAccessToken`.
7. **`CloudClientTest.kt`** (16 tests): four .NET canonical-JSON parity vectors, RSA sign/verify accept + tamper-reject, URL building/escaping, and response parsing.
8. **`dorado/src/Dorado.Infrastructure.Devices/SyncProtocol.cs`** (new): explicit LAN sync contract — `sync.hello|pair|manifest|pull|push` methods, `_dorado-sync._tcp`, port 8787, and camelCase DTOs shared conceptually with `SyncProtocol.kt`.
9. **`RemoteDeviceTransport.cs`** (new): `IDeviceTransport` over the phone's transmitted content snapshot; deterministic string→Guid entity id mapping.
10. **`SyncEndpointHost.cs`** (new): JSON-RPC handler computing the plan from the desktop library + phone snapshot; pairs on a 6-digit code; serves the plan, the ADD manifest (with artist/album/heart-rating for transfer), and accepts reverse-sync play-count/rating pushes.
11. **`NetworkStreamLineTransport.cs`** + **`SyncTcpServer.cs`** (new): real TCP socket host, line-framed with the shared `JsonRpcChannel`.
12. **`AppSettings`**: `LanSyncEnabled`, `LanSyncPort`, `LanSyncPairingCode`; **`App.axaml.cs`** registers `SyncEndpointHost` (built from the real `IMediaLibraryService`/video/photo/podcast services) and `SyncTcpServer`, starting the listener only when opted in.
13. **`SyncEndpointTests.cs`** (7 tests): hello camelCase, pair accept/reject, manifest ADD/KEEP computation, pull metadata + heart rating, push, and a **real TCP round-trip** through `SyncTcpServer`.
14. **`dorado-hd/app/.../sync/SyncClient.kt`** (new): phone-side socket client (`SyncLineTransport` seam + `SocketSyncLineTransport`) speaking the same methods.
15. **`SyncClientTest.kt`** (7 tests): request framing, camelCase parsing, error propagation, and request-id sequencing.
16. **`dorado-hd/app/.../cloud/CloudMetadataSource.kt`** (new): cloud-first artist metadata hydration (catalog → MBID → artwork CDN), a disambiguation bio fallback, and listen-activity posting to the social module. Wired into `ArtistImageService` and `ArtistBioService` (cloud-first, local fallback) and constructed in `DoradoApp` from live settings.
17. **`CloudMetadataSourceTest.kt`** (8 tests): enable gating, catalog resolution, artwork bytes, bio fallback, unknown-artist null, token-gated listen posting with bearer auth.

### Vector 1 — identity, social & directory integration added

- **`ICloudSocialService`** + `CloudSocialService`: posts completed listens as activities, fetches live Zune Cards, upserts the profile, registers the desktop device, and syncs settings. The client self-heals when the base URL/token changes at runtime.
- **`UserStatsService.RecordTrackPlayedAsync`** now mirrors each completed play to the cloud (fire-and-forget, never blocking playback) — the desktop's play history feeds the live cross-device Zune Card. `ZuneProfile`/`ZuneBadge`/`ZuneCard.cs` remain the local projection.
- **`ICloudDirectoryService`** + `CloudDirectoryService`: unified podcast (Podcast Index) and radio (Radio-Browser) directory search via the cloud, with the offline no-op default.
- **`IPodcastService.SearchDirectoryAsync`** delegates discovery to the cloud; subscribe-by-URL stays local.
- DI registration for all three services in `App.axaml.cs`.
- Tests: `CloudSocialServiceTests` (9) and `CloudDirectoryServiceTests` (7), covering bearer auth, parsing, disabled/no-op paths, and playback survival on cloud failure.
- Note: `ArtistEnrichmentCoordinator` already consumes `IExternalMetadataService`, which now resolves to the cloud-backed decorator — so artist enrichment is cloud-first without further changes.
- **Live Zune Card rendering**: `ZuneCardViewModel` now fetches the live cross-device card (`ICloudSocialService`) and exposes `HasLiveCard` / `LiveFollowersText` / `LiveFollowingText` / `LiveActivitiesText` / `LiveBadges` / `LiveRecent`; `ZuneCardView.axaml` renders a "LIVE ZUNE CARD" section (zero corner radius, token colours) that appears only when the cloud is enabled and a handle is configured. `AppSettings.CloudHandle` selects the handle. `ZuneCardLiveTests` (5) cover populated/hidden states.

### Vector 2 & 3 artifacts added

- **`docs/parity/media-formats.md`** + `MediaFormats.cs`/`MediaFormats.kt`: the shared ingest set, the HD-playable set (Media3), and the transcode targets, with parity tests on both sides (desktop 10, HD 6).
- **`dorado-emu/docs/mini-app-parity.md`**: all 29 HD mini-apps cross-referenced against the official `.zcp` packages and the emulator corpus, with a coverage summary (21 faithful native, 8 network shells, 2 runnable XNA goldens).
- **`dorado-emu/docs/zcp-cross-validation.md`**: field-by-field agreement between `dorado-hd/docs/zcp-inventory.md` and `Dorado.Containers/Zcp/ZcpReader.cs`, pointing at the executable tests.

### Vector 4 — design-system parity + font remediation

- **`docs/parity/design-system-parity.md`**: shared invariants, the intentional accent/motion divergences (device vs 4.8 software are different products), and the asset/font gap.
- **`docs/parity/font-sharing.md`**: the Selawik sharing contract between the two clients.
- **Microsoft fonts removed from the desktop**: the four `SegoeZ*.ttf` binaries and `SEGOEZ-LIGHT.TTC` are deleted; the five OFL Selawik faces are copied into `dorado/src/Dorado.UI/Assets/Selawik/` and the three `ZuneTheme.axaml` font families now resolve through Selawik-first with Inter/system fallbacks.
- **`FontAssetPolicyTests`** (2 tests) guard the policy: no non-Selawik font binary under `Assets/`, and no `FontFamily` may resolve through `Segoe Z`.
- **Artwork + fonts + sounds re-created clean-room, Microsoft assets fully removed.** All 349 Microsoft files under `Assets/Zune` are gone:
  - 279 icons across 9 folders → `Dorado.UI.Design.ZuneGlyphs` vector geometries (the animated Now Playing icon became a procedural `Equalizer` via `EqualizerGeometryConverter`, keeping geometry out of the platform-free ViewModel).
  - 9 wallpaper JPEGs → `DORADO-BACKGROUND-*.PNG` generated by `tools/gen_backgrounds.py`.
  - 4 WAV chimes → `DORADO-CHIME-*.WAV` generated by `tools/gen_sounds.py`.
  - 5 Microsoft fonts → OFL Selawik (earlier).
  - `Assets` now contains only OFL Selawik, generated art, and the project's own branding.
- `ZuneGlyphsTests` / `FontAssetPolicyTests` (21 assertions) guard the removed folders, forbidden references, non-Selawik fonts, and non-generated backgrounds.

### Desktop OIDC Authorization Code + PKCE sign-in

- `IOAuthPkceService` + `OAuthPkceService`: RFC 7636 S256 challenge generation and the `/connect/authorize` / `/connect/token` exchanges against the cloud's OpenIddict server — no embedded client secret.
- `LoopbackRedirectListener`: a 127.0.0.1 HTTP listener that captures the `?code=` callback (started before the browser opens) and serves a confirmation page.
- `ICloudSignInService` + `CloudSignInService`: orchestrates browser launch → loopback callback → token exchange → persist access token + expiry into `AppSettings`, enabling the `Cloud*` services. Registered in DI.
- Tests: `OAuthPkceServiceTests` (5, incl. the RFC 7636 Appendix B vector) and `CloudSignInServiceTests` (3, incl. a full loopback sign-in round-trip).
- **User-reachable**: a "DORADO CLOUD" section in Settings (Game preview → Online) with enable toggle, base URL, handle, and SIGN IN/SIGN OUT commands + live status, wired through `SignatureViewModel → MainShellViewModel → DI`. `SettingsCloudTests` (4) cover status, commands, and a **regression fix**: `SaveCurrentSettings` previously rebuilt `AppSettings` from scratch and would wipe the sign-in token (and the LAN-sync/emulator fields) on any settings change — it now preserves service-owned fields.

### HD interactive OAuth 2.0 (PKCE) sign-in

- `OAuthPkce` (HD): RFC 7636 S256 challenge, the `connect/authorize` URL, and the `connect/token` exchange via the shared `CloudHttp.postForm` — mirroring the desktop, no client secret.
- `CloudSignIn` + `CloudSignInCallback`: launches the browser, suspends on a `CompletableDeferred` that `MainActivity` completes from the `doradohd://oauth` deep link (state-validated), exchanges the code, and persists the token + enables the cloud.
- `AndroidManifest.xml` gains the `doradohd` browsable intent-filter; `MainActivity` is `singleTask` and forwards `onCreate`/`onNewIntent` deep links.
- Settings screen gains a **DORADO CLOUD** section: enable toggle, cloud URL prompt, and SIGN IN / SIGN OUT rows reflecting token state.
- Tests: `OAuthPkceTest` (5, incl. the RFC 7636 vector) and `CloudSignInTest` (6, incl. the deep-link callback bridge and state-mismatch rejection).

### HD records play history to the cloud

- `ScrobbleService.record` now mirrors each completed play to the cloud social feed via `CloudMetadataSource.recordListen` (best-effort, wrapped so a cloud failure never affects local playback or the Last.fm queue). It fires independently of the Last.fm scrobble gate, so a user with Last.fm off still gets a live cross-device Zune Card.
- Wired in `DoradoApp`; covered by two new `ScrobbleTest` cases (mirror-when-Last.fm-off, and cloud-failure-swallowed).

### Desktop consumes the signed OTA feed

- `ICloudUpdateService` + `CloudUpdateService`: fetches `GET /v1/updates/{app}/{channel}`, then verifies the detached RS256 signature over the canonical manifest against the published signing key (`GET /v1/updates/signing-key`) using the shared `UpdateManifestCrypto` contract. An unverified release is returned with `SignatureVerified = false` and must never be applied.
- Registered in DI; `AppSettings.AutoCheckForUpdates` remains the user gate.
- Tests: `CloudUpdateServiceTests` (5) — real RSA sign/verify accept, tamper reject, unavailable, disabled, and cloud-error paths.

### HD consumes cloud QuickMix for DynamicMix

- `CloudMixSource` (implements `MixSuggester`) resolves "more like this" artist names from `GET /v1/recs/quickmix`; `CloudMixService` blends them into the on-device `DynamicMixService` result, deduped, capped at `trackLimit`, and deterministically ordered.
- Wired into `DoradoGraph`/`DoradoApp`; the two mix call sites (`HomeScreens`, `trackMenuActions`) already run in coroutine scopes.
- Tests: `CloudMixSourceTest` (4) and `CloudMixServiceTest` (5). The local result stays complete when the cloud is disabled, so offline behaviour is unchanged.

### Transcode pipeline — real encode, end to end

- `SyncPullItemDto.TranscodeTarget` (desktop) / `SyncPullItem.transcodeTarget` (HD) carry the device-playable container per pull item, derived from `Dorado.Domain.Models.MediaFormats`.
- `ITranscodeService` + `FfmpegTranscodeService` (new): maps a target container to a codec profile (`m4a`→AAC 256k, `mp3`→LAME 320k, `flac`→FLAC, `ogg`→Vorbis, `opus`→Opus) and runs `ffmpeg -i … -progress pipe:1`, reporting progress against the `ffprobe` duration. `IsAvailable` probes FFmpeg; when absent the pipeline copies verbatim.
- `SyncEngine.ApplyPlanAsync` now transcodes unsupported ADD items to a temp file, transfers it, and deletes it — the transfer pipeline is codec-correct against HD's Media3 support.
- Registered in DI (`FfmpegTranscodeService`).
- Tests: `FfmpegTranscodeServiceTests` (14 cases incl. a **real WAV→M4A encode**, skipped only if FFmpeg is absent) and `SyncEngineTranscodeTests` (3: transcode-unsupported, copy-playable, unavailable-transcoder).

**Grand total:** 55 (cloud) + 354 (desktop) + 27 (emu) + 140 (HD) = **576 tests, all passing**, four repos building with `0 warnings / 0 errors`.

### Cross-repo integration verified end-to-end

- **Cloud contracts**: server ⇄ desktop `DoradoCloud.Client` ⇄ Kotlin `DoradoCloudClient` all share one wire shape; the desktop exercises it via `CloudBackedMetadataService`, the phone via 25 typed methods.
- **OTA verification**: `CloudUpdateVerifier` byte-matches `UpdateManifestCrypto.Serialize` for arbitrary inputs; the desktop verifies via the same shared helper.
- **Emulator**: desktop `JsonRpcEmulatorBridge` spawns the real `dorado --ipc` CLI and round-trips `refs`/`inspect` (proven by a sub-process E2E test).
- **LAN sync**: desktop `SyncTcpServer` ⇄ phone `SyncClient` over JSON-RPC 2.0; heart ratings, play counts, playlists/sync-groups and media metadata are carried by explicit DTOs.

### Known remaining work (not required to satisfy the five phases)

- The desktop's `ZuneCardView` does not yet render the live `ZuneCardSnapshot` (the service + DI are in place; the view still shows the local projection).
- Turbulence: `dorado` currently has unpushed local commits on top of the pushed P0 commit (pre-existing state, not introduced here).
- Vector 4 (typography/motion/asset normalization) remains a doc-level task; the invariant audits themselves pass on both clients.
- Transcoding is now **real and end-to-end**: contract → sync `transcodeTarget` → `FfmpegTranscodeService` encode during apply (see the section above).
- HD does not yet consume cloud QuickMix for DynamicMix (the client method exists and is tested).

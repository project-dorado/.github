# Dorado — Program Status

**Last updated:** 2026-09-10

A consolidated view of what has been completed and what remains across the
organization. Legend: ✅ done · 🚧 in progress · ⏳ pending

## Repositories

| Repository | Purpose | State |
|---|---|---|
| [dorado](https://github.com/project-dorado/dorado) | Zune 4.8 desktop re-creation (.NET 8 / Avalonia) | ✅ pushed through the P0 IP fix; 🚧 **11 unpushed local commits (Phase 12–19) + uncommitted WIP** |
| [dorado-hd](https://github.com/project-dorado/dorado-hd) | Zune HD Android client (Kotlin / Compose) | ✅ pushed (Sprint 4: marketplace, device sync, scrobble, lyrics, audio analysis) |
| [dorado-cloud](https://github.com/project-dorado/dorado-cloud) | Community cloud services (.NET 8) | ✅ M0–M5 done; ⏳ M6 legal-gated |
| [dorado-emu](https://github.com/project-dorado/dorado-emu) | Zune HD `.zcp`/`.ccgame` XNA emulator core | ✅ present |
| [project-dorado.github.io](https://github.com/project-dorado/project-dorado.github.io) | Organization website (dorado.org.uk) | ✅ present |
| [.github](https://github.com/project-dorado/.github) | Org profile + community health files | ✅ published |

## Completed

### Repository migration & rebrand
- `Heretek-AI/not-zune` → **project-dorado/dorado** (history preserved, full rename: assemblies/namespaces, storage paths, assets, CI, docs).
- `Heretek-AI/xune-HD` → **project-dorado/dorado-hd** (package `com.heretek.dorado_hd`, full `Xune*`→`Dorado*`, DB/DataStore ids, CI).
- No dangling `Heretek-AI` URLs (only provenance/attribution references remain); no submodules.
- Original author copyrights preserved; MIT licensing retained.

### Organization branding
- Org profile repo `.github` with `profile/README.md`, brand assets (banner, marks), and org-wide community health files (CONTRIBUTING, SECURITY, CODE_OF_CONDUCT, SUPPORT).
- Org metadata set (name "Dorado", description, website); repository topics + descriptions set.

### P0 — IP remediation (partial)
- ✅ Decompiled Microsoft Zune corpus moved **out** of `dorado` to a local `zune-disassembly/` reference and removed from the repository (`tools/disassembly`, 3,953 files); tooling and docs repointed; `.gitignore` updated.
- ⏳ **Still bundled in `dorado`:** `src/Dorado.UI/Assets/Zune/` (Microsoft artwork + SegoeZ fonts). These need to be replaced/relocated; `ZuneTheme.axaml` still references the bundled fonts.

### Dorado Cloud (M0–M5)
- M0 Foundations · M1 Identity+sync+updates · M2 Directory · M3 Catalog+artwork CDN · M4 Social · M5 QuickMix — all implemented, **44/44 tests**, **0 build warnings**, CI green, images published to `ghcr.io/project-dorado/dorado-cloud-{api,gateway}`.
- See [`dorado-cloud/ROADMAP.md`](https://github.com/project-dorado/dorado-cloud/blob/main/ROADMAP.md).

## Pending

| Item | Owner area | Notes |
|---|---|---|
| **Push `dorado` local work** | dorado | 11 commits (Phase 12–19) + uncommitted files (`IReviewService`, `ReputationEngine`, `SqliteReviewService`, view/VM edits) are **local only**. Review, finish, commit, push. |
| **Finish P0 assets/fonts** | dorado | Replace SegoeZ with OFL Selawik/Inter; relocate/re-create the bundled Zune artwork; correct `NOTICE.md`. |
| **M6 — Media** | dorado-cloud | License-gated PD/CC streaming; requires legal review. |
| **Client integration** | dorado / dorado-hd | Point clients at `dorado-cloud` (metadata, artwork, updates, account, recs). |
| **Manual GitHub steps** | org | Upload the org avatar (`dorado-cloud`/`.github` `profile/assets/dorado-avatar-512.png`) and pin repositories. |
| **Cloud hardening** | dorado-cloud | EF Core migrations, consent screen, login rate-limiting + CSRF, account lifecycle (GDPR), pgvector QuickMix, Discogs/Fanart providers. |

## Verification snapshot

- **dorado-cloud:** `dotnet build -c Release /warnaserror` → 0 warnings/0 errors; 44/44 tests; CI green.
- **dorado-hd:** CI `Build & Test` green on pushed `main`; design-invariant + logic tests pass.
- **dorado:** last pushed CI green (P0 commit); local Phase 12–19 build/test status to be confirmed before push.

## Security & legal posture

- No Microsoft code, binaries, fonts, firmware or artwork should be redistributed (the disassembly corpus has been removed; the bundled `Assets/Zune` set is the remaining item).
- No DRM circumvention and no license-server emulation.
- No copyrighted media hosted; streaming is restricted to public-domain / CC content.
- Zune, Zegoe, Zune HD and Microsoft are trademarks of Microsoft Corporation; Dorado is an independent, non-affiliated homage.

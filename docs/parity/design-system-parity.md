# Design-system parity (Dorado desktop ↔ Dorado-HD)

**Date:** 2026-09-10

Both clients follow the same canon (`dorado-hd/docs/zune-hd-ui-canon.md`,
`dorado-hd/docs/design-tokens.md`, and the desktop's Zune 4.8 palette). This
document records the **shared invariants**, the **intentional divergences**
(device vs desktop are different product generations), and the **asset/font
normalization gap**.

## Shared invariants (both clients)

| Invariant | Desktop | Dorado-HD |
|---|---|---|
| Zero corner radius | `DesignInvariantTest` (Avalonia) audits; **PASSED** (26 files, 0 violations) | `DesignInvariantTest` bans `RoundedCornerShape`; **PASSED** |
| Text-first navigation | Pivot strips, no icon nav | Crossbar, no icon nav |
| Tri-state hearts (not stars) | `HeartRating` enum | `Rating` enum |
| Opacity communicates state | token ladder | token ladder |
| Motion decelerates (no springs) | `CubicEaseOut` | `CubicBezierEasing(0.1, 0.9, 0.2, 1.0)` |
| 480×272 device canvas | device-mode window | `DeviceCanvas` |

## Intentional divergences

| Token | Desktop (Zune 4.8 software) | Dorado-HD (Zune HD device) | Why |
|---|---|---|---|
| Primary accent | `#F10DA2` magenta | `#FA2A55` pink | Decompiled Zune 4.8 `WindowColorFromRGB` vs the HD device's pink. Different products. |
| Pivot slide | 420 ms (`PivotParallaxTransition`) | 380 ms (`DoradoMotion.PIVOT_SLIDE_MS`) | Desktop windows are larger; both decelerate. |
| Quickplay | 320 ms (tighter "parked left and rear") | 420 ms (`DoradoMotion.QUICKPLAY_MS`) | The two names target different surfaces; not a contradiction. |
| Type scale | Avalonia `FontSize` classes | `DoradoTokens.TYPE_*` (480×272 design units) | Different canvases. |

**Do not collapse these.** Aligning them would break one of the two canons.

## Asset & font normalization gap — ACTION REQUIRED

The desktop still ships **Microsoft-owned assets** under
`dorado/src/Dorado.UI/Assets/Zune/`:

- **349 files** — transport glyphs, branding, social seals, backgrounds
  (`.PNG`), extracted from the Zune 4.8 disassembly.
- **4 Microsoft font binaries** — `SegoeZLight.ttf`, `SegoeZUCLight.ttf`,
  `SegoeZLCLight.ttf`, `SegoeZLCAltLight.ttf` under `Assets/Zune/Fonts/`.
  `ZuneTheme.axaml` references them as `#Segoe Z Light` *before* the
  `Selawik`/`Inter` fallbacks.

This contradicts `AGENTS.md` ("Never bundle Microsoft fonts or firmware"),
`NOTICE.md`, and the project's IP posture. `STATUS.md` already lists
"Finish P0 assets/fonts" as pending.

### Remediation status

**Fonts — DONE.** The five OFL Selawik faces were copied from the HD resources
into `dorado/src/Dorado.UI/Assets/Selawik/`; the three `FontFamily` resources in
`ZuneTheme.axaml` now resolve through `avares://Dorado.UI/Assets/Selawik#Selawik`
with Inter/system fallbacks. All Microsoft font binaries (the four `SegoeZ*.ttf`
files and `SEGOEZ-LIGHT.TTC`) were deleted. `FontAssetPolicyTests` (2 tests)
guards the policy: no non-Selawik font binary may exist under `Assets/`, and no
`FontFamily` may resolve through a `Segoe Z` resource. Build, all 393 desktop
application tests, and the invariant audit (26 files, 0 violations) stay green.
Sharing is documented in `docs/parity/font-sharing.md`.

**Artwork — substantially DONE.** `Dorado.UI.Design.ZuneGlyphs` now provides
clean-room vector geometries for every UI glyph the views used, and the
Microsoft asset folders were removed outright:

| Folder | Files removed | Replacement |
|---|---|---|
| `Rating` | 57 | `Heart` / `BrokenHeart` vectors |
| `Transport` | 134 | `Play`/`Pause`/`SkipBack`/`SkipForward`/`Speaker`/`Repeat`/`Shuffle`/`ShowList` + a procedural `Equalizer` |
| `Window` | 50 | `Minimize`/`Maximize`/`Restore`/`Close`/`ArrowBack`/`CompactMode` |
| `Slideshow` | 6 | reused transport glyphs + `PlayCircle`/`PhotoFrame` |
| `Mixview` | 28 | `Play`/`Mix`/`Heart`/`BrokenHeart`/`Info`/`Add` |
| `Sync` | 4 | `Sync` circular arrow |
| `Social` | 2 | `ProfileTile` / `Seal` |
| `Branding` | 8 | `BrandMark` / `Device` (no Microsoft logos) |
| `CD` | 3 | radial-gradient `Ellipse` stack |

**Backgrounds & sounds — DONE.** The 9 wallpaper JPEGs were replaced by
procedurally generated 536×196 gradient PNGs (`DORADO-BACKGROUND-01..09.PNG`,
`tools/gen_backgrounds.py`), and the 4 Microsoft WAV chimes by synthesized
sine-partial chimes (`DORADO-CHIME-*.WAV`, `tools/gen_sounds.py`). Both
generators are committed and deterministic, so the art is original and
reproducible.

### Result

`dorado/src/Dorado.UI/Assets` now bundles **no Microsoft-owned files**:

| Group | Files | Origin |
|---|---|---|
| `Selawik/*.ttf` | 5 | OFL 1.1 |
| `Zune/Backgrounds/DORADO-BACKGROUND-*.PNG` | 9 | generated (`tools/gen_backgrounds.py`) |
| `Zune/Sounds/DORADO-CHIME-*.WAV` | 4 | generated (`tools/gen_sounds.py`) |
| `dorado.png` / `dorado.ico` / `dorado_32.png` | 3 | project branding |

Every icon the UI used (`RATING`, `TRANSPORT`, `ICON.NOWPLAYING`, `WINDOW`,
`SLIDESHOW`, `MIX`, `SYNC`, `PROFILE`, `ZUNELOGO`, `CD*`, …) is now a vector in
`Dorado.UI.Design.ZuneGlyphs`. `ZuneGlyphsTests` and `FontAssetPolicyTests` guard
the policy.

**Share vectors with HD.** HD draws its icons procedurally in Compose. Export
the recreated SVGs to both `dorado/src/Dorado.UI/Assets/` and
`dorado-hd/app/src/main/res/drawable/`.

## Tooling

- Desktop token source: `dorado/src/Dorado.UI/Styles/ZuneTheme.axaml`.
- Desktop motion: `dorado/src/Dorado.UI/Animations/PivotParallaxTransition.cs`.
- HD token source: `dorado-hd/app/src/main/java/com/heretek/dorado_hd/design/DoradoTokens.kt`.
- HD motion: `.../design/DoradoMotion.kt`.
- HD canon + tokens: `dorado-hd/docs/zune-hd-ui-canon.md`, `.../design-tokens.md`.
- Desktop invariants audit: `dorado/scripts/mcp_tools.py::audit_design_invariants`.

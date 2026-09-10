# Font sharing (desktop ↔ Dorado-HD)

Both clients render Zegoe UI's stand-in, **Selawik** (OFL 1.1, Segoe-metric).
The canonical copies live in the HD resource folder:

```
dorado-hd/app/src/main/res/font/selawk.ttf     (Regular)
dorado-hd/app/src/main/res/font/selawkl.ttf    (Light)
dorado-hd/app/src/main/res/font/selawksl.ttf   (Semilight)
dorado-hd/app/src/main/res/font/selawksb.ttf   (Semibold)
dorado-hd/app/src/main/res/font/selawkb.ttf    (Bold)
```

The desktop mirrors them at `dorado/src/Dorado.UI/Assets/Selawik/` and resolves
its three Zune font families through that folder
(`avares://Dorado.UI/Assets/Selawik#Selawik`).

## Why

Zegoe UI is a Microsoft asset and is never bundled (`AGENTS.md`). Selawik was
commissioned by Microsoft under the SIL Open Font License specifically as a
metric-compatible substitute, so switching preserves text layout.

## Keeping copies in sync

```bash
cp dorado-hd/app/src/main/res/font/selawk*.ttf dorado/src/Dorado.UI/Assets/Selawik/
```

The desktop suite guards this with `FontAssetPolicyTests`:

- no font binary under `Assets/` may be anything but Selawik, and
- no `FontFamily` may resolve through a `Segoe Z` resource.

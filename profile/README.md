<div align="center">

<img src="https://raw.githubusercontent.com/project-dorado/.github/main/profile/assets/banner.svg" alt="Dorado — The Zune experience, reborn" width="100%" />

<br/>

**Open-source re-creations of the Microsoft Zune experience — a cross-platform desktop media player, a Zune HD–style Android music client, and the emulator core that connects them.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://github.com/project-dorado/dorado/blob/main/LICENSE)
[![Desktop](https://img.shields.io/badge/Desktop-Windows%20%7C%20Linux-0078D7?style=flat-square&logo=dotnet&logoColor=white)](https://github.com/project-dorado/dorado)
[![Android](https://img.shields.io/badge/Android-9%2B-3DDC84?style=flat-square&logo=android&logoColor=white)](https://github.com/project-dorado/dorado-hd)
[![.NET](https://img.shields.io/badge/.NET-8.0-512BD4?style=flat-square&logo=dotnet&logoColor=white)](https://github.com/project-dorado/dorado)
[![Kotlin](https://img.shields.io/badge/Kotlin-Compose-7F52FF?style=flat-square&logo=kotlin&logoColor=white)](https://github.com/project-dorado/dorado-hd)

</div>

---

## The projects

<table>
<tr>
<td width="33%" valign="top" align="center">
<img src="https://raw.githubusercontent.com/project-dorado/.github/main/profile/assets/dorado.svg" width="84" alt="Dorado" /><br/>
<h3>Dorado</h3>
<sub><b>Desktop · .NET 8 · Avalonia</b></sub>
<p align="left">An authentic cross-platform re-creation of <b>Zune 4.8 Desktop</b>: Metro pivots, Quickplay &amp; Smart DJ, Mixview, a real BASS audio engine (gapless, crossfade, ReplayGain, FFT), libVLC video, and MusicBrainz / Fanart.tv / LRCLIB enrichment.</p>
<a href="https://github.com/project-dorado/dorado"><b>Repository →</b></a>
</td>
<td width="33%" valign="top" align="center">
<img src="https://raw.githubusercontent.com/project-dorado/.github/main/profile/assets/dorado-hd.svg" width="84" alt="Dorado-HD" /><br/>
<h3>Dorado-HD</h3>
<sub><b>Android · Kotlin · Compose</b></sub>
<p align="left">The <b>Zune HD</b> handheld, reborn for modern Android: the 480×272 device canvas, crossbar pivots, kinetic lists, tri-state hearts, Media3/ExoPlayer playback, a MediaStore-backed library, and 20+ faithfully re-implemented mini-apps and games.</p>
<a href="https://github.com/project-dorado/dorado-hd"><b>Repository →</b></a>
</td>
<td width="33%" valign="top" align="center">
<img src="https://raw.githubusercontent.com/project-dorado/.github/main/profile/assets/dorado.svg" width="84" alt="Dorado-EMU" /><br/>
<h3>Dorado-EMU</h3>
<sub><b>Emulation core</b></sub>
<p align="left">A Zune HD application emulator that runs <code>.zcp</code> / <code>.ccgame</code> XNA packages — the shared core behind the Android client's marketplace heritage.</p>
<a href="https://github.com/project-dorado/dorado-emu"><b>Repository →</b></a>
</td>
</tr>
</table>

---

## About

**Dorado** is an independent, community-driven effort to keep the Zune experience alive on
hardware people actually own. Each project is a behavioral re-implementation: we study the
original interface and rebuild it cleanly with modern, open tooling — no Microsoft binaries,
firmware, or DRM content are involved.

> The Zune design language was famously content-first: black canvases, typography as navigation,
> zero chrome, zero rounded corners. We take that canon seriously — and audit it in continuous
> integration.

## Technology at a glance

| | Dorado (desktop) | Dorado-HD (android) |
|---|---|---|
| **UI** | Avalonia 11 · XAML · MVVM | Jetpack Compose · Material 3 |
| **Audio** | BASS / ManagedBass (P/Invoke) | Media3 / ExoPlayer |
| **Video** | libVLCSharp | Media3 |
| **Storage** | EF Core + SQLite | Room + DataStore |
| **Toolchain** | .NET 8 · C# 12 | AGP 9 · Kotlin 2.4 · KSP |

## Community

- 📊 **[Program status](https://github.com/project-dorado/.github/blob/main/STATUS.md)** — what's done and what's pending across the organization
- 📖 **[Contributing](https://github.com/project-dorado/.github/blob/main/CONTRIBUTING.md)** — how to build, test, and open a great pull request
- 🛡️ **[Security policy](https://github.com/project-dorado/.github/blob/main/SECURITY.md)** — report a vulnerability privately
- 🤝 **[Code of Conduct](https://github.com/project-dorado/.github/blob/main/CODE_OF_CONDUCT.md)** — the standards we hold ourselves to
- 💬 **[Support](https://github.com/project-dorado/.github/blob/main/SUPPORT.md)** — where to ask questions

Every repository runs a full build, test suite, and design-invariant audit on each push via GitHub Actions.

<div align="center">
<br/>
<sub>
Zune, Zegoe, Zune HD and Microsoft are trademarks of Microsoft Corporation.<br/>
Dorado is an independent, non-affiliated homage and is not endorsed by or affiliated with Microsoft.
</sub>
</div>

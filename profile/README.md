<div align="center">

<img src="https://raw.githubusercontent.com/project-dorado/.github/main/profile/assets/banner.svg" alt="Dorado — The Zune experience, reborn" width="100%" />

<br/>

**Open-source re-creations of the Microsoft Zune experience — a cross-platform desktop media player, a Zune HD–style Android music client, a Zune HD application emulator, and the self-hostable community cloud that ties them together.**

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
<td width="25%" valign="top" align="center">
<img src="https://raw.githubusercontent.com/project-dorado/.github/main/profile/assets/dorado.svg" width="84" alt="Dorado" /><br/>
<h3>Dorado</h3>
<sub><b>Desktop · .NET 8 · Avalonia</b></sub>
<p align="left">An authentic cross-platform re-creation of <b>Zune 4.8 Desktop</b>: Metro pivots, Quickplay &amp; Smart DJ, Mixview, a real BASS audio engine (gapless, crossfade, ReplayGain, FFT, 10-band EQ), libVLC video, and MusicBrainz / Fanart.tv / LRCLIB / AcoustID enrichment.</p>
<a href="https://github.com/project-dorado/dorado"><b>Repository →</b></a>
</td>
<td width="25%" valign="top" align="center">
<img src="https://raw.githubusercontent.com/project-dorado/.github/main/profile/assets/dorado-hd.svg" width="84" alt="Dorado-HD" /><br/>
<h3>Dorado-HD</h3>
<sub><b>Android · Kotlin · Compose</b></sub>
<p align="left">The <b>Zune HD</b> handheld, reborn for modern Android: the 480×272 device canvas, crossbar pivots, kinetic lists, tri-state hearts, Media3/ExoPlayer playback, a MediaStore-backed library, a Now Playing widget, and <b>29</b> faithfully re-implemented mini-apps and games.</p>
<a href="https://github.com/project-dorado/dorado-hd"><b>Repository →</b></a>
</td>
<td width="25%" valign="top" align="center">
<img src="https://raw.githubusercontent.com/project-dorado/.github/main/profile/assets/dorado.svg" width="84" alt="Dorado-EMU" /><br/>
<h3>Dorado-EMU</h3>
<sub><b>Emulation core · .NET 8</b></sub>
<p align="left">A Zune HD application emulator that runs <code>.zcp</code> / <code>.ccgame</code> XNA 3.1 packages against a clean-room <code>Microsoft.Xna.Framework</code> shim — the shared core behind the Android client's marketplace heritage.</p>
<a href="https://github.com/project-dorado/dorado-emu"><b>Repository →</b></a>
</td>
<td width="25%" valign="top" align="center">
<img src="https://raw.githubusercontent.com/project-dorado/.github/main/profile/assets/dorado.svg" width="84" alt="Dorado Cloud" /><br/>
<h3>Dorado Cloud</h3>
<sub><b>Backend · .NET 8 · self-hostable</b></sub>
<p align="left">Community cloud services replacing the dead Zune web services: OpenIddict identity, device registry &amp; settings sync, signed updates, a MusicBrainz catalog + artwork CDN, podcast/radio directory, recommendations (<b>QuickMix</b>), social &amp; Zune Card.</p>
<a href="https://github.com/project-dorado/dorado-cloud"><b>Repository →</b></a>
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

| | Dorado (desktop) | Dorado-HD (android) | Dorado Cloud (backend) |
|---|---|---|---|
| **UI** | Avalonia 11 · XAML · MVVM | Compose + custom Zune tokens | Minimal APIs · OpenAPI |
| **Audio** | BASS / ManagedBass (P/Invoke) | Media3 / ExoPlayer | — |
| **Video** | libVLCSharp | Media3 | — |
| **Storage** | EF Core + SQLite | Room + DataStore | EF Core + PostgreSQL (Redis cache, S3/MinIO) |
| **Toolchain** | .NET 8 · C# 12 | AGP 9 · Kotlin 2.4 · KSP | .NET 8 · OpenIddict 5 |

## Community

- 📊 **[Program status](https://github.com/project-dorado/.github/blob/main/STATUS.md)** — what's done and what's pending across the organization
- 📖 **[Contributing](https://github.com/project-dorado/.github/blob/main/CONTRIBUTING.md)** — how to build, test, and open a great pull request
- 🛡️ **[Security policy](https://github.com/project-dorado/.github/blob/main/SECURITY.md)** — report a vulnerability privately
- 🤝 **[Code of Conduct](https://github.com/project-dorado/.github/blob/main/CODE_OF_CONDUCT.md)** — the standards we hold ourselves to
- 💬 **[Support](https://github.com/project-dorado/.github/blob/main/SUPPORT.md)** — where to ask questions

Every code repository runs a full build and test suite on each push via GitHub
Actions; the desktop and HD repositories additionally run the design-invariant UI
audit.

<div align="center">
<br/>
<sub>
Zune, Zegoe, Zune HD and Microsoft are trademarks of Microsoft Corporation.<br/>
Dorado is an independent, non-affiliated homage and is not endorsed by or affiliated with Microsoft.
</sub>
</div>

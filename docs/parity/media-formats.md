# Shared media-format contract (desktop ↔ Dorado-HD)

**Status:** locked by parity tests on both sides.

The desktop ingests more formats than the Zune HD Android client can play. During
sync the desktop copies device-playable files verbatim and transcodes the rest to
a device-playable container. This document is the human-readable form of the
contract; the machine-checked form lives in:

- `dorado/src/Dorado.Domain/Models/MediaFormats.cs`
- `dorado-hd/app/src/main/java/com/heretek/dorado_hd/data/model/MediaFormats.kt`

Each side has a test asserting the lists below, so changing one without the other
fails that repo's suite.

## Ingest set (desktop library scanner)

`mp3 · m4a · m4b · wma · mp4 · m4v · flac · ogg · opus · aac`

Mirrors the `AppSettings.IngestExtensions` default (Settings → File Types).

## HD-playable set (Media3 / ExoPlayer)

`mp3 · m4a · aac · flac · ogg · opus · mp4 · m4v`

Deliberately **absent**:

| Format | Why |
|---|---|
| `wma` | Open-source Media3 has no WMA extractor/decoder. |
| `m4b` | Audiobook container; not a device target in this generation. |

## Transcode policy

| Source | Action | Target |
|---|---|---|
| HD-playable (above) | copy verbatim | — |
| `wma` | transcode | `m4a` (AAC) |
| `m4b` | transcode | `m4a` (AAC) |
| `ape` | transcode | `m4a` (AAC) |
| `wav` | transcode | `flac` (lossless) |
| anything else | transcode | `m4a` (AAC) |

Lossless sources that the device supports (`flac`) are never transcoded. The
default target for unknown/unplayable audio is AAC in an M4A container.

## Emulator

The emulator's content pipeline consumes the same XNA `.xnb` payloads regardless
of container; it does not transcode audio. Its source packages are `.ccgame` /
`.zcp` and are out of scope for this audio contract.

## Changing the contract

1. Edit `MediaFormats.cs` (desktop) **and** `MediaFormats.kt` (HD).
2. Update both tests' expected literals.
3. Update this document.
4. Run `dotnet test` in `dorado` and `./gradlew testDebugUnitTest` in `dorado-hd`.

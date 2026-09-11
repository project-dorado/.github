# Contributing to Dorado

Thanks for your interest in Dorado! This document covers the whole organization.
Each repository also has its own `AGENTS.md` / build notes — read those before a
large change.

## Ways to contribute

- **Report a bug** using the issue template in the relevant repository.
- **Request a feature** — especially Zune-parity gaps; cite the behavior if you can.
- **Send a pull request** for a fix, a parity improvement, or documentation.
- **Improve tests** — all repositories run unit tests; the desktop and HD repos also enforce design-invariant audits.

## Ground rules

- Be respectful. See [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).
- **No Microsoft code, binaries, fonts, firmware, or DRM content.** Dorado is a
  behavioral re-implementation. Do not add decompiled Microsoft source or
  extracted Microsoft assets to any repository.
- Keep changes focused; one concern per pull request.
- Never commit secrets, tokens, or credentials.

## Building and testing

### Dorado (desktop — .NET 8 / Avalonia)

```bash
dotnet restore Dorado.sln
dotnet build Dorado.sln -c Release /warnaserror   # zero-warning policy
dotnet test Dorado.sln -c Release
```

Design-invariants audit:

```bash
python3 -c "import sys; sys.path.insert(0,'scripts'); from mcp_tools import audit_design_invariants; print(audit_design_invariants('.'))"
```

### Dorado-HD (Android — Kotlin / Compose)

```bash
export JAVA_HOME=/path/to/jdk-21
./gradlew test            # unit tests + design-invariant audit
./gradlew assembleDebug
```

### Dorado Cloud (backend — .NET 8)

```bash
dotnet restore DoradoCloud.sln
dotnet build DoradoCloud.sln -c Release /warnaserror
dotnet test  DoradoCloud.sln
```

Production runs EF Core **migrations** on PostgreSQL; local development uses
SQLite with `EnsureCreated`. Author migrations with the repo-local tool
(`dotnet tool restore`, then `dotnet ef …`).

### Dorado-EMU (emulator core — .NET 8)

```bash
dotnet build Dorado.sln -c Release
dotnet test  Dorado.sln
```

## Pull request checklist

- [ ] `dotnet build … /warnaserror` **or** `./gradlew test` passes with no new warnings
- [ ] Tests added or updated for behavior changes
- [ ] Design invariants still pass (zero corner radius, tokenized colors/motion)
- [ ] Documentation updated where setup or behavior changed
- [ ] No new references to the old `Heretek-AI` organization
- [ ] No Microsoft code/assets introduced

## Commit style

Conventional commits are preferred, e.g. `feat(ui/playlists): …`, `fix(sync): …`,
`docs(parity): …`, `chore(legal): …`.

## License

By contributing you agree that your contributions are licensed under the MIT
License of the repository you are contributing to.

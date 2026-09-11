# Security Policy

## Supported versions

Dorado is pre-1.0. Security fixes are applied to the `main` branch of each
repository; please test against the latest `main` before reporting.

## Reporting a vulnerability

**Please do not open a public issue for security problems.**

Use GitHub's private vulnerability reporting:

- Dorado (desktop): https://github.com/project-dorado/dorado/security/advisories/new
- Dorado-HD (android): https://github.com/project-dorado/dorado-hd/security/advisories/new
- Dorado Cloud (backend): https://github.com/project-dorado/dorado-cloud/security/advisories/new
- Dorado-EMU: https://github.com/project-dorado/dorado-emu/security/advisories/new

Include, where possible:

- affected repository and version/commit,
- a description of the issue and its impact,
- reproduction steps or a proof of concept,
- any suggested remediation.

We aim to acknowledge reports within a few days and will coordinate disclosure
once a fix is available.

## Scope

In scope: anything that affects users of the shipped applications — e.g. unsafe
deserialization, path traversal in library/sync scanning, injection through
metadata or network parsers, or handled secrets.

Out of scope: the Microsoft Zune decompilation corpus (not distributed here),
trademark/legal questions, and issues in third-party dependencies (report those
upstream, though we appreciate a heads-up).

## Please do not

- Test against systems you do not own or have permission to test.
- Upload or redistribute Microsoft code, binaries, fonts, firmware, or DRM content.

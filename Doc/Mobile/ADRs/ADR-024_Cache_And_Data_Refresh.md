# ADR-024 Cache And Data Refresh

Version: 2.0 (ForgeApp — Removed)

Status: Removed — Not Applicable to ForgeApp

---

> **Changelog**
> - **2.0 (2026-09-08):** Removed for ForgeApp. This ADR's decision solves a problem ForgeApp does
>   not have. ForgeApp has no remote source to cache from or refresh against — the Drift database is the source of truth directly (ADR-008), not a cache in front of a backend.
>   This file is kept as a placeholder (rather than deleted from disk) because the toolchain used
>   to update these docs could not delete files directly in this pass — delete this file the next
>   time you have local file access; see `ADRs/README.md` for the up-to-date index, which already
>   excludes this ADR number from the active set.

---

## Why this ADR does not apply to ForgeApp

ForgeApp has no remote source to cache from or refresh against — the Drift database is the source of truth directly (ADR-008), not a cache in front of a backend.

See `Doc/SDS_v2.0.md` (System Design Specification) for ForgeApp's actual architecture, and
`ADRs/README.md` for the current active ADR index.

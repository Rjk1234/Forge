# ADR-029 Route Guard Strategy

Version: 2.0 (ForgeApp — Removed)

Status: Removed — Not Applicable to ForgeApp

---

> **Changelog**
> - **2.0 (2026-09-08):** Removed for ForgeApp. This ADR's decision solves a problem ForgeApp does
>   not have. ForgeApp needs only the single app-lock guard, which is fully specified in ADR-003 (Routing) directly — there is no backend permission check, workflow-prerequisite check, or deep-link entry point that would justify a separate multi-guard-chain ADR.
>   This file is kept as a placeholder (rather than deleted from disk) because the toolchain used
>   to update these docs could not delete files directly in this pass — delete this file the next
>   time you have local file access; see `ADRs/README.md` for the up-to-date index, which already
>   excludes this ADR number from the active set.

---

## Why this ADR does not apply to ForgeApp

ForgeApp needs only the single app-lock guard, which is fully specified in ADR-003 (Routing) directly — there is no backend permission check, workflow-prerequisite check, or deep-link entry point that would justify a separate multi-guard-chain ADR.

See `Doc/SDS_v2.0.md` (System Design Specification) for ForgeApp's actual architecture, and
`ADRs/README.md` for the current active ADR index.

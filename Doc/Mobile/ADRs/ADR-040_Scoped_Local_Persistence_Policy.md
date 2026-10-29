# ADR-040 Scoped Local Persistence Policy

Version: 2.0 (ForgeApp — Removed)

Status: Removed — Not Applicable to ForgeApp

---

> **Changelog**
> - **2.0 (2026-09-08):** Removed for ForgeApp. This ADR's decision solves a problem ForgeApp does
>   not have — it existed to carve out narrow exceptions to a normally-restrictive local-storage
>   policy. ForgeApp's ADR-008 has no such restriction — Drift is already the sole store for all
>   business data — so no exception carve-out is needed.
>   This file is kept as a placeholder (rather than deleted from disk) because the toolchain used
>   to update these docs could not delete files directly in this pass — delete this file the next
>   time you have local file access; see `ADRs/README.md` for the up-to-date index, which already
>   excludes this ADR number from the active set.

---

## Why this ADR does not apply to ForgeApp

This ADR existed to carve out narrow exceptions to a normally-restrictive local-storage policy.
ForgeApp's ADR-008 has no such restriction — Drift is already the sole store for all business data
— so no exception carve-out is needed.

See `Doc/SDS_v2.0.md` (System Design Specification) for ForgeApp's actual architecture, and
`ADRs/README.md` for the current active ADR index.

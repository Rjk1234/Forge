# ADR-025 Offline And Network Connectivity

Version: 2.0 (ForgeApp — Removed)

Status: Removed — Not Applicable to ForgeApp

---

> **Changelog**
> - **2.0 (2026-09-08):** Removed for ForgeApp. This ADR's decision solves a problem ForgeApp does
>   not have. ForgeApp has no connectivity concept at all — it is fully offline by design, not an online-first app with an offline fallback mode. SDS §2.3/§3.5 and `Doc/UserStories/SCR-27-Cross-Cutting-Global-States.md` already state this explicitly: the only local failure modes are Drift read/write failures (ADR-007), not connectivity loss.
>   This file is kept as a placeholder (rather than deleted from disk) because the toolchain used
>   to update these docs could not delete files directly in this pass — delete this file the next
>   time you have local file access; see `ADRs/README.md` for the up-to-date index, which already
>   excludes this ADR number from the active set.

---

## Why this ADR does not apply to ForgeApp

ForgeApp has no connectivity concept at all — it is fully offline by design, not an online-first app with an offline fallback mode. SDS §2.3/§3.5 and `Doc/UserStories/SCR-27-Cross-Cutting-Global-States.md` already state this explicitly: the only local failure modes are Drift read/write failures (ADR-007), not connectivity loss.

See `Doc/SDS_v2.0.md` (System Design Specification) for ForgeApp's actual architecture, and
`ADRs/README.md` for the current active ADR index.

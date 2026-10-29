# Mobile User & Role Matrix

## Single Local User

ForgeApp supports exactly one local user per device install. There are no roles, no permission
tiers, and no multi-account concept (SDS §2.3 Assumptions; `ADRs/ADR-011_Authorization.md` —
removed as not applicable).

**Feature Access:** The single local user has access to every feature in the app — static login,
profile, exercise catalogue, workout plans, scheduling, workout execution, history, progress, and
statistics. There is no feature gated behind a role or permission check beyond the app-lock state
itself (locked vs. unlocked).

If ForgeApp is ever extended to support multiple users or roles, this document — and
`ADRs/ADR-011_Authorization.md` — should be rewritten at that time against a real requirement, not
built speculatively now.

# Definition of Ready — ForgeApp

A feature is **Ready for Implementation** only when ALL items in this checklist are checked. A
feature that does not meet the Definition of Ready should not move to "In Progress," and coding
should not begin against an unready spec.

---

## Checklist

### 1. Specification (`spec.md`, where the feature has one)
- [ ] Problem statement clearly articulated — explains the gap against the SDS/User Story
- [ ] Proposed solution described at a high level
- [ ] Out-of-scope items explicitly listed
- [ ] User stories follow the format: `As a [user] / I want / So that`
      (`Doc/UserStories/` is the canonical source for these)
- [ ] Each user story has at least one **happy path** acceptance criterion in `Given/When/Then`
      format
- [ ] Each user story has at least one **failure/edge case** acceptance criterion
- [ ] Any open product decision (e.g. the Personal Best metric — SDS §3.5/Appendix F) is either
      resolved or explicitly still flagged open, never silently defaulted
- [ ] All dependencies identified — other features, data prerequisites
- [ ] All ambiguities resolved (no open `[NEEDS CLARIFICATION]` markers remain)
- [ ] Status set to `Approved` in the document header

### 2. Implementation Plan (`plan.md`, where the feature has one)
- [ ] Overview explains the technical approach clearly
- [ ] Feature module and layers affected (domain/data/application/presentation) listed
- [ ] New/modified classes documented (entities, repositories, use cases, Blocs, widgets)
- [ ] Navigation section complete: routes added/changed and the app-lock guard's interaction with
      them (ADR-003)
- [ ] Security Considerations section complete: input validation strategy described
      (`standards/security-standards.md`)
- [ ] Test strategy identifies which unit/widget/integration tests are needed

### 3. Security Review
- [ ] Security Considerations section reviewed against `standards/security-standards.md`
- [ ] No sensitive data (the static demo credential, personal data) present anywhere in spec
      documents in a form that could be mistaken for a real secret
- [ ] If the feature introduces a new third-party package — reviewed against
      `standards/security-standards.md` §8 and `ADRs/ADR-030_Dependency_Versioning_Governance.md`

### 4. Task Breakdown (`tasks.md`, where the feature has one)
- [ ] Tasks cover all phases relevant to the feature: Setup (if needed), domain → data →
      application → presentation → tests, Polish
- [ ] Task dependencies are clearly marked
- [ ] Each task has acceptance criteria
- [ ] No single task exceeds one day of effort (larger tasks are broken down further)

### 5. Cross-Cutting Concerns
- [ ] Feature status updated to `Approved` in `spec.md` header, where one exists

---

## Sign-Off Requirements

This is a single-developer project. The developer signs off on both `spec.md` and
`plan.md`/`tasks.md` by completing this checklist — there is no separate Product Manager / Tech
Lead role to route approval through.

---

## Ready vs. Not Ready — Examples

### Ready
> "Workout Execution has a complete spec.md with happy-path and error-path acceptance criteria,
> aligned with SDS-COMP-7 and the User Stories. plan.md identifies the Bloc, use cases, and Drift
> repository changes needed. Tasks are broken down and each is under a day. Status is Approved."

### Not Ready
> "Personal Bests has a spec.md but the metric definition is still open (SDS §3.5, Decision #1) and
> plan.md has not been written." — **Do not start implementation; resolve the open decision first.**

---

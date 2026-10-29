# ForgeApp Feature Input Template

> **Status**: Approved | **Version**: 2.0 (ForgeApp) | **Last updated**: 2026-09-08
> **Owner**: ForgeApp (single developer)

Use this values block as input to [`specify-feature.md`](specify-feature.md). It selects one
feature and its source material within this project. It does not invoke or choose a workflow on
its own.

Copy the block into the `COMPLETED FORGEAPP FEATURE SDD RUN VALUES` section of the reusable
specify prompt and replace values in angle brackets.

```text
FEATURE_TITLE: <short human-readable feature title>
USER_STORY_REF: <the User Story folder/file this feature implements, e.g. Doc/UserStories/US-012-workout-execution.md>
SOURCE_DISCOVERY_MODE: MANUAL
SDS_INPUT_PATH: Doc/SDS_v2.0.md
USER_STORY_INPUT_PATH: <path under Doc/UserStories/>
DESIGN_SYSTEM_INPUT_PATH: Doc/DESIGN-SYSTEM.md
ADDITIONAL_INPUT_PATHS: NONE
FEATURE_DIRECTORY: AUTO
CHANGE_CATEGORY: Functional Change
IMPLEMENTATION_REQUESTED: NO
```

## Field guidance

- `USER_STORY_REF` must point at the actual file/folder under `Doc/UserStories/` this feature
  implements.
- `SOURCE_DISCOVERY_MODE: MANUAL` reflects that ForgeApp is a single project with no separate
  external corpus to auto-discover by story ID — you name the input paths directly.
- `SDS_INPUT_PATH` is always `Doc/SDS_v2.0.md` unless a feature genuinely needs a narrower or
  additional design reference.
- `ADDITIONAL_INPUT_PATHS` is `NONE` or a comma-separated list of explicitly relevant paths (for
  example a specific ADR).
- Use `FEATURE_DIRECTORY: AUTO` for a new feature. The specify workflow derives
  `specs/<short-feature-slug>` — a short, readable slug is fine, e.g. `specs/workout-execution`.
- For an existing feature refresh, supply its exact project-relative directory, for example:

  ```text
  FEATURE_DIRECTORY: specs/workout-execution
  ```

- `CHANGE_CATEGORY` must reflect the change type used by the review gates in
  `governance/review-gate-framework.md`.
- `IMPLEMENTATION_REQUESTED` is traceability metadata for the SDD run. Code changes still require
  the separate explicit authorization in `implement-feature.md` after G-03 genuinely passes.

## Path and source rules

- Resolve paths from the project root (`Doc/Mobile/..` i.e. the ForgeApp project root, or
  wherever this doc set is copied into the final repo).
- Persist only portable, project-relative paths such as `Doc/SDS_v2.0.md`, `Doc/UserStories/...`,
  and `specs/...`.
- Never persist machine-specific absolute paths, usernames, home-directory prefixes, or `file://`
  URIs.
- Never modify `Doc/SDS_v2.0.md`, `Doc/UserStories/`, or `Doc/DESIGN-SYSTEM.md` from a feature
  workflow — those are read as source authority, not edited by it.
- A missing or ambiguous reference remains a declared dependency gap; it is not permission to
  invent content.

After completing this input, begin with `prompts/specify-feature.md` and then follow the approved
standalone sequence in [`README.md`](README.md).

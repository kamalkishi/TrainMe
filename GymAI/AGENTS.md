
# GymAI Agent Instructions

## 1. Product Mission

GymAI is a commercial-quality, AI-assisted fitness coaching application for
iOS, macOS, and visionOS.

The product will progressively support:

* Workout planning and execution
* Workout history and progress tracking
* Camera-based pose estimation
* Exercise repetition counting
* Live posture and form correction
* Red, orange, and green pose-quality feedback
* Personalized AI coaching
* Long-term fitness recommendations
* Multilingual user interfaces

Treat every implementation as production software, not as tutorial,
demonstration, or prototype code.

## 2. Sources of Truth

Before reviewing, proposing, or implementing changes, read the relevant parts
of:

1. `PRODUCT.md`
2. `ARCHITECTURE.md`
3. This `AGENTS.md`
4. The current source files involved in the requested feature
5. Existing tests for the affected behavior
6. Current Git status and diff

The checked-out repository is the source of truth for code.

Never assume that a file, symbol, method, folder, dependency, test target, or
implementation exists. Search and inspect before referring to it.

Historical descriptions, chat summaries, task prompts, and documentation may
be stale. When they conflict with the current source code, report the
difference explicitly before making changes.

If something cannot be verified from the repository or build environment,
state exactly what could not be verified.

## 3. Architecture Rules

The established architecture is frozen unless a change is demonstrably
necessary.

Prefer additive, focused changes over broad restructuring.

Current architectural boundaries:

* `App/` owns application entry and root application flow.
* `Core/` contains shared infrastructure, navigation, state, theme,
  persistence, utilities, resources, and reusable global components.
* `Features/` contains feature-specific models, views, view models, services,
  and components.
* Domain models remain independent from SwiftData entities.
* `WorkoutRepository` remains the orchestration boundary used by application
  features.
* `WorkoutPersistence` owns SwiftData reads and writes.
* Mapping code owns domain-to-entity and entity-to-domain conversion.
* Feature-specific user interface components remain inside their feature.
* Only genuinely reusable components belong in `Core/Components`.
* Localization uses `Localizable.xcstrings`.
* Do not introduce a custom localization wrapper without explicit approval.
* Do not introduce a dependency-injection framework or new DI layer unless the
  existing architecture can no longer satisfy a verified requirement.
* Do not duplicate repositories, persistence services, entities, domain
  models, navigation systems, or state owners.

Before introducing a new type, search for an existing type serving the same or
a closely related responsibility.

Any proposed architectural change must include:

* The verified problem
* Evidence from current code
* Alternatives considered
* Migration impact
* Persistence and data-loss risk
* Test impact
* Why a smaller change is insufficient

Do not perform architectural changes without explicit user approval.

## 4. Supported Environment

The current development environment is:

* Apple Silicon Mac
* Xcode 26.6
* macOS Tahoe 26.5
* SwiftUI
* Observation framework
* SwiftData
* iOS deployment target 26.5
* macOS deployment target 26.5
* visionOS deployment target 26.5

Do not silently change:

* Deployment targets
* Swift language mode
* Bundle identifiers
* Signing configuration
* Entitlements
* Build settings
* Supported platforms
* Package versions
* Project or scheme names

Any necessary project-setting change requires an explanation and explicit
approval.

## 5. Mandatory Task Workflow

For every task, follow this sequence.

### Phase A — Inspect

Before modifying files:

1. Run or inspect `git status`.
2. Identify the repository root.
3. Inspect the relevant files and related tests.
4. Search for existing implementations and call sites.
5. Identify the current data and control flow.
6. Check for uncommitted changes.
7. Determine the relevant Xcode project, schemes, targets, and destinations.
8. Explain the verified current implementation.

Do not edit during the inspection phase when the user requested review or
planning only.

### Phase B — Plan

Propose one focused, coherent change.

The plan must state:

* Intended behavior
* Files expected to change
* Files inspected but not expected to change
* Data-model or persistence implications
* Test coverage to add or update
* Build destinations to verify
* Known risks
* Acceptance criteria

Do not include unrelated cleanup.

Wait for explicit approval before modifying files unless the user clearly asked
for immediate implementation.

### Phase C — Implement

After approval:

* Make the smallest complete change that satisfies the acceptance criteria.
* Preserve existing public APIs unless a verified requirement demands a change.
* Follow existing naming and formatting conventions.
* Avoid speculative abstractions.
* Avoid unrelated renaming or reformatting.
* Do not replace a working implementation merely because another style is
  preferred.
* Do not modify generated files manually.
* Do not suppress compiler warnings or errors without resolving their cause.
* Do not remove behavior unless explicitly approved.
* Do not delete user data or introduce a destructive migration without explicit
  approval.

### Phase D — Validate

After implementation:

1. Inspect the complete Git diff.
2. Build every affected target that is available locally.
3. Run all relevant automated tests.
4. Add regression tests for corrected defects.
5. Verify persistence behavior when persistence code changes.
6. Verify navigation and state transitions when application flow changes.
7. Check supported-platform compilation where practical.
8. Report warnings separately from errors.
9. Report anything not tested or not available.

Never claim success based only on code inspection.

Use these distinct verification labels accurately:

* **Source reviewed**
* **Diff reviewed**
* **Compiled successfully**
* **Unit tests passed**
* **UI tests passed**
* **Simulator flow verified**
* **Physical-device flow verified**
* **Not verified**

### Phase E — Report

Every implementation report must include:

* Summary of behavior delivered
* Exact files changed
* Important implementation decisions
* Build command or Xcode action used
* Build result
* Tests executed and results
* Manual flow verification performed
* Known limitations or remaining risks
* Git working-tree status
* Suggested commit message

Do not commit, push, merge, reset, clean, discard, or force-update Git history
unless explicitly instructed.

## 6. Git Safety

At the start of every task, protect existing work.

* Never overwrite uncommitted user changes.
* Never assume an untracked file is disposable.
* Never run destructive Git commands without explicit approval.
* Never use `git reset --hard`.
* Never use `git clean`.
* Never force-push.
* Never amend an existing commit unless instructed.
* Never modify `main` directly for a substantial feature when a feature branch
  is appropriate.
* Keep each task focused enough to review and revert independently.
* Review `git diff --check` and the complete diff before declaring completion.

When pre-existing changes overlap with the requested work, stop editing the
affected file and report the conflict.

## 7. Swift and SwiftUI Standards

* Prefer clear Swift over clever or compressed Swift.
* Follow existing Observation and state-management patterns.
* Keep UI state ownership explicit.
* Avoid duplicate sources of truth.
* Keep business logic out of SwiftUI view bodies.
* Keep persistence operations out of views.
* Use safe collection indexing and handle empty collections.
* Avoid force unwraps and forced casts.
* Avoid `try!`.
* Handle thrown errors or deliberately propagate them.
* Respect actor isolation and main-thread requirements.
* Use `@MainActor` where UI-owned mutable state requires it.
* Do not introduce detached tasks without a documented reason.
* Ensure asynchronous work handles cancellation where relevant.
* Avoid retaining view models or services unintentionally.
* Keep platform-specific APIs behind explicit availability or conditional
  compilation checks.
* Preserve accessibility labels and Dynamic Type compatibility.
* Use semantic colors rather than platform-incompatible UIKit-only colors.
* Keep strings localizable; do not hard-code new user-facing copy when a String
  Catalog key is appropriate.

## 8. SwiftData and Persistence Standards

Persistence changes require particular caution.

Before modifying persistence:

* Inspect every related entity.
* Inspect model-container registration.
* Inspect repository calls.
* Inspect mapping code.
* Inspect save, load, resume, completion, history, and deletion paths.
* Search for all entity initializers and fetch descriptors.

Persistence requirements:

* Keep domain models separate from SwiftData entities.
* Avoid storing UI-specific state unless required for session restoration.
* Preserve stable identifiers.
* Prevent accidental duplicate entities.
* Treat relationship deletion behavior explicitly.
* Handle missing or corrupted records safely.
* Keep write operations transactional where practical.
* Save only after a coherent state update.
* Do not silently discard persistence errors.
* Do not introduce schema-breaking changes without migration analysis.
* Do not infer migration safety merely because the project compiles.

For workout lifecycle work, verify the complete flow:

1. Start a session
2. Persist the initial session
3. Update workout progress
4. Save resumable state
5. Reload an active session
6. Complete the session
7. Create or expose workout history
8. Prevent an already completed session from appearing active
9. Avoid duplicate history records
10. Preserve data across app relaunch

Automated tests should cover this flow before persistence is considered
complete.

## 9. Navigation and Full-Flow Requirements

A feature is not complete merely because its isolated screen builds.

For user-facing features, inspect and test:

* Entry point
* Navigation destination
* Required state
* Loading state
* Empty state
* Error state
* Success state
* Back navigation
* App relaunch behavior where persistence is involved
* Accessibility behavior
* Localization readiness
* Platform-specific presentation differences

For workout functionality, verify the expected user journey from workout
selection through workout completion and history visibility.

Do not create unreachable screens.

## 10. Testing Requirements

Use the existing test framework and test targets where available.

If tests are missing for changed business logic, create appropriate tests rather
than relying solely on manual verification.

Prioritize tests for:

* Domain-model invariants
* Workout progression
* Set and exercise advancement
* Completion conditions
* Repository orchestration
* Domain/entity mapping
* SwiftData save and fetch behavior
* Active-session restoration
* Workout-history generation
* Duplicate prevention
* Error handling
* Navigation state where testable
* Regression scenarios

Tests must:

* Be deterministic
* Avoid shared persistent state
* Use isolated in-memory stores when testing SwiftData
* Describe behavior rather than implementation details
* Include meaningful failure messages where useful
* Cover edge cases and invalid state
* Avoid arbitrary delays
* Avoid being weakened or deleted merely to pass

A compilation-only check does not count as test coverage.

## 11. Code Review Standard

Review changed code for:

### Critical issues

* Crash risks
* Data loss
* Broken persistence
* Incorrect session restoration
* Security or privacy violations
* Destructive migrations
* Broken primary user flows

### High-priority issues

* Incorrect state ownership
* Duplicate sources of truth
* Concurrency violations
* Invalid navigation behavior
* Incorrect mappings
* Incomplete error handling
* Platform compilation failures
* Regressions in existing behavior

### Maintainability issues

* Duplicate architecture
* Unnecessary abstractions
* Unreachable or unused code
* Misleading names
* Excessively coupled types
* Missing tests
* Hard-coded user-facing strings
* Unfocused changes

Review findings should include:

* Severity
* File and symbol
* Concrete failure scenario
* Why it matters
* Minimal recommended correction

Do not report stylistic preferences as defects unless they violate an established
project convention or create a material maintenance risk.

## 12. UI and Product Quality

New user-facing work should be:

* Clear to a general fitness user
* Consistent with the existing visual system
* Accessible
* Localizable
* Responsive across supported layouts
* Honest about unavailable or incomplete AI capabilities
* Designed for error recovery
* Free of placeholder behavior in production paths

Do not present simulated, hard-coded, or inferred fitness measurements as
actual sensor-derived results.

Camera, pose, health, biometric, and fitness data require explicit privacy and
permission handling before production use.

## 13. Scope Control

Do not attempt to complete multiple roadmap versions in one task.

Each task must have explicit acceptance criteria and a reviewable diff.

When discovering unrelated defects:

* Record them separately.
* Explain their impact.
* Do not fix them as part of the current change unless they block the approved
  task or the user approves the expanded scope.

When the requested change is too broad, first produce a staged implementation
plan divided into independently buildable and testable increments.

## 14. Communication Rules

Be precise and evidence-based.

* Mention exact paths and symbols.
* Clearly separate facts from recommendations.
* Do not claim to have opened, built, tested, or reviewed something unless it
  was actually done.
* Do not fabricate command results.
* Do not hide failures.
* Include complete relevant compiler or test failures.
* Explicitly identify assumptions.
* Prefer a smaller verified result over a broad unverified claim.
* When uncertain, inspect further rather than guessing.

## 15. Definition of Done

A task is complete only when:

* Approved acceptance criteria are satisfied.
* Relevant source was inspected.
* The implementation diff was reviewed.
* Affected targets compile.
* Relevant automated tests pass.
* Required user flow was verified to the extent possible.
* No unexplained errors or warnings were introduced.
* No unrelated files were changed.
* Documentation was updated when behavior or architecture changed.
* Remaining limitations were reported honestly.
* The working tree is understood and ready for user review.

Do not describe a task as complete when any required validation step remains
unperformed. Use “implemented but not verified” instead.

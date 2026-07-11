# GymAI Architecture Decisions

## AD-001 - Modular Feature Architecture

Status: Accepted

Decision:
Use Feature-based architecture with shared Core components.

Rationale:
Keeps features independent while allowing reusable UI, styling,
extensions and utilities.

---

## AD-002 - Native SwiftUI Localization

Status: Accepted

Decision:
Use Xcode String Catalogs (.xcstrings) with LocalizedStringKey.

Rationale:
Native Apple solution.
Supports plurals, placeholders, RTL languages and future expansion.
Avoid custom localization wrappers unless dynamic formatting requires them.

---

## AD-003 - One Build at a Time

Status: Accepted

Decision:
Only one logical change per build.
Commit only after a stable milestone.

Rationale:
Reduces regression risk and makes Git history clean.

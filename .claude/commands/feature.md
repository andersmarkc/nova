# /feature

Scaffold a complete new feature following Nova standards.

## Argument

Feature name and brief description. Example: `/feature product search`

## Steps

1. Read @docs/DOMAIN.md — does this touch existing domain models?
2. Read @docs/ARCHITECTURE.md — correct directory placement and patterns
3. Read @docs/PULSAR_API.md — which Pulsar endpoints are involved?
4. **Enter plan mode before writing any code.** For any feature touching more than 3 files, planning is mandatory.
5. List every file to be created or modified. Show the plan. **Wait for explicit approval before writing a single line of code.**
6. Implement in this order:
   a. Models (Codable structs in `Nova/Models/`)
   b. API service methods (in `Nova/Services/API/`)
   c. Repository / local persistence (if offline support needed)
   d. ViewModel (`@MainActor @Observable class` in `Nova/ViewModels/`)
   e. Views (SwiftUI in `Nova/Views/`)
   f. Localized strings in `Localizable.xcstrings` (da + en)
   g. Tests for every model, service, and view model created
7. Run `/ci`
8. If any mistakes were made, add rules to @lessons.md immediately.

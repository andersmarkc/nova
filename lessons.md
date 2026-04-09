# Lessons

Rules learned from mistakes. Updated after every mistake. Never deleted.
Add a new entry immediately when something goes wrong — before moving on.

---

## Template

```
### [short description of the mistake]
**What happened:** One sentence describing what went wrong.
**Rule:** Never do X. Always do Y instead.
```

---

## Seeded rules (known gotchas for this stack)

### Real Pulsar API: ProductVariant.id is Int, not String
**What happened:** Fixture used `"id": "pv_1"` (string) but real API returns `"id": 3734` (integer). Search hits use string IDs from Typesense, but item variant IDs are integers from PostgreSQL.
**Rule:** Always verify fixture JSON against the real API before committing. SearchHit.id is String (Typesense), ProductVariant.id is Int (PostgreSQL).

### Real Pulsar API: variant_attributes has mixed value types
**What happened:** Fixture used `[String: String]` for variant_attributes, but real API returns `{"organic": true, "section": "text", "fat_percentage": 0.1}` — a mix of Bool, String, and Double values.
**Rule:** Use `AnyCodableValue` enum for JSON fields with mixed value types. Never assume all values are the same type.

### Real Pulsar API: price amounts are JSON numbers, not strings
**What happened:** lessons.md said "DKK prices are decimal strings in JSON" but the real API returns `"amount": 12.95` (number), not `"amount": "12.95"` (string). Our `decodeDecimalFromString` helper handles both, which is correct.
**Rule:** Keep the flexible decoder that handles both string and number Decimals. The API may change serialization.

### Real Pulsar API: suggestions endpoint returns 500
**What happened:** `GET /api/v1/search/suggestions?q=mae` returns a 500 error on production. This is a Pulsar server bug, not a Nova issue.
**Rule:** Document Pulsar API bugs found during real testing. This needs to be fixed in Pulsar.

### Xcode warnings must be zero before committing
**What happened:** Committed code with 4 Xcode warnings about MainActor isolation that were not caught because the CI workflow only checked for build success and test passes, not warnings.
**Rule:** Always check for Xcode warnings after building: `xcodebuild build 2>&1 | grep 'warning:' | grep -v 'appintentsmetadataprocessor'`. Treat warnings as errors. The `/ci` command includes this check.

### Pulsar API uses snake_case JSON keys
**What happened:** Anticipated from reading the Pulsar codebase (Alba serializer, Rails conventions).
**Rule:** Every Codable model must define explicit `CodingKeys` mapping snake_case to camelCase. Set `decoder.keyDecodingStrategy = .convertFromSnakeCase` on the shared JSONDecoder as the default, but still define explicit CodingKeys for clarity and to catch mismatches.

### DKK prices are decimal strings in JSON
**What happened:** Pulsar's Orion::Price stores `amount` as `decimal(8,2)` in PostgreSQL. Alba serializes this as a JSON string `"12.95"`, not a number.
**Rule:** Decode price fields as `Decimal` using a custom decoder or string-to-Decimal conversion. Never use `Double` for money.

### Pulsar rate limits search more aggressively
**What happened:** Known from Pulsar's rack-attack config: search is 60 req/min vs 200 req/min for other endpoints.
**Rule:** Debounce search input (300ms minimum). Show cached results while waiting. Handle 429 gracefully with exponential backoff.

### .pbxproj must never be edited manually
**What happened:** Known Xcode best practice. Manual edits cause merge conflicts and project corruption.
**Rule:** Never edit `project.pbxproj` by hand. Add files through Xcode or use file system synchronized groups (Xcode 16+).

### No non-Swift files inside Nova/ source directory
**What happened:** Xcode's PBXFileSystemSynchronizedRootGroup auto-syncs everything in `Nova/` into the app bundle. Placing CLAUDE.md files in `Nova/Models/`, `Nova/Services/`, `Nova/Views/` caused "Multiple commands produce CLAUDE.md" build errors because three files with the same name got copied to the same bundle path.
**Rule:** Never place non-Swift files (CLAUDE.md, .md, .txt) inside the `Nova/` source directory. Use `.claude/rules/` with `paths:` frontmatter for path-scoped Claude instructions instead of nested CLAUDE.md files.

### Swift 6 test files need explicit Foundation import
**What happened:** Test files using `#expect` with Foundation types (URL.scheme, URL.host, URL.absoluteString) failed with "not available due to missing import of defining module 'Foundation'" even though `@testable import Nova` was present.
**Rule:** Always add `import Foundation` to test files that reference Foundation types in `#expect` macros. Swift 6's `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY` requires explicit imports.

### All Codable models and service types need nonisolated
**What happened:** Project has `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, which makes all types implicitly `@MainActor`. Codable structs and service classes that need to work across actors (e.g., decoded in URLSession's background, used in `Sendable` generics) failed with "main actor-isolated conformance cannot satisfy conformance requirement for Sendable type parameter."
**Rule:** Always prefix Codable model structs, service classes, enums, and other non-UI types with `nonisolated`. Only ViewModels should be `@MainActor` (which they get implicitly). Example: `nonisolated struct Price: Decodable, Sendable { ... }`

### Swift Testing suites using MockURLProtocol must be .serialized
**What happened:** APIClient tests failed with 1-second timeouts because Swift Testing runs tests in parallel by default. The shared static `MockURLProtocol.requestHandler` was being overwritten by concurrent tests.
**Rule:** Always add `.serialized` to any `@Suite` that uses `MockURLProtocol`. Example: `@Suite("APIClient", .serialized)`.

### Simulator name must match installed Xcode version
**What happened:** Build commands referenced "iPhone 16" but the installed Xcode 26 only has iPhone 17 series simulators.
**Rule:** Use `iPhone 17 Pro` as the default simulator destination. Check available simulators with `xcrun simctl list devices available` if builds fail with destination errors.

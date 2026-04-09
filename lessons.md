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

### Simulator name must match installed Xcode version
**What happened:** Build commands referenced "iPhone 16" but the installed Xcode 26 only has iPhone 17 series simulators.
**Rule:** Use `iPhone 17 Pro` as the default simulator destination. Check available simulators with `xcrun simctl list devices available` if builds fail with destination errors.

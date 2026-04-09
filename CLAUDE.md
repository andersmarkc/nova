# Nova

Danish grocery shopping list app for iOS. SwiftUI front-end for the Pulsar API.

Run `/start` at the beginning of every session before writing any code.

---

## Quick reference

| What | Where |
|---|---|
| What we're building, current phase | @docs/PROJECT.md |
| Business concepts + data model | @docs/DOMAIN.md |
| Directory structure + patterns | @docs/ARCHITECTURE.md |
| Visual design + component rules | @docs/STYLE_GUIDE.md |
| Testing patterns + mocking | @docs/TESTING.md |
| Pulsar API reference | @docs/PULSAR_API.md |
| Future items + deferred decisions | @docs/BACKLOG.md |
| Mistakes already made | @lessons.md |

Path-scoped rules in `.claude/rules/` load automatically when you work on matching files:
- `services.md` — networking, API client, no third-party HTTP libraries
- `models.md` — data model rules, Codable patterns
- `views.md` — SwiftUI component patterns, accessibility

---

## Commands

```bash
# Build
xcodebuild -scheme Nova -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -20

# Test
xcodebuild -scheme Nova -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test 2>&1 | tail -40

# Lint
swiftlint --config .swiftlint.yml
swiftlint --fix --config .swiftlint.yml
```

---

## Stack

- **iOS 26.1** — deployment target. SwiftUI only, no UIKit unless absolutely required.
- **Swift 6.0** — strict concurrency. `@MainActor` on all view models.
- **SwiftUI + @Observable** — MVVM. No Combine, no ObservableObject, no @Published.
- **Swift Testing** — `import Testing`, `@Test`, `#expect`. No XCTest for unit tests.
- **URLSession** — all networking. No Alamofire, no third-party HTTP libraries.
- **SwiftData** — offline persistence for shopping lists and cached searches.
- **Swift Package Manager** — dependencies via Xcode. No CocoaPods, no Carthage.

---

## Hard rules (universal — apply everywhere)

- Build must succeed with zero warnings after every task. Xcode warnings are bugs — fix them before committing.
- No UIKit. SwiftUI only. If a SwiftUI API gap is found, document it in lessons.md and discuss before importing UIKit.
- No third-party HTTP library. All networking goes through `APIClient` using URLSession.
- No Combine. Use `@Observable` macro, async/await, and AsyncSequence.
- No hardcoded user-facing strings. All text uses `String(localized:)` with Localizable.xcstrings. Danish (`da`) is the primary locale, English (`en`) is fallback.
- All money amounts are `Decimal`. Never Float or Double for prices.
- Every view model is `@MainActor @Observable class`. Never a struct. Never ObservableObject.
- Every API response type conforms to `Codable` with explicit `CodingKeys` (Pulsar uses snake_case JSON).
- Never edit `.pbxproj` manually. Use Xcode or xcodebuild commands only.
- All images use SF Symbols where possible. Custom assets go in Assets.xcassets with dark mode variants.
- Accessibility: every interactive element needs an `accessibilityLabel`. Every image needs `accessibilityHidden(true)` or a label.

---

## Testing requirements

- Every view model must have a corresponding test file.
- Every API service method must be tested with mock URLProtocol responses.
- Tests use Swift Testing framework (`import Testing`, `@Test`, `#expect`).
- UI tests use XCTest (required by Xcode for UI testing).
- Mock all network calls. Zero real HTTP in tests. Use `MockURLProtocol`.

---

## Real API testing (after every new API method)

After implementing each new PulsarAPI method, verify it works against the real Pulsar API:

1. Start local Pulsar: `cd ~/RubymineProjects/pulsar && bin/dev`
2. Run integration tests: `PULSAR_INTEGRATION=1 xcodebuild -scheme Nova -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test -only-testing NovaTests 2>&1 | tail -40`
3. If real API behavior differs from fixture JSON, update fixtures and document in @lessons.md
4. Integration tests in `NovaTests/Integration/` are gated by `PULSAR_INTEGRATION` env var
5. Normal test runs use mocks only (fast, no network). Integration tests require explicit opt-in.

Base URL is in `Nova/Services/API/APIConfiguration.swift` — the single source of truth. Never hardcode the Pulsar URL anywhere else.

---

## When you make a mistake

Add a rule to @lessons.md immediately. Do not skip this step.

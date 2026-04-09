# Nova — Testing

## Frameworks

| Framework | Purpose |
|---|---|
| Swift Testing | Unit tests — models, view models, services |
| XCTest | UI tests only (required by Xcode for XCUIApplication) |

---

## Commands

```bash
# All tests
xcodebuild -scheme Nova -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test 2>&1 | tail -40
```

---

## Test Structure

Mirrors `Nova/` exactly.

```
NovaTests/
├── Models/
│   └── DecodingTests.swift            # Codable round-trip against fixture JSON
├── Services/
│   ├── APIClientTests.swift           # Base client: auth injection, error mapping, retry
│   ├── PulsarAPISearchTests.swift     # Search + suggestions
│   ├── PulsarAPIItemsTests.swift      # Item variants
│   ├── AuthManagerTests.swift         # Token refresh, keychain
│   └── MockURLProtocol.swift          # Shared mock for all API tests
├── ViewModels/
│   ├── SearchViewModelTests.swift
│   ├── ShoppingListViewModelTests.swift
│   └── ItemDetailViewModelTests.swift
└── Fixtures/
    ├── search_response.json           # Real Pulsar response shape
    ├── item_variants_response.json
    ├── shopping_lists_response.json
    └── error_401.json
```

---

## MockURLProtocol Pattern

All API tests use a custom URLProtocol subclass that intercepts requests and
returns pre-configured responses. Zero real HTTP in tests.

```swift
final class MockURLProtocol: URLProtocol {
    static var mockResponses: [URL: (Data, HTTPURLResponse)] = [:]

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let url = request.url,
              let (data, response) = Self.mockResponses[url] else {
            client?.urlProtocol(self, didFailWithError: URLError(.fileDoesNotExist))
            return
        }
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
```

---

## For Every New Feature

- **Model test** — Codable decode from fixture JSON, encode round-trip
- **Service test** — API call with MockURLProtocol, happy path + error paths (401, 404, 429)
- **ViewModel test** — state transitions (loading, loaded, error), with mock API
- **Preview** — every view has a `#Preview` with static data
- **UI test** — critical user flows only (search, add to list)

---

## Fixture JSON Rules

- Copy response shape from Pulsar (snake_case keys)
- Keep fixtures small — 2-3 items per collection
- Store in `NovaTests/Fixtures/` as `.json` files
- Load in tests via `Bundle(for: type(of: self)).url(forResource:withExtension:)`

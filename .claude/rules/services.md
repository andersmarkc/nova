---
paths:
  - "Nova/Services/**/*.swift"
---

# Services rules

## The two rules that matter most

### 1. No third-party HTTP libraries

All networking goes through `APIClient` using `URLSession`. No Alamofire, no Moya,
no third-party HTTP library. This mirrors the ecosystem's "no gem for APIs" philosophy.

### 2. All API calls go through PulsarAPI

Never call `APIClient` directly from a ViewModel. Always go through `PulsarAPI`
methods which provide typed request/response handling.

```swift
// WRONG — calling APIClient from a ViewModel
let data = try await APIClient.shared.request(endpoint)

// CORRECT — through PulsarAPI
let results = try await PulsarAPI.shared.search(query: "maelk")
```

## APIClient pattern

`APIClient` handles:
- Base URL configuration (per environment)
- JWT token injection via `AuthManager`
- Automatic token refresh on 401
- Rate limit handling (429 + Retry-After)
- JSON decoding with shared decoder configuration
- Error mapping to `APIError` enum

## Adding a new endpoint

1. Define the response model in `Models/API/`
2. Add an extension method on `PulsarAPI` in `PulsarAPI+{Feature}.swift`
3. Add fixture JSON in `NovaTests/Fixtures/`
4. Write test in `NovaTests/Services/`
5. Run `/ci`

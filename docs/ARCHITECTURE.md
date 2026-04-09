# Nova — Architecture

## Directory Structure

```
Nova/
├── NovaApp.swift                      # @main entry point, app-level DI
├── ContentView.swift                  # Root navigation (tab bar or auth gate)
├── Models/
│   ├── CLAUDE.md                      # Codable rules, CodingKeys, Decimal for money
│   ├── API/                           # Codable structs matching Pulsar JSON responses
│   │   ├── SearchResult.swift
│   │   ├── ProductVariant.swift
│   │   ├── Price.swift
│   │   ├── Shop.swift
│   │   ├── Item.swift
│   │   ├── ShoppingList.swift
│   │   ├── Family.swift
│   │   └── User.swift
│   └── Local/                         # SwiftData models for offline persistence
│       ├── CachedShoppingList.swift
│       └── CachedSearch.swift
├── Services/
│   ├── CLAUDE.md                      # Networking rules, no third-party HTTP
│   ├── API/
│   │   ├── APIClient.swift            # URLSession wrapper, base request, JWT injection
│   │   ├── APIError.swift             # Typed error enum
│   │   ├── APIEndpoint.swift          # Endpoint builder (path, method, query params)
│   │   ├── PulsarAPI.swift            # Main API namespace
│   │   ├── PulsarAPI+Auth.swift       # Login, refresh, logout
│   │   ├── PulsarAPI+Search.swift     # Search, suggestions
│   │   ├── PulsarAPI+Items.swift      # Item variants
│   │   ├── PulsarAPI+Lists.swift      # Shopping lists CRUD
│   │   ├── PulsarAPI+Family.swift     # Family management
│   │   ├── PulsarAPI+Prices.swift     # Price tracking watches
│   │   └── PulsarAPI+Push.swift       # Push token registration
│   ├── Auth/
│   │   ├── AuthManager.swift          # Token lifecycle, Keychain, refresh logic
│   │   └── KeychainService.swift      # Keychain read/write wrapper
│   └── Persistence/
│       ├── ShoppingListStore.swift    # SwiftData CRUD for offline lists
│       └── SearchCache.swift          # TTL-based search result cache
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── SearchViewModel.swift
│   ├── ItemDetailViewModel.swift
│   ├── ShoppingListViewModel.swift
│   ├── FamilyViewModel.swift
│   └── PriceWatchViewModel.swift
├── Views/
│   ├── CLAUDE.md                      # SwiftUI patterns, accessibility rules
│   ├── Auth/
│   │   └── LoginView.swift
│   ├── Search/
│   │   ├── SearchView.swift
│   │   ├── SearchResultRow.swift
│   │   └── SearchSuggestionView.swift
│   ├── Items/
│   │   ├── ItemDetailView.swift
│   │   └── VariantRow.swift
│   ├── Lists/
│   │   ├── ShoppingListView.swift
│   │   ├── ListItemRow.swift
│   │   └── AddItemSheet.swift
│   ├── Family/
│   │   ├── FamilyView.swift
│   │   └── InviteSheet.swift
│   ├── Prices/
│   │   └── PriceWatchView.swift
│   └── Components/
│       ├── PriceLabel.swift           # Formatted DKK price with sale styling
│       ├── ShopLogo.swift             # AsyncImage with fallback
│       ├── LoadingView.swift
│       └── ErrorView.swift
├── Extensions/
│   ├── Decimal+Currency.swift         # DKK formatting: "12,95 kr."
│   └── Date+Relative.swift           # Relative date strings in Danish
├── Resources/
│   ├── Localizable.xcstrings          # Danish (da) primary, English (en) fallback
│   └── Assets.xcassets/
└── Preview Content/
    └── PreviewData.swift              # Static preview data for SwiftUI previews

NovaTests/
├── Services/
│   ├── APIClientTests.swift
│   ├── PulsarAPISearchTests.swift
│   └── MockURLProtocol.swift          # Reusable mock for all API tests
├── ViewModels/
│   ├── SearchViewModelTests.swift
│   └── ShoppingListViewModelTests.swift
├── Models/
│   └── DecodingTests.swift            # Round-trip Codable tests against fixture JSON
└── Fixtures/
    ├── search_response.json
    ├── item_variants_response.json
    └── shopping_lists_response.json

NovaUITests/
├── NovaUITests.swift
└── NovaUITestsLaunchTests.swift
```

---

## Patterns

### MVVM with @Observable

```swift
// ViewModel — always @MainActor, always @Observable class
@MainActor
@Observable
final class SearchViewModel {
    var query = ""
    var results: [SearchResult] = []
    var isLoading = false
    var error: APIError?

    private let api: PulsarAPI

    init(api: PulsarAPI = .shared) {
        self.api = api
    }

    func search() async {
        isLoading = true
        defer { isLoading = false }
        do {
            results = try await api.search(query: query)
        } catch let apiError as APIError {
            error = apiError
        } catch {
            self.error = .unknown(error)
        }
    }
}
```

### API Client Pattern

```swift
// All networking flows through this one class
final class APIClient: Sendable {
    static let shared = APIClient()
    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func requestVoid(_ endpoint: APIEndpoint) async throws
}
```

### Dependency Injection

ViewModels receive dependencies via init. In production, use `.shared` singletons.
In tests, inject mocks.

```swift
// Production
SearchView(viewModel: SearchViewModel())

// Test
let mockAPI = MockPulsarAPI()
let vm = SearchViewModel(api: mockAPI)
```

### Error Handling

```swift
enum APIError: Error, LocalizedError {
    case unauthorized          // 401 — trigger token refresh or logout
    case notFound              // 404
    case rateLimited(retryAfter: Int)  // 429
    case serverError(Int)      // 5xx
    case networkError(Error)   // URLSession errors
    case decodingError(Error)  // JSON decode failure
    case unknown(Error)

    var errorDescription: String? { ... }  // Localized Danish strings
}
```

### Offline-First Shopping Lists

Shopping lists use SwiftData for local persistence and sync to Pulsar API
when network is available. Conflict resolution: last-write-wins with timestamps.

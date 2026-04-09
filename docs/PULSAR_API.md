# Nova — Pulsar API Reference

Base URL: configured per environment. JWT Bearer token in Authorization header.

---

## Authentication

JWT tokens use HS256. Payload contains `sub` (user ID) and `jti` (token ID).
Pulsar checks a Redis denylist for revoked tokens.

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/v1/auth/dev_token` | POST | Dev-only: get a JWT for testing |

Production auth flow: Apple/Google Sign In -> exchange for Pulsar JWT (endpoint TBD).

---

## Search

| Endpoint | Method | Rate Limit | Purpose |
|---|---|---|---|
| `/api/v1/search?q=&shop_ids=&on_sale=&sort=&page=&per_page=` | GET | 60/min | Product search via Typesense |
| `/api/v1/search/suggestions?q=` | GET | 60/min | Search autocomplete |

### Search Parameters
- `q` — search query string (required)
- `shop_ids` — comma-separated shop IDs to filter
- `on_sale` — `1` or `true` to filter sale items only
- `item_id` — filter to variants of a specific item
- `sort` — `price_asc` or `price_desc`
- `page` — page number (default: 1)
- `per_page` — results per page (1-100, default: 20)

### Search Response
```json
{
  "data": [
    {
      "id": 42,
      "name": "Arla Letmaelk 1L",
      "brand": "Arla",
      "shop": { "id": 1, "name": "Netto" },
      "price": { "amount": "12.95", "on_sale": false },
      "image_url": "https://..."
    }
  ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 142,
    "query": "maelk"
  }
}
```

---

## Items

| Endpoint | Method | Purpose |
|---|---|---|
| `/api/v1/items/:id/variants` | GET | All variants + prices for an item |

### Variants Response
Returns item info, attribute definitions (for variant matrix), and all active
variants with their current prices across shops.

---

## Rate Limits

- General API: 200 req/min per user
- Search: 60 req/min per user
- Unauthenticated: 30 req/min per IP

When rate limited, Pulsar returns 429. Check `Retry-After` header.

---

## Planned Endpoints (not yet built in Pulsar)

These endpoints are designed in the Pulsar data model but controllers are not yet built.
Nova should be designed to call them. Pulsar will be built to match.

### Auth
| Endpoint | Method | Purpose |
|---|---|---|
| `/api/v1/auth/apple` | POST | Exchange Apple Sign In token for JWT |
| `/api/v1/auth/google` | POST | Exchange Google Sign In token for JWT |
| `/api/v1/auth/refresh` | POST | Refresh JWT using refresh token |
| `/api/v1/auth/logout` | DELETE | Revoke refresh token + denylist JWT |

### Shopping Lists
| Endpoint | Method | Purpose |
|---|---|---|
| `/api/v1/lists` | GET | User's family shopping lists |
| `/api/v1/lists` | POST | Create shopping list |
| `/api/v1/lists/:id` | PATCH | Update list (rename, archive) |
| `/api/v1/lists/:id` | DELETE | Delete list |
| `/api/v1/lists/:id/items` | GET | Items in a list |
| `/api/v1/lists/:id/items` | POST | Add item to list |
| `/api/v1/lists/:id/items/:id` | PATCH | Update item (complete, reorder, change qty) |
| `/api/v1/lists/:id/items/:id` | DELETE | Remove item from list |

### Family
| Endpoint | Method | Purpose |
|---|---|---|
| `/api/v1/family` | GET | Current user's family |
| `/api/v1/family` | POST | Create family |
| `/api/v1/family/join` | POST | Join family via invite code |
| `/api/v1/family/members/:id` | DELETE | Remove family member (owner only) |

### Preferences & Fingerprints
| Endpoint | Method | Purpose |
|---|---|---|
| `/api/v1/preferences` | GET | User preferences |
| `/api/v1/preferences` | PATCH | Update preferences |
| `/api/v1/fingerprints/resolve` | POST | Resolve fingerprint for item |

### Price Tracking
| Endpoint | Method | Purpose |
|---|---|---|
| `/api/v1/watches` | GET | User's price watches |
| `/api/v1/watches` | POST | Create price watch |
| `/api/v1/watches/:id` | DELETE | Delete price watch |

### Push Notifications
| Endpoint | Method | Purpose |
|---|---|---|
| `/api/v1/push/tokens` | POST | Register APNS token |
| `/api/v1/push/tokens/:token` | DELETE | Unregister APNS token |

### Reference Data
| Endpoint | Method | Purpose |
|---|---|---|
| `/api/v1/shops` | GET | All active shops |

# Nova — Project Brief

> Read this at the start of every session. Tells you what we are building,
> where we are, and what to work on next.
>
> Business concepts + data model -> @docs/DOMAIN.md
> Technical structure + namespacing -> @docs/ARCHITECTURE.md
> Testing patterns -> @docs/TESTING.md
> Visual design -> @docs/STYLE_GUIDE.md
> Pulsar API -> @docs/PULSAR_API.md
> Mistakes to avoid -> @lessons.md

---

## What Nova Is

Nova is the iOS front-end for the Orion/Pulsar ecosystem — a Danish grocery shopping list app.
Users search 13+ Danish grocery retailers, compare prices, build shopping lists with smart
defaults (fingerprint system), share lists with family, and track price drops.

Nova talks exclusively to the Pulsar API (`/api/v1`). It never talks to Orion directly.

---

## Who We Are Building For

**Primary:** Danish families doing weekly grocery shopping. Age 25-55. Want the cheapest
option for their preferred brands across multiple stores.

**Secondary:** Budget-conscious singles. Price-sensitive students.

---

## Market

Denmark only. All UI in Danish (primary) with English fallback. Currency is always DKK.

---

## Tech Stack (Decided — Do Not Debate)

| Concern | Choice |
|---|---|
| Platform | iOS 26.1, SwiftUI |
| Language | Swift 6.0, strict concurrency |
| UI pattern | MVVM with @Observable |
| Networking | URLSession, async/await, no third-party HTTP libs |
| Persistence | SwiftData (offline shopping lists, cached search) |
| Auth | JWT (HS256) via Pulsar, tokens stored in Keychain |
| Search | Pulsar proxies Typesense — we just call the API |
| Push | APNS via Pulsar backend |
| Dependencies | Swift Package Manager only |
| Testing | Swift Testing (unit), XCTest (UI) |

---

## Current Phase: Phase 1 — Foundation

### Completed
- [x] Xcode project created (Hello World template)
- [x] Claude Code infrastructure (CLAUDE.md, settings, commands, docs)
- [x] Directory structure set up per ARCHITECTURE.md
- [x] SwiftLint configured (.swiftlint.yml)
- [x] APIClient base (URLSession wrapper, JWT auth, error handling)
- [x] APIConfiguration with base URL (single source of truth)
- [x] All API models (SearchHit, ProductVariant, Price, etc.) with Codable + Decimal
- [x] PulsarAPI methods (auth, search, suggestions, item variants)
- [x] KeychainService + AuthManager (token storage and lifecycle)
- [x] MockURLProtocol + 50 unit tests passing
- [x] Integration test infrastructure (gated by PULSAR_INTEGRATION env var)
- [x] Decimal+Currency extension (DKK formatting)

### Next Tasks (in order)
1. Create auth flow (Apple Sign In -> Pulsar JWT)
2. Create search screen (first real feature)
6. Create item detail / variants screen
7. Create shopping list feature
8. Create family sharing
9. Create price tracking watches
10. Push notification registration
11. Offline mode for shopping lists

---

## Phases Overview

| Phase | Focus | Status |
|---|---|---|
| 1 | Foundation: project structure, APIClient, auth | In Progress |
| 2 | Core: search, item detail, shopping lists | Not Started |
| 3 | Social: family sharing, collaborative lists | Not Started |
| 4 | Smart: fingerprint preferences, price tracking | Not Started |
| 5 | Polish: offline mode, push notifications, widgets | Not Started |

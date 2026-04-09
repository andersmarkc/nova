# Nova — Style Guide

## Brand Identity

**Name:** Nova
**Bundle ID:** dk.orion.Nova
**Personality:** Fast, clean, Scandinavian. A tool that disappears — the shopping list appears.

---

## Design Principles

1. **Speed first** — search results appear instantly, interactions feel immediate
2. **Scandinavian minimal** — generous whitespace, clean typography, no decoration
3. **Glanceable** — prices, sale badges, and list status visible without tapping
4. **One-handed** — bottom navigation, thumb-reachable actions
5. **Dark mode native** — equally good in light and dark

---

## Color System

Use semantic SwiftUI colors (adapt to light/dark automatically).

| Token | Light | Dark | Usage |
|---|---|---|---|
| `.accent` | Blue `#2563EB` | Blue `#3B82F6` | Primary actions, links, selected state |
| `.background` | System background | System background | Page background |
| `.secondaryBackground` | Secondary system bg | Secondary system bg | Cards, grouped sections |

### Status Colors
| Status | Color | Usage |
|---|---|---|
| Sale / discount | `.red` | Sale badge, discounted price |
| Completed | `.green` | Checked-off list item |
| Watching | `.orange` | Price watch active |
| Best price | `.green` | Cheapest variant highlight |

---

## Typography

Use system Dynamic Type throughout. No custom fonts.

| Style | Usage |
|---|---|
| `.title` | Screen titles |
| `.headline` | Product name, list name |
| `.subheadline` | Brand, shop name |
| `.body` | Descriptions, item text |
| `.callout` | Price labels |
| `.caption` | Timestamps, unit prices, metadata |

---

## Price Display

- Always DKK. Format: `12,95 kr.` (Danish decimal comma)
- Sale price: show original struck through, sale price in red
- Unit price: smaller caption below, e.g., `13,29 kr./L`
- Use `Decimal+Currency.swift` extension for all formatting

---

## Components

### PriceLabel
Shows formatted price. Red if on_sale. Strikethrough for original price.

### ShopLogo
AsyncImage loading shop logo_url. SF Symbol `cart.fill` as fallback.

### Sale Badge
Small red capsule with "Tilbud" (Danish for "offer/sale").

---

## Layout Patterns

- Tab bar navigation (Search, Lists, Family, Settings)
- List-based screens use SwiftUI `List` with `.listStyle(.insetGrouped)`
- Modal sheets for add/edit flows
- Pull-to-refresh on all data screens

---

## Accessibility

- Every interactive element: `accessibilityLabel`
- Every decorative image: `accessibilityHidden(true)`
- Price labels: read as natural Danish (e.g., "tolv kroner og femoghalvfems oere")
- Support Dynamic Type — never hardcode font sizes
- Minimum tap target: 44x44 points

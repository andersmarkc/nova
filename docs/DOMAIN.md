# Nova — Domain

## The Mental Model

Nova is a price comparison + shopping list app for Danish groceries. The data flows:

1. **Orion** scrapes 13+ Danish retailers, matches products, tracks prices
2. **Pulsar** receives synced data, adds user features (lists, families, fingerprints)
3. **Nova** (this app) is the iOS client that talks to Pulsar's `/api/v1`

Nova never talks to Orion. Nova never scrapes. Nova only consumes the Pulsar API.

---

## Core Concepts

### Shop
A grocery retailer. Read-only from Nova's perspective.
Examples: Netto, Foetex, Bilka, Rema 1000, Lidl, Aldi, MENY, Coop 365, Irma, Spar.

### Item
A generic product concept. "Maelk" (milk), "Rugbroed" (rye bread).
One item has many product variants across different shops.

### ProductVariant
A specific product: "Arla Letmaelk 1L" at a specific shop.
Has: name, brand, size, unit, EAN, image_url, variant_attributes (JSONB).

### Price
A price for a product variant at a shop. Has: amount (DKK), on_sale flag,
sales_price, unit_price, valid_from/until, promotion_text.

**All prices are in DKK. Always Decimal. Never Float.**

### User
Authenticated via Apple Sign In (apple_sub) or Google Sign In (google_sub).
Has a locale (default: "da"), belongs to a family (optional).

### Family
Group of users sharing shopping lists. Has: name, invite_code (8-char alphanumeric).
Owner is the creator. Members join via invite code.

### ShoppingList
Belongs to a family. Has: name, archived flag.
Contains ShoppingList::Items ordered by position.

### ShoppingList::Item
A line on a shopping list. Can be linked to an Item (structured) or just
raw_text (freeform, e.g., "3 bananer"). Has: quantity, unit, completed flag,
position, fingerprint (JSONB — saved preference snapshot).

### Fingerprint (User::ItemFingerprint)
Per-user preference for an item. Remembers which variant/shop the user last picked.
When adding an item to a list, the fingerprint is checked first to pre-select the
user's preferred variant. Updated each time the user makes a different choice.

### PriceTracking::Watch
User sets a target price for a product variant (optionally at a specific shop).
Pulsar sends a push notification when the price drops to or below the target.

### Push::Token
APNS device token registered with Pulsar. Platform: "ios".

### User::Preference
User settings: default_shop_ids (array), locale, max_stores_count,
dietary_settings (JSONB), prefer_organic flag.

---

## Data Ownership

| Data | Owner | Nova access |
|---|---|---|
| Shops, Items, Variants, Prices | Orion (via Pulsar sync) | Read-only via search + item detail |
| Users, Families | Pulsar | Read-write via auth + family API |
| Shopping Lists + Items | Pulsar | Read-write via lists API |
| Fingerprints | Pulsar | Read-write via fingerprint API |
| Price Watches | Pulsar | Read-write via watches API |
| Push Tokens | Pulsar | Write (register) via push API |

---

## Currency

All prices are DKK (Danish Krone). Display format: `12,95 kr.` (Danish locale).
Use `Decimal` for all price fields. The comma is the decimal separator in Danish.

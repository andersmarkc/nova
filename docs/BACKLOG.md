# Nova — Backlog

Future items and deferred decisions. Not in scope for current phase.

---

## Deferred Features

- [ ] Widgets (iOS WidgetKit) — shopping list widget, price alert widget
- [ ] Apple Watch companion — quick list view
- [ ] Siri Shortcuts — "Add milk to my list"
- [ ] Recipe import — paste URL, extract ingredients, add to list
- [ ] Store map / nearby stores — MapKit integration
- [ ] Barcode scanner — scan EAN to find product + prices
- [ ] iPad layout — sidebar navigation
- [ ] Spotlight integration — search products from home screen
- [ ] Share sheet — share list with non-family members
- [ ] In-app purchase — premium features (TBD)

---

## Deferred Technical Decisions

- **WebSocket for real-time list sync** — polling vs ActionCable. Defer until family sharing works.
- **Image caching library** — start with AsyncImage. Add Kingfisher/Nuke only if performance is poor.
- **Analytics** — no analytics in Phase 1. Evaluate TelemetryDeck or Aptabase later.
- **Crash reporting** — Sentry vs built-in MetricKit. Defer to Phase 3.
- **CI/CD** — Xcode Cloud vs Fastlane vs GitHub Actions. Decide at first App Store submission.

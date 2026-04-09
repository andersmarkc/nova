---
paths:
  - "Nova/Views/**/*.swift"
---

# Views rules

## SwiftUI only

No UIKit. No UIViewRepresentable unless there is no SwiftUI equivalent and you have
documented the gap in lessons.md.

## Every view must have a #Preview

```swift
#Preview {
    SearchResultRow(result: .preview)
}
```

Use static `.preview` properties on models for preview data.

## Accessibility is not optional

- Every interactive element: `.accessibilityLabel("descriptive text")`
- Every decorative image: `.accessibilityHidden(true)`
- Price labels: custom accessibility value that reads naturally in Danish
- Support Dynamic Type — never hardcode font sizes or frame heights
- Test with VoiceOver in Simulator

## Localization

- All user-facing strings: `String(localized: "key")`
- Never hardcode Danish text directly in views
- Danish is primary locale, English is fallback
- Pluralization: use stringsdict or String(localized:) with interpolation

## Component reuse

Shared components live in `Views/Components/`. Screen-specific views live in
their feature directory. A component moves to Components/ when used by 2+ screens.

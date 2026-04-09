# /ci

Run all checks and fix failures before proceeding.

## Steps

1. `swiftlint --fix --config .swiftlint.yml 2>&1` — auto-fix lint violations
2. `swiftlint --config .swiftlint.yml 2>&1` — must be zero violations
3. `xcodebuild -scheme Nova -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -20` — must compile clean
4. `xcodebuild -scheme Nova -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test 2>&1 | tail -40` — must be zero failures
5. Fix everything that fails. Do not proceed until all four checks pass.
6. Report: what passed, what needed fixing.

All four checks must pass before any commit. No exceptions.

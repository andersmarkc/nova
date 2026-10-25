# /ci

Run all checks and fix failures before proceeding.

## Steps

1. `swiftlint --fix --config .swiftlint.yml 2>&1` — auto-fix lint violations
2. `swiftlint --config .swiftlint.yml 2>&1` — must be zero violations
3. `xcodebuild -scheme Nova -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -20` — must compile clean
4. Check for Xcode warnings: `xcodebuild -scheme Nova -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | grep 'warning:' | grep -v 'appintentsmetadataprocessor'` — must be zero warnings from our code
5. `xcodebuild -scheme Nova -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test -only-testing NovaTests 2>&1 | tail -40` — must be zero failures
6. Fix everything that fails. Do not proceed until all five checks pass.
7. Report: what passed, what needed fixing.

All five checks must pass before any commit. No exceptions.

## Integration tests (optional, requires local Pulsar)

```bash
# Start Pulsar first: cd ~/RubymineProjects/billigst_apps/pulsar && bin/dev
PULSAR_INTEGRATION=1 xcodebuild -scheme Nova -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test -only-testing NovaTests 2>&1 | tail -40
```

Run integration tests after adding new PulsarAPI methods. Not required for every commit.

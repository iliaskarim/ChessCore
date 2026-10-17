# Bare `just` lists recipes.
set default-list := true

# Apply SwiftFormat and SwiftLint autocorrects.
lint:
    swiftformat .
    swiftlint lint --fix .

# Unit tests with an HTML coverage report. Matches `.github/workflows/codecov.yml`.
coverage:
    bash scripts/coverage

# SwiftLint analyze (`scripts/swiftlint-analyze`: clean build-for-testing + analyze).
analyze:
    bash scripts/swiftlint-analyze

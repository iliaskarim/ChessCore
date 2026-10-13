# Bare `just` lists recipes.
set default-list := true

# SwiftFormat and SwiftLint checks. Matches `.github/workflows/lint.yml`.
lint:
    swiftformat --lint .
    swiftlint lint --strict .

# Unit tests with an HTML coverage report. Matches `.github/workflows/codecov.yml`.
coverage:
    bash scripts/coverage

# SwiftLint analyze (`scripts/swiftlint-analyze`: clean build-for-testing + analyze).
analyze:
    bash scripts/swiftlint-analyze

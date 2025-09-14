# Test & Analysis — Run locally

Recommended commands to run tests and analysis in a `bash` shell.

1. Open a `bash` session (if your default is zsh):

```bash
bash
```

2. Go to project root and install dependencies:

```bash
cd "/Volumes/SSD Lexar/Documenti/alpha/Wallet_wise/wallet_wise/wallet_wise"
flutter pub get
```

3. Run static analysis:

```bash
flutter analyze --no-preamble
```

4. Run the full test suite with coverage:

```bash
flutter test --coverage -r expanded
```

5. Run a single test file:

```bash
flutter test test/widgets/dashboard_chips_test.dart -r expanded
```

6. If you need to inspect coverage output locally:

```bash
# After tests
ls -la coverage
head -n 80 coverage/lcov.info
```

Notes
- CI will upload `coverage/lcov.info` artifact and — if `CODECOV_TOKEN` is set in repository secrets — will also send coverage to Codecov.
- Prefer `bash` for running these commands locally when your shell configuration for zsh includes custom exports with spaces that may break test runners.

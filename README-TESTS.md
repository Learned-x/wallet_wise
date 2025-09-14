Run tests locally

Prerequisites:
- Install Flutter SDK and ensure `flutter` is in your PATH.
- From project root run:

```bash
flutter pub get
flutter test
```

To run a single test file:

```bash
flutter test test/providers/transactions_provider_test.dart -r expanded
```

Notes:
- The in-memory repository is registered in `lib/core/di.dart` for local development.
- If you prefer to override providers in tests, use `ProviderContainer(overrides: [...])` as shown in tests.
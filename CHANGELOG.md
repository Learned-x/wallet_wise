# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

- Migrate storage from in-memory to persistent encrypted DB using Drift.
- Add `AppDatabase` with migration strategy and seed for default categories.
- Add `lib/main_prod.dart` entrypoint to run app with persistent DB.
- Add integration test for DB seed (`test/integration/seed_integration_test.dart`).
- Update CI to run code generation and integration tests.
- Add documentation for SQLCipher/native libraries and production run.

## 0.1.0

- Initial scaffold and in-memory repository implementations.

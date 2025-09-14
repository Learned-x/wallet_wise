# Testing and Verification Guide

This document outlines how to test the drift database migration implementation.

## Local Testing (Recommended Steps)

### 1. Setup Dependencies
```bash
flutter pub get
```

### 2. Generate Drift Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run All Tests
```bash
# Run unit and integration tests
flutter test -r expanded

# Run only integration tests
flutter test test/integration -r expanded
```

### 4. Test Production Mode (Data Persistence)
```bash
# Start app with persistent database
flutter run -t lib/main_prod.dart
```

Expected behavior:
1. App starts with seeded default categories (food, transport, entertainment, bills, income)
2. Create some transactions
3. Close and restart the app
4. Data should persist between restarts

### 5. Test Development Mode (In-Memory)
```bash
# Start app with in-memory database
flutter run
```

Expected behavior:
1. App starts fresh each time (no data persistence)
2. Good for development and testing

## CI Testing

The CI workflow automatically:
1. Runs `flutter pub get`
2. Runs `flutter pub run build_runner build --delete-conflicting-outputs`
3. Runs `flutter analyze`
4. Runs `flutter test --coverage -r expanded`
5. Runs `flutter test test/integration -r expanded`

## Architecture Verification

Key components to verify:
- `AppDatabase` class with proper migration strategy
- Default category seeding in `onCreate`
- Drift repositories implementing domain interfaces
- DI properly configured for both modes
- `main_prod.dart` using persistent mode
- Integration tests validating seeding behavior

## Troubleshooting

If you encounter issues:
1. Ensure Flutter SDK is properly installed
2. Run `flutter clean` followed by `flutter pub get`
3. Regenerate code with `flutter pub run build_runner build --delete-conflicting-outputs`
4. Check that SQLite native libraries are properly configured for your platform
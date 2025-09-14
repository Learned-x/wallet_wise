# Wallet Wise - Phase 1 Detailed Plan (15-21 Settembre)

Obiettivo: stabilire le fondamenta del progetto (scaffold, architettura pulita, database locale encrypted, logging, state management e test iniziali).

Deliverable principali:
- Progetto Flutter scaffold con struttura `core/`, `domain/`, `data/`, `presentation/`.
- DI iniziale (`get_it`) e logger funzionante.
- Schema DB base (`transactions`, `categories`, `settings`) definito e repository interfaces.
- State management (Riverpod) providers skeleton.
- 20+ unit/widget tests di base e CI workflow che esegue i test.

Sub-task (con stime in giorni-uomo e dipendenze):

1) Project scaffold (0.5 d)
- Creare `pubspec.yaml`, `lib/` structure, `main.dart` (ProviderScope), `README.md` base.
- Deliverable: file scaffold (già presente nel repo).

2) Dependency Injection & Logger (0.5 d)
- Implementare `core/di.dart` con `get_it` e `core/logger.dart`.
- Deliverable: DI init + `ConsoleLogger`.

3) Domain models & Value Objects (1.0 d)
- Definire entities: `Transaction`, `Category`, `HealthScore` e value objects per `Amount`, `Date`, `CategoryId`.
- Deliverable: entity classes e test per validazione.

4) Repository interfaces & Usecases skeleton (1.0 d)
- Aggiungere abstract repository interfaces per `TransactionsRepository`, `CategoriesRepository`, `SettingsRepository`.
- Aggiungere esempi di usecase: `AddTransactionUseCase`, `GetTransactionsUseCase` (solo skeleton con tests).

5) Database Schema & Data Layer setup (1.5 d)
- Preparare schema per `transactions`, `categories`, `health_scores`, `app_settings` (drift schema file placeholder).
- Preparare `DatabaseHelper` interface e repository wiring (no full SQLCipher integration in Fase1, ma placeholder e tests).

6) State Management (Riverpod) skeleton (0.5 d)
- Providers per transactions list, categories list e health score (skeleton con mock data).

7) Logging & Error Handling (0.5 d)
- Implementare logging (core logger) e integrazione in usecases & repositories.

8) Tests & CI (1.0 d)
- Aggiungere widget/unit tests (20+) per entities/usecases/providers.
- Creare `.github/workflows/ci.yml` che esegue `flutter test`.

Totale stimato: ~6.5 giorni-uomo (parallelizzabile su più dev)

Acceptance Criteria Fase 1:
- Progetto builda (`flutter analyze` passes no fatal errors)
- `flutter test` > 20 tests passing
- DI registrata e logger disponibile via `GetIt`
- Repository interfaces e DB schema presenti
- Providers Riverpod skeleton disponibili

Rischi & Note:
- SQLCipher e drift possono richiedere configurazione nativa; per la fase 1 si mantiene un placeholder ed integrazione completa nella Fase 2.
- OCR/ML non inclusi in Fase 1; implementazione prevista in Fase 3.

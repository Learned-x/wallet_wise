# wallet_wise
Mobile app Flutter per gestione finanze personali

## Setup e installazione

1. **Installare le dipendenze:**
   ```bash
   flutter pub get
   ```

2. **Generare il codice Drift:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   Questo genererà i file `*.g.dart` necessari per Drift (es. `lib/data/datasources/drift_database.g.dart`).

## Comandi di esecuzione e test

### Test
```bash
# Eseguire tutti i test (unit + integration)
flutter test -r expanded

# Solo test di integrazione
flutter test test/integration -r expanded
```

### Esecuzione dell'app

```bash
# Modalità sviluppo (database in-memory)
flutter run

# Modalità produzione (database persistente con Drift)
flutter run -t lib/main_prod.dart
```
## Architettura del database
L'app supporta due modalità:
- **Sviluppo**: Database in-memory per testing rapido
- **Produzione**: Database SQLite persistente con Drift e seeding automatico delle categorie di default
L'entrypoint `lib/main_prod.dart` inizializza l'app con `initDI(useInMemory: false)` per utilizzare il database persistente, mentre `lib/main.dart` usa il database in-memory per default.
## Architettura del database

L'app supporta due modalità:
- **Sviluppo**: Database in-memory per testing rapido
- **Produzione**: Database SQLite persistente con Drift e seeding automatico delle categorie di default

L'entrypoint `lib/main_prod.dart` inizializza l'app con `initDI(useInMemory: false)` per utilizzare il database persistente, mentre `lib/main.dart` usa il database in-memory per default.

## Release helper

Un piccolo script `release.sh` è stato aggiunto alla root del repo per creare un tag annotato e, se disponibile, creare una GitHub Release tramite la CLI `gh`.

Esempio d'uso:

```bash
chmod +x ./release.sh
./release.sh v0.1.0
```

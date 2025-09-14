# wallet_wise
Mobile app Flutter per gestione finanze personali

## Generazione codice Drift

Dopo aver aggiornato le dipendenze, eseguire i seguenti comandi nella shell (macOS / zsh):


Questo genererà i file `*.g.dart` necessari per Drift (es. `lib/data/datasources/drift_database.g.dart`).
Per eseguire l'app in modalità produzione (usando il DB persistente e le implementazioni Drift):

```bash
# Avvia app in modalità produzione
flutter run -t lib/main_prod.dart
```

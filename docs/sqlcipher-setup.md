# Configurazione SQLCipher e librerie native per Drift

Questa guida spiega come configurare SQLCipher / sqlite native libraries per Android e iOS quando si usa `drift` con supporto di DB cifrato (es. `sqflite_sqlcipher` o `sqlite3_flutter_libs`).

Prerequisiti
- Flutter installato (compatibile con il progetto). Testato con Flutter 3.24.x.
- Eseguire `flutter pub get` prima di qualsiasi modifica.

Android
- Aggiungere la dipendenza nel `pubspec.yaml`: `sqflite_sqlcipher` oppure usare `sqlite3_flutter_libs` a seconda dell'approccio (SQLCipher vs sqlite3 native builds).
- Se usi `sqflite_sqlcipher`, modifica `android/app/build.gradle` per includere packagingOptions se necessario e assicurati che `minSdkVersion` sia compatibile.
- Se usi `sqlite3_flutter_libs`, aggiungi il plugin e segui la documentazione ufficiale per includere le librerie native.

iOS
- Per `sqflite_sqlcipher`, modifica il `ios/Podfile` per usare frameworks e aggiorna le flags di linking secondo la documentazione del plugin.
- Esegui `pod install` nella cartella `ios/` dopo aver aggiornato `pubspec.yaml`.

Test e debug
- Dopo aver configurato le dipendenze native, esegui `flutter clean` e `flutter pub get` e poi `flutter run` su emulator/device.
- Per build automatiche in CI: assicurati che il runner abbia gli SDK necessari e che il job esegua `flutter pub get` prima di eseguire build/test.

Prodotto / entrypoint di produzione
- Per avviare l'app usando il DB persistente cifrato e le implementazioni Drift registrate, usa l'entrypoint `lib/main_prod.dart`.
	- Esempio: `flutter run -t lib/main_prod.dart`.

Verifiche end-to-end
- Per verificare che l'encryption native sia correttamente integrata:
	1. Pulire e reinstallare le dipendenze: `flutter clean && flutter pub get`.
	2. Avviare su emulator/device usando l'entrypoint di produzione: `flutter run -t lib/main_prod.dart`.
	3. Inserire transazioni e riavviare l'app; i dati devono persistere tra i riavii.
	4. Per testare SQLCipher in Android CI, assicurati che il runner usi un'immagine con supporto per NDK/architetture richieste o usa `sqlite3_flutter_libs` che fornisce binari precompilati.

CI
 - Il workflow CI è stato aggiornato per eseguire codegen e i test di integrazione (cartella `test/integration`) dopo i test unitari. Se aggiungi test di integrazione che richiedono emulatori o dispositivi, aggiorna il job CI per avviare gli emulatori necessari.

Nota
- Le istruzioni specifiche dipendono dalla libreria scelta (`sqflite_sqlcipher` vs `sqlite3_flutter_libs`). Consultare le rispettive pagine pub.dev per i dettagli aggiornati.

# Budget Tracker Smart v1.0.0 - Specifica Funzionale Dettagliata (SFD)

**Documento**: Specifica Funzionale v1.0.0  
**Progetto**: Budget Tracker Smart  
**Versione Documento**: 1.0  
**Data**: 13 Settembre 2025  
**Autore**: Development Team  
**Stato**: APPROVATO per sviluppo

---

## 1. PANORAMICA DEL PROGETTO

### 1.1 Obiettivo del Prodotto
Sviluppare la **prima applicazione mobile di gestione budget personale completamente locale** che si distingue dalla concorrenza tramite un sistema di visualizzazione della salute finanziaria innovativo (Visual Budget Health Score) e gestione intelligente delle ricevute fotografiche, senza dipendenze cloud e con costi operativi zero.

### 1.2 Scope della Versione v1.0.0
La versione 1.0.0 include esclusivamente funzionalità **offline-first** per validare il product-market fit prima dell'evoluzione cloud (v2.0.0+).

**Incluso in v1.0.0**:
- ✅ Gestione completa transazioni (CRUD)
- ✅ Visual Budget Health Score (funzione distintiva)
- ✅ Smart Receipt Photo Manager con OCR locale
- ✅ AI Categorization completamente offline
- ✅ Report base (mensili/annuali) con export CSV
- ✅ Backup/restore locale completo
- ✅ 12 categorie predefinite + custom illimitate

**Escluso da v1.0.0** (riservato v2.0.0+):
- ❌ Sincronizzazione cloud
- ❌ Multi-device access
- ❌ Account utente online
- ❌ Bank integration APIs
- ❌ Family sharing
- ❌ Web dashboard

### 1.3 Target Users v1.0.0
- **Primary**: Privacy-conscious users (25-45 anni, tech-savvy)
- **Secondary**: Cost-conscious users che preferiscono one-time purchase
- **Tertiary**: Users con connessione internet limitata o inconsistente

---

## 2. REQUISITI FUNZIONALI DETTAGLIATI

### 2.1 RF001 - Gestione Transazioni

#### RF001.1 - Aggiunta Nuova Transazione
**ID**: RF001.1  
**Priorità**: CRITICA  
**User Story**: "Come utente, voglio aggiungere una nuova spesa o entrata rapidamente per tenere traccia delle mie finanze"

**Precondizioni**:
- App installata e inizializzata
- Database locale creato e funzionante

**Flusso Principale**:
1. Utente tap su FloatingActionButton "+" nella home
2. Si apre schermata "Aggiungi Transazione"
3. Utente inserisce importo (campo obbligatorio)
4. Utente seleziona categoria da dropdown/grid
5. Utente inserisce descrizione (opzionale)
6. Utente seleziona data (default: oggi)
7. Utente può aggiungere foto ricevuta (opzionale)
8. Utente tap "Salva"
9. Sistema valida input e salva in database locale
10. Sistema ricalcola Health Score
11. Sistema torna alla home con feedback "Transazione salvata"

**Campi Input**:
- **Importo** (obbligatorio):
  - Tipo: Double con 2 decimali
  - Range: -€999.999,99 / +€999.999,99
  - Validazione: Required, ≠ 0, formato valido
  - UI: TextFormField con formatter currency
  
- **Categoria** (obbligatorio):
  - Tipo: Selection da lista
  - Source: Categorie predefinite + custom utente
  - Validazione: Required, must exist in categories table
  - UI: Dropdown menu o Grid selector con icone

- **Descrizione** (opzionale):
  - Tipo: String
  - Max length: 200 caratteri
  - Validazione: Nessuna
  - UI: TextFormField multiline

- **Data** (obbligatorio):
  - Tipo: DateTime
  - Default: DateTime.now()
  - Range: Dal 1° gennaio 2020 a oggi +7 giorni
  - Validazione: Required, not future beyond 7 days
  - UI: DatePicker con formato dd/MM/yyyy

- **Foto ricevuta** (opzionale):
  - Tipo: File path string
  - Format: JPG/PNG
  - Max size: 10MB per foto
  - Validazione: Valid image format
  - UI: Camera capture + gallery picker

**Business Rules**:
- BR001.1.1: Importi negativi automaticamente assegnati a categorie "Spesa"
- BR001.1.2: Importi positivi automaticamente assegnati a categorie "Entrata"
- BR001.1.3: Auto-suggestion descrizione basata su cronologia (ultimi 10 merchant con stesso importo ±10%)
- BR001.1.4: Default categoria = ultima categoria utilizzata per transazioni simili
- BR001.1.5: Se foto presente, tentativo auto-estrazione dati con OCR

**Output/Postcondizioni**:
- Nuova transazione salvata in tabella `transactions`
- Health Score ricalcolato e aggiornato
- Dashboard aggiornata con nuovi dati
- Feedback visivo di successo mostrato all'utente

**Flussi Alternativi**:
- **Alt 1**: Campo importo invalido → Show error message, focus su campo
- **Alt 2**: Nessuna categoria selezionata → Default a "Altro" con warning
- **Alt 3**: Foto troppo grande → Auto-compress a qualità 85%
- **Alt 4**: OCR fails → Salvare transazione senza dati estratti

**Eccezioni**:
- **E001.1.1**: Database write error → Show "Errore salvataggio, riprova"
- **E001.1.2**: Storage full → Show "Spazio insufficiente per foto"
- **E001.1.3**: Camera permission denied → Show settings redirect dialog

**Criteri di Accettazione**:
- [ ] Transazione salvata correttamente in <500ms
- [ ] Health Score aggiornato automaticamente
- [ ] Validation errors chiari e actionable
- [ ] OCR extraction funziona su ricevute italiane comuni
- [ ] UI responsive su schermi 4.5" - 6.7"

#### RF001.2 - Visualizzazione Lista Transazioni
**ID**: RF001.2  
**Priorità**: CRITICA  
**User Story**: "Come utente, voglio vedere tutte le mie transazioni in ordine cronologico per monitorare le mie spese"

**Precondizioni**:
- Almeno una transazione presente nel database
- App avviata correttamente

**Flusso Principale**:
1. Utente naviga a tab "Transazioni"
2. Sistema carica transazioni da database locale
3. Sistema mostra lista in ordine cronologico (più recente primo)
4. Ogni item mostra: importo, categoria, descrizione, data
5. Utente può scroll per vedere transazioni più vecchie
6. Sistema carica batch da 50 transazioni con infinite scroll

**UI Components**:
- **ListTile Layout**:
  ```
  [Icona Categoria] [Descrizione]           [€ Importo]
                    [Data - dd/MM/yyyy]     [Categoria]
  ```

**Funzionalità Sorting/Filtering**:
- **Sort Options**:
  - Data (default): più recente → più vecchia
  - Importo: maggiore → minore
  - Categoria: alfabetico A-Z
  
- **Filter Options**:
  - Per categoria: dropdown multiselect
  - Per range date: date picker start/end
  - Per range importi: min/max input
  - Per descrizione: search bar con debounce 500ms

**Performance Requirements**:
- Lista carica in <300ms per primi 50 items
- Scroll smooth anche con 10.000+ transazioni
- Search risultati in <200ms per query
- Filter applicazione in <100ms

**Business Rules**:
- BR001.2.1: Transazioni "deleted" (soft delete) non mostrate
- BR001.2.2: Batch size = 50 items per performance
- BR001.2.3: Auto-refresh quando si torna da altre schermate
- BR001.2.4: Mantiene posizione scroll durante sessione

#### RF001.3 - Modifica Transazione Esistente
**ID**: RF001.3  
**Priorità**: ALTA  
**User Story**: "Come utente, voglio correggere errori nelle transazioni già inserite"

**Precondizioni**:
- Transazione esiste nel database
- Transazione non è più vecchia di 12 mesi (business rule)

**Flusso Principale**:
1. Utente tap su transazione nella lista
2. Si apre schermata "Modifica Transazione" con dati precompilati
3. Utente modifica uno o più campi
4. Utente tap "Salva Modifiche"
5. Sistema valida input
6. Sistema aggiorna record in database
7. Sistema ricalcola Health Score
8. Sistema torna alla lista con feedback "Modifiche salvate"

**Business Rules**:
- BR001.3.1: Solo transazioni ultimi 12 mesi sono modificabili
- BR001.3.2: Modifica update campo `updated_at` con timestamp corrente
- BR001.3.3: Se importo o categoria cambiano, ricalcola Health Score
- BR001.3.4: Mantenere audit trail in `ml_training_data` se categoria cambia

**Validation Rules**:
- Stesse validation rules di RF001.1 (Aggiunta Transazione)
- Controllo aggiuntivo: transaction_date > 12 mesi fa → read-only mode

#### RF001.4 - Eliminazione Transazione
**ID**: RF001.4  
**Priorità**: ALTA  
**User Story**: "Come utente, voglio eliminare transazioni errate o duplicate"

**Flusso Principale**:
1. Utente swipe-left su transazione nella lista
2. Appare pulsante rosso "Elimina"
3. Utente tap "Elimina"
4. Sistema mostra dialog conferma: "Eliminare transazione? Questa azione non può essere annullata"
5. Utente conferma
6. Sistema esegue soft delete (deleted_at = now())
7. Sistema rimuove item dalla lista con animazione
8. Sistema ricalcola Health Score
9. Sistema mostra snackbar "Transazione eliminata"

**Business Rules**:
- BR001.4.1: Soft delete: set `deleted_at` timestamp invece di DELETE
- BR001.4.2: Foto ricevuta associata mantenuta per recovery
- BR001.4.3: Ricalcolo immediate Health Score dopo delete
- BR001.4.4: Recovery possibile entro 30 giorni (future enhancement)

**Flusso Alternativo**:
- **Alt 1**: Utente tap fuori dal dialog → Cancel elimination
- **Alt 2**: Utente swipe-right → Show "Modifica" option invece di "Elimina"

### 2.2 RF002 - Visual Budget Health Score (FUNZIONE DISTINTIVA)

#### RF002.1 - Calcolo Health Score
**ID**: RF002.1  
**Priorità**: CRITICA  
**User Story**: "Come utente, voglio vedere immediatamente lo stato della mia salute finanziaria senza dover interpretare numeri complessi"

**Algoritmo di Calcolo**:
```dart
double calculateHealthScore(List<Transaction> transactions, Map<String, double> budgets) {
  // 1. Budget Adherence (40% del punteggio)
  double budgetAdherence = calculateBudgetAdherence(transactions, budgets);
  
  // 2. Savings Rate (30% del punteggio)  
  double savingsRate = calculateSavingsRate(transactions);
  
  // 3. Spending Consistency (20% del punteggio)
  double spendingConsistency = calculateSpendingConsistency(transactions);
  
  // 4. Improvement Trend (10% del punteggio)
  double improvementTrend = calculateImprovementTrend(transactions);
  
  return (budgetAdherence * 0.4) + 
         (savingsRate * 0.3) + 
         (spendingConsistency * 0.2) + 
         (improvementTrend * 0.1);
}

// Implementazione dettagliata singoli componenti
double calculateBudgetAdherence(List<Transaction> transactions, Map<String, double> budgets) {
  if (budgets.isEmpty) return 80.0; // Default se no budgets impostati
  
  double totalAdherence = 0.0;
  int categoriesWithBudget = 0;
  
  for (String categoryId in budgets.keys) {
    double budgetAmount = budgets[categoryId]!;
    double spentAmount = transactions
        .where((t) => t.categoryId == categoryId && t.amount < 0)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    double adherence = budgetAmount > 0 
        ? math.max(0.0, (budgetAmount - spentAmount) / budgetAmount * 100)
        : 100.0;
    
    totalAdherence += adherence;
    categoriesWithBudget++;
  }
  
  return categoriesWithBudget > 0 ? totalAdherence / categoriesWithBudget : 80.0;
}

double calculateSavingsRate(List<Transaction> transactions) {
  double totalIncome = transactions
      .where((t) => t.amount > 0)
      .fold(0.0, (sum, t) => sum + t.amount);
  
  double totalExpenses = transactions
      .where((t) => t.amount < 0)
      .fold(0.0, (sum, t) => sum + t.amount.abs());
  
  if (totalIncome <= 0) return 0.0;
  
  double savings = totalIncome - totalExpenses;
  double savingsRate = (savings / totalIncome) * 100;
  
  // Normalizza in range 0-100
  return math.max(0.0, math.min(100.0, savingsRate));
}

double calculateSpendingConsistency(List<Transaction> transactions) {
  Map<String, List<double>> dailySpending = {};
  
  for (var transaction in transactions.where((t) => t.amount < 0)) {
    String dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
    dailySpending.putIfAbsent(dateKey, () => []);
    dailySpending[dateKey]!.add(transaction.amount.abs());
  }
  
  List<double> dailyTotals = dailySpending.values
      .map((spendingList) => spendingList.fold(0.0, (a, b) => a + b))
      .toList();
  
  if (dailyTotals.length < 7) return 70.0; // Default per dati insufficienti
  
  double mean = dailyTotals.fold(0.0, (a, b) => a + b) / dailyTotals.length;
  double variance = dailyTotals
      .map((x) => math.pow(x - mean, 2))
      .fold(0.0, (a, b) => a + b) / dailyTotals.length;
  
  double stdDev = math.sqrt(variance);
  double coefficient = mean > 0 ? stdDev / mean : 0.0;
  
  // Meno variabilità = più consistenza = score più alto
  return math.max(0.0, 100.0 - (coefficient * 50.0));
}

double calculateImprovementTrend(List<Transaction> transactions) {
  DateTime now = DateTime.now();
  DateTime thirtyDaysAgo = now.subtract(Duration(days: 30));
  DateTime sixtyDaysAgo = now.subtract(Duration(days: 60));
  
  double recentSpending = transactions
      .where((t) => t.amount < 0 && t.date.isAfter(thirtyDaysAgo))
      .fold(0.0, (sum, t) => sum + t.amount.abs());
  
  double previousSpending = transactions
      .where((t) => t.amount < 0 && 
                   t.date.isAfter(sixtyDaysAgo) && 
                   t.date.isBefore(thirtyDaysAgo))
      .fold(0.0, (sum, t) => sum + t.amount.abs());
  
  if (previousSpending <= 0) return 50.0; // Neutral se no data
  
  double improvement = ((previousSpending - recentSpending) / previousSpending) * 100;
  
  // Normalizza: miglioramento 20% = score 100, peggioramento 20% = score 0
  return math.max(0.0, math.min(100.0, 50.0 + (improvement * 2.5)));
}
```

**Update Triggers**:
- Ogni aggiunta/modifica/eliminazione transazione
- Modifica budget settings
- Apertura dashboard (refresh)
- Background refresh ogni ora se app active

**Performance Requirements**:
- Calcolo completato in <100ms per 10.000 transazioni
- Caching risultato per 5 minuti per evitare ricalcoli frequenti
- Progress indicator se calcolo > 200ms

#### RF002.2 - Visualizzazione Dashboard Health Score
**ID**: RF002.2  
**Priorità**: CRITICA  
**User Story**: "Come utente, voglio vedere la mia salute finanziaria rappresentata visivamente in modo immediato e comprensibile"

**UI Components Dettagliati**:

**1. Central Health Ring**:
```dart
// Specifiche tecniche widget
Container(
  width: 200.0,
  height: 200.0,
  child: Stack(
    alignment: Alignment.center,
    children: [
      // Background ring
      CircularProgressIndicator(
        value: 1.0,
        strokeWidth: 12.0,
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[200]),
      ),
      // Progress ring con colore dinamico
      CircularProgressIndicator(
        value: healthScore / 100,
        strokeWidth: 12.0,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation<Color>(getHealthScoreColor(healthScore)),
      ),
      // Score numerico centrale
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            healthScore.toInt().toString(),
            style: TextStyle(
              fontSize: 48.0,
              fontWeight: FontWeight.bold,
              color: getHealthScoreColor(healthScore),
            ),
          ),
          Text(
            '/100',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ],
  ),
)
```

**Color Mapping**:
```dart
Color getHealthScoreColor(double score) {
  if (score >= 80) return Color(0xFF4CAF50); // Verde brillante
  if (score >= 60) return Color(0xFF8BC34A); // Verde chiaro  
  if (score >= 40) return Color(0xFFFF9800); // Arancione
  if (score >= 20) return Color(0xFFFF5722); // Rosso chiaro
  return Color(0xFFF44336); // Rosso scuro
}
```

**2. Mood Emoji Indicator**:
```dart
Widget buildMoodIndicator(double healthScore) {
  String emoji;
  String message;
  
  if (healthScore >= 80) {
    emoji = '😊';
    message = 'Ottimo controllo!';
  } else if (healthScore >= 60) {
    emoji = '🙂';
    message = 'Sulla buona strada';
  } else if (healthScore >= 40) {
    emoji = '😐';
    message = 'Attenzione al budget';
  } else if (healthScore >= 20) {
    emoji = '😟';
    message = 'Revisione necessaria';
  } else {
    emoji = '😰';
    message = 'Situazione critica';
  }
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        emoji,
        style: TextStyle(fontSize: 24.0),
      ),
      SizedBox(width: 8.0),
      Text(
        message,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}
```

**3. Quick Insights Cards** (3 cards orizzontalmente scrollabili):

**Card 1 - Monthly Budget Progress**:
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Speso questo mese', style: cardTitleStyle),
        SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: spentAmount / budgetAmount,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  spentAmount / budgetAmount > 0.8 
                    ? Colors.red 
                    : Colors.green
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.0),
        Text(
          '€${spentAmount.toStringAsFixed(2)} / €${budgetAmount.toStringAsFixed(2)}',
          style: cardValueStyle,
        ),
        Text(
          '${((spentAmount / budgetAmount) * 100).toInt()}% utilizzato',
          style: cardSubtitleStyle,
        ),
      ],
    ),
  ),
)
```

**Card 2 - Top Category**:
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categoria principale', style: cardTitleStyle),
        SizedBox(height: 8.0),
        Row(
          children: [
            Icon(
              topCategory.icon,
              size: 24.0,
              color: topCategory.color,
            ),
            SizedBox(width: 8.0),
            Text(
              topCategory.name,
              style: cardValueStyle,
            ),
          ],
        ),
        Text(
          '€${topCategoryAmount.toStringAsFixed(2)} (${topCategoryPercentage.toInt()}%)',
          style: cardSubtitleStyle,
        ),
      ],
    ),
  ),
)
```

**Card 3 - Days Remaining**:
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Giorni rimanenti', style: cardTitleStyle),
        SizedBox(height: 8.0),
        Text(
          daysRemainingInMonth.toString(),
          style: cardValueStyle.copyWith(
            fontSize: 32.0,
            color: suggestedDailySpend > availableBudget / daysRemainingInMonth 
              ? Colors.red 
              : Colors.green,
          ),
        ),
        Text(
          'Budget giornaliero suggerito:',
          style: cardSubtitleStyle,
        ),
        Text(
          '€${(availableBudget / daysRemainingInMonth).toStringAsFixed(2)}',
          style: cardValueStyle.copyWith(fontSize: 16.0),
        ),
      ],
    ),
  ),
)
```

**4. Weekly Trend Sparkline**:
```dart
Container(
  height: 60.0,
  width: double.infinity,
  child: CustomPaint(
    painter: SparklinePainter(
      data: last7DaysSpending,
      color: getHealthScoreColor(healthScore),
      strokeWidth: 2.0,
    ),
  ),
)

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double strokeWidth;
  
  SparklinePainter({
    required this.data,
    required this.color,
    required this.strokeWidth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    final double maxValue = data.reduce(math.max);
    final double minValue = data.reduce(math.min);
    final double range = maxValue - minValue;
    
    if (range == 0) {
      // Linea piatta se tutti i valori uguali
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, size.height / 2);
    } else {
      final double stepX = size.width / (data.length - 1);
      
      for (int i = 0; i < data.length; i++) {
        final double x = i * stepX;
        final double y = size.height - ((data[i] - minValue) / range) * size.height;
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

**Animazioni Specifiche**:
- **Health Ring**: Spring animation (duration: 1000ms, curve: Curves.elasticOut)
- **Mood Emoji**: Fade transition quando cambia (duration: 300ms)
- **Cards**: Staggered slide-in animation (100ms offset tra cards)
- **Sparkline**: Draw animation da sinistra a destra (duration: 800ms)

#### RF002.3 - Notifications e Alerts Intelligenti
**ID**: RF002.3  
**Priorità**: MEDIA  
**User Story**: "Come utente, voglio ricevere avvisi automatici quando la mia situazione finanziaria richiede attenzione"

**Trigger Conditions e Messaggi**:

**1. Budget Alert (80% raggiunto)**:
```dart
if (spentPercentage >= 0.8 && spentPercentage < 0.95) {
  showNotification(
    title: '⚠️ Budget quasi esaurito!',
    body: 'Hai speso €${spentAmount.toStringAsFixed(2)} di €${budgetAmount.toStringAsFixed(2)}. '
          'Rimangono €${(budgetAmount - spentAmount).toStringAsFixed(2)} per ${daysRemaining} giorni.',
    type: NotificationType.WARNING,
  );
}
```

**2. Budget Exceeded (>95% o superato)**:
```dart
if (spentPercentage >= 0.95) {
  showNotification(
    title: '🚨 Budget superato!',
    body: spentAmount > budgetAmount 
      ? 'Hai superato il budget di €${(spentAmount - budgetAmount).toStringAsFixed(2)}.'
      : 'Hai raggiunto il ${(spentPercentage * 100).toInt()}% del budget mensile.',
    type: NotificationType.CRITICAL,
  );
}
```

**3. Unusual Spending Pattern**:
```dart
if (transactionAmount > (averageTransactionAmount + (2 * standardDeviation))) {
  showNotification(
    title: '🔍 Spesa insolita rilevata',
    body: 'Hai speso €${transactionAmount.toStringAsFixed(2)} per ${categoryName}. '
          'È circa il ${((transactionAmount / averageTransactionAmount) * 100).toInt()}% '
          'della tua spesa media per questa categoria.',
    type: NotificationType.INFO,
  );
}
```

**4. Health Score Improvement**:
```dart
if (newHealthScore > previousHealthScore + 5) {
  showNotification(
    title: '🎉 Progresso finanziario!',
    body: 'Il tuo Health Score è migliorato di ${(newHealthScore - previousHealthScore).toInt()} punti '
          'questa settimana. Continua così!',
    type: NotificationType.SUCCESS,
  );
}
```

**5. Month End Summary**:
```dart
if (isLastDayOfMonth && healthScore >= 70) {
  showNotification(
    title: '💪 Obiettivo mensile raggiunto!',
    body: 'Hai risparmiato €${monthlySavings.toStringAsFixed(2)} questo mese. '
          'Health Score finale: ${healthScore.toInt()}/100',
    type: NotificationType.SUCCESS,
  );
}
```

**Notification Scheduling**:
- **Real-time**: Budget alerts, unusual spending (immediate dopo transaction)
- **Daily**: Health score check (ore 20:00)
- **Weekly**: Improvement notifications (domenica ore 18:00)  
- **Monthly**: Summary notifications (ultimo giorno mese ore 21:00)

**Settings User**:
- Enable/disable notifications globalmente
- Granular control per tipo notification
- Quiet hours (default 22:00 - 8:00)
- Threshold personalizzabile per unusual spending (1x, 1.5x, 2x average)

### 2.3 RF003 - Smart Receipt Photo Manager

#### RF003.1 - Acquisizione Foto Ricevute
**ID**: RF003.1  
**Priorità**: ALTA  
**User Story**: "Come utente, voglio fotografare le ricevute per avere documentazione delle mie spese"

**Flusso Acquisizione Camera**:
1. Utente tap su icona camera nella schermata "Aggiungi Transazione"
2. Sistema richiede permesso camera se non già concesso
3. Si apre camera preview con overlay guida per ricevuta
4. Utente allinea ricevuta nell'overlay rettangolare
5. Utente tap pulsante scatto o volume button
6. Sistema cattura foto ad alta risoluzione
7. Sistema mostra preview con opzioni "Rifai" o "Conferma"
8. Se confermata, sistema processa foto e salva temporaneamente
9. Sistema tenta OCR extraction e mostra risultati
10. Utente può modificare dati estratti o procedere

**Camera Settings**:
```dart
// Configurazione camera ottimizzata per ricevute
CameraController cameraController = CameraController(
  cameras.first,
  ResolutionPreset.high, // 1920x1080 per OCR accuracy
);

// Auto-focus continuo per testo nitido
await cameraController.setFocusMode(FocusMode.auto);

// Flash automatico basato su condizioni luce
await cameraController.setFlashMode(
  ambientLightLevel < threshold ? FlashMode.auto : FlashMode.off
);

// Stabilizzazione per ridurre blur
await cameraController.setStabilizationMode(true);
```

**Overlay Guide UI**:
```dart
Stack(
  children: [
    // Camera preview
    CameraPreview(cameraController),
    
    // Overlay scuro con ritaglio rettangolare
    CustomPaint(
      painter: ReceiptOverlayPainter(),
      child: Container(),
    ),
    
    // Istruzioni posizionate
    Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Posiziona la ricevuta all\'interno del rettangolo.\n'
          'Assicurati che il testo sia leggibile.',
          style: TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    ),
    
    // Controlli camera
    Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          IconButton(
            icon: Icon(Icons.photo_library, color: Colors.white, size: 32),
            onPressed: () => _pickFromGallery(),
          ),
          
          // Capture button
          GestureDetector(
            onTap: () => _capturePhoto(),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 3),
              ),
              child: Icon(Icons.camera_alt, size: 35, color: Colors.grey[700]),
            ),
          ),
          
          // Flash toggle
          IconButton(
            icon: Icon(
              _flashMode == FlashMode.off 
                ? Icons.flash_off 
                : Icons.flash_on,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () => _toggleFlash(),
          ),
        ],
      ),
    ),
  ],
)
```

**Gallery Selection Alternative**:
```dart
Future<void> _pickFromGallery() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 1920,
    maxHeight: 1080,
    imageQuality: 85,
  );
  
  if (image != null) {
    File imageFile = File(image.path);
    await _processReceiptImage(imageFile);
  }
}
```

#### RF003.2 - Processing e Storage Foto
**ID**: RF003.2  
**Priorità**: ALTA  
**User Story**: "Come utente, voglio che le foto delle ricevute siano ottimizzate per occupare poco spazio ma rimanere leggibili"

**Image Processing Pipeline**:
```dart
Future<String> processAndStoreReceipt(File originalImage, String transactionId) async {
  try {
    // 1. Load e decode immagine
    img.Image? image = img.decodeImage(await originalImage.readAsBytes());
    if (image == null) throw Exception('Invalid image format');
    
    // 2. Auto-rotate basato su EXIF
    image = img.bakeOrientation(image);
    
    // 3. Resize se troppo grande (mantenendo aspect ratio)
    if (image.width > 1920 || image.height > 1920) {
      image = img.copyResize(
        image,
        width: image.width > image.height ? 1920 : null,
        height: image.height > image.width ? 1920 : null,
      );
    }
    
    // 4. Enhance contrast per OCR (opzionale)
    image = img.adjustColor(
      image,
      contrast: 1.2,
      brightness: 1.1,
    );
    
    // 5. Compress JPEG con qualità 85%
    List<int> compressedBytes = img.encodeJpg(image, quality: 85);
    
    // 6. Generate unique filename
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String fileName = 'receipt_${transactionId}_$timestamp.jpg';
    
    // 7. Save to app directory
    Directory appDir = await getApplicationDocumentsDirectory();
    Directory receiptsDir = Directory('${appDir.path}/receipts');
    if (!receiptsDir.existsSync()) {
      receiptsDir.createSync(recursive: true);
    }
    
    File outputFile = File('${receiptsDir.path}/$fileName');
    await outputFile.writeAsBytes(compressedBytes);
    
    // 8. Return relative path per database storage
    return 'receipts/$fileName';
    
  } catch (e) {
    throw Exception('Error processing receipt image: $e');
  }
}
```

**Storage Organization**:
```
/data/data/com.example.budgettracker/app_flutter/
├── receipts/
│   ├── receipt_trans123_1694620800000.jpg
│   ├── receipt_trans124_1694620850000.jpg
│   └── receipt_trans125_1694620900000.jpg
├── backups/
└── temp/
```

**Cleanup Strategy**:
```dart
// Cleanup foto di transazioni eliminate (run weekly)
Future<void> cleanupOrphanedReceipts() async {
  Directory receiptsDir = Directory('${appDir.path}/receipts');
  List<FileSystemEntity> files = receiptsDir.listSync();
  
  for (FileSystemEntity file in files) {
    if (file is File && file.path.endsWith('.jpg')) {
      // Extract transaction ID from filename
      String fileName = file.path.split('/').last;
      RegExp regExp = RegExp(r'receipt_([^_]+)_\d+\.jpg');
      Match? match = regExp.firstMatch(fileName);
      
      if (match != null) {
        String transactionId = match.group(1)!;
        
        // Check if transaction exists and is not deleted
        bool transactionExists = await _checkTransactionExists(transactionId);
        if (!transactionExists) {
          // Delete orphaned receipt
          await file.delete();
          print('Deleted orphaned receipt: ${file.path}');
        }
      }
    }
  }
}
```

#### RF003.3 - OCR Extraction Locale
**ID**: RF003.3  
**Priorità**: ALTA  
**User Story**: "Come utente, voglio che i dati importanti vengano estratti automaticamente dalle foto delle ricevute"

**Google ML Kit Text Recognition Integration**:
```dart
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  late final TextRecognizer _textRecognizer;
  
  OCRService() {
    _textRecognizer = TextRecognizer();
  }
  
  Future<ReceiptData?> extractReceiptData(String imagePath) async {
    try {
      // 1. Load immagine
      final InputImage inputImage = InputImage.fromFilePath(imagePath);
      
      // 2. Riconoscimento testo
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // 3. Extract structured data
      return _parseReceiptText(recognizedText);
      
    } catch (e) {
      print('OCR Error: $e');
      return null;
    }
  }
  
  ReceiptData? _parseReceiptText(RecognizedText recognizedText) {
    String fullText = recognizedText.text;
    List<String> lines = fullText.split('\n');
    
    // Initialize extraction results
    double? amount;
    DateTime? date;
    String? merchant;
    List<ReceiptItem> items = [];
    
    // 1. Extract total amount (multiple patterns)
    amount = _extractAmount(lines);
    
    // 2. Extract date (multiple formats)
    date = _extractDate(lines);
    
    // 3. Extract merchant name
    merchant = _extractMerchant(lines);
    
    // 4. Extract line items (advanced)
    items = _extractLineItems(lines);
    
    if (amount != null || date != null || merchant != null) {
      return ReceiptData(
        amount: amount,
        date: date,
        merchant: merchant,
        items: items,
        confidence: _calculateConfidence(amount, date, merchant),
      );
    }
    
    return null;
  }
  
  double? _extractAmount(List<String> lines) {
    // Pattern per importi italiani
    List<RegExp> amountPatterns = [
      RegExp(r'TOTALE\s*[€]?\s*(\d+[.,]\d{2})', caseSensitive: false),
      RegExp(r'TOTAL\s*[€]?\s*(\d+[.,]\d{2})', caseSensitive: false),
      RegExp(r'TOT[.]?\s*[€]?\s*(\d+[.,]\d{2})', caseSensitive: false),
      RegExp(r'[€]\s*(\d+[.,]\d{2})\s*$'), // Euro amount at line end
      RegExp(r'(\d+[.,]\d{2})\s*[€]\s*$'), // Amount Euro at line end
      RegExp(r'SALDO\s*[€]?\s*(\d+[.,]\d{2})', caseSensitive: false),
    ];
    
    for (String line in lines) {
      for (RegExp pattern in amountPatterns) {
        Match? match = pattern.firstMatch(line.trim());
        if (match != null) {
          String amountStr = match.group(1)!.replaceAll(',', '.');
          double? parsedAmount = double.tryParse(amountStr);
          if (parsedAmount != null && parsedAmount > 0 && parsedAmount < 10000) {
            return parsedAmount;
          }
        }
      }
    }
    
    return null;
  }
  
  DateTime? _extractDate(List<String> lines) {
    List<RegExp> datePatterns = [
      RegExp(r'(\d{2})[/.-](\d{2})[/.-](\d{4})'), // DD/MM/YYYY
      RegExp(r'(\d{2})[/.-](\d{2})[/.-](\d{2})'), // DD/MM/YY  
      RegExp(r'(\d{4})[/.-](\d{2})[/.-](\d{2})'), // YYYY/MM/DD
    ];
    
    for (String line in lines) {
      for (RegExp pattern in datePatterns) {
        Match? match = pattern.firstMatch(line);
        if (match != null) {
          try {
            if (pattern == datePatterns[0] || pattern == datePatterns[1]) {
              // DD/MM format
              int day = int.parse(match.group(1)!);
              int month = int.parse(match.group(2)!);
              int year = int.parse(match.group(3)!);
              
              // Handle 2-digit years
              if (year < 100) {
                year += (year < 50) ? 2000 : 1900;
              }
              
              DateTime parsedDate = DateTime(year, month, day);
              
              // Validate date is reasonable (not future, not too old)
              DateTime now = DateTime.now();
              if (parsedDate.isBefore(now.add(Duration(days: 1))) && 
                  parsedDate.isAfter(now.subtract(Duration(days: 365 * 2)))) {
                return parsedDate;
              }
            } else {
              // YYYY/MM/DD format
              int year = int.parse(match.group(1)!);
              int month = int.parse(match.group(2)!);
              int day = int.parse(match.group(3)!);
              
              DateTime parsedDate = DateTime(year, month, day);
              DateTime now = DateTime.now();
              if (parsedDate.isBefore(now.add(Duration(days: 1))) && 
                  parsedDate.isAfter(now.subtract(Duration(days: 365 * 2)))) {
                return parsedDate;
              }
            }
          } catch (e) {
            continue; // Try next pattern
          }
        }
      }
    }
    
    return null;
  }
  
  String? _extractMerchant(List<String> lines) {
    // Merchant name usually in first few lines, all caps or title case
    for (int i = 0; i < math.min(5, lines.length); i++) {
      String line = lines[i].trim();
      
      // Skip common receipt headers
      if (line.toLowerCase().contains('ricevut') ||
          line.toLowerCase().contains('scontrin') ||
          line.toLowerCase().contains('fiscal') ||
          line.toLowerCase().contains('data') ||
          line.toLowerCase().contains('ora') ||
          line.length < 3 ||
          line.length > 50) {
        continue;
      }
      
      // Look for lines with business-like characteristics
      if (_looksLikeMerchantName(line)) {
        return _cleanMerchantName(line);
      }
    }
    
    return null;
  }
  
  bool _looksLikeMerchantName(String line) {
    // Heuristics per identificare merchant names
    line = line.trim();
    
    // Caratteristiche positive
    bool hasUpperCase = line.contains(RegExp(r'[A-Z]'));
    bool isNotTooShort = line.length >= 3;
    bool isNotTooLong = line.length <= 50;
    bool notJustNumbers = !RegExp(r'^\d+$').hasMatch(line);
    bool notCommonWords = !RegExp(r'^(VIA|PIAZZA|CORSO|TEL|FAX|P\.?IVA)').hasMatch(line.toUpperCase());
    
    return hasUpperCase && isNotTooShort && isNotTooLong && notJustNumbers && notCommonWords;
  }
  
  String _cleanMerchantName(String merchant) {
    // Clean e standardizza merchant name
    merchant = merchant.trim();
    
    // Remove common suffixes/prefixes
    merchant = merchant.replaceAll(RegExp(r'\s*S\.?R\.?L\.?$', caseSensitive: false), '');
    merchant = merchant.replaceAll(RegExp(r'\s*S\.?P\.?A\.?$', caseSensitive: false), '');
    merchant = merchant.replaceAll(RegExp(r'\s*S\.?N\.?C\.?$', caseSensitive: false), '');
    
    // Capitalize properly
    return merchant.split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
  
  double _calculateConfidence(double? amount, DateTime? date, String? merchant) {
    double confidence = 0.0;
    
    if (amount != null) confidence += 0.5; // Amount è più importante
    if (date != null) confidence += 0.3;
    if (merchant != null) confidence += 0.2;
    
    return confidence;
  }
  
  void dispose() {
    _textRecognizer.close();
  }
}

class ReceiptData {
  final double? amount;
  final DateTime? date;
  final String? merchant;
  final List<ReceiptItem> items;
  final double confidence;
  
  ReceiptData({
    this.amount,
    this.date,
    this.merchant,
    this.items = const [],
    required this.confidence,
  });
}

class ReceiptItem {
  final String name;
  final double price;
  final int quantity;
  
  ReceiptItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}
```

**OCR Results UI**:
```dart
Widget buildOCRResultsCard(ReceiptData ocrData) {
  return Card(
    margin: EdgeInsets.all(16),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Dati estratti automaticamente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(ocrData.confidence),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(ocrData.confidence * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Extracted fields
          if (ocrData.amount != null) ...[
            _buildExtractedField(
              'Importo',
              '€${ocrData.amount!.toStringAsFixed(2)}',
              Icons.euro,
            ),
          ],
          
          if (ocrData.date != null) ...[
            _buildExtractedField(
              'Data',
              DateFormat('dd/MM/yyyy').format(ocrData.date!),
              Icons.calendar_today,
            ),
          ],
          
          if (ocrData.merchant != null) ...[
            _buildExtractedField(
              'Esercente',
              ocrData.merchant!,
              Icons.store,
            ),
          ],
          
          SizedBox(height: 12),
          Text(
            'Controlla i dati estratti e modifica se necessario.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildExtractedField(String label, String value, IconData icon) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
  );
}

Color _getConfidenceColor(double confidence) {
  if (confidence >= 0.8) return Colors.green;
  if (confidence >= 0.6) return Colors.orange;
  return Colors.red;
}
```

#### RF003.4 - Gallery e Gestione Foto
**ID**: RF003.4  
**Priorità**: MEDIA  
**User Story**: "Come utente, voglio visualizzare tutte le foto delle ricevute e gestirle facilmente"

**Receipt Gallery Interface**:
```dart
class ReceiptGalleryPage extends StatefulWidget {
  @override
  _ReceiptGalleryPageState createState() => _ReceiptGalleryPageState();
}

class _ReceiptGalleryPageState extends State<ReceiptGalleryPage> {
  List<ReceiptPhoto> receipts = [];
  bool isLoading = true;
  String searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadReceipts();
  }
  
  Future<void> _loadReceipts() async {
    setState(() => isLoading = true);
    
    try {
      receipts = await ReceiptService.getAllReceipts();
      receipts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _showErrorSnackbar('Errore caricamento foto: $e');
    }
    
    setState(() => isLoading = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galleria Ricevute'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'cleanup',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services),
                    SizedBox(width: 8),
                    Text('Pulizia automatica'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.archive),
                    SizedBox(width: 8),
                    Text('Esporta tutto'),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleMenuAction(value),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : receipts.isEmpty
              ? _buildEmptyState()
              : _buildReceiptGrid(),
    );
  }
  
  Widget _buildReceiptGrid() {
    List<ReceiptPhoto> filteredReceipts = receipts.where((receipt) {
      if (searchQuery.isEmpty) return true;
      
      return receipt.merchant?.toLowerCase().contains(searchQuery.toLowerCase()) == true ||
             receipt.description?.toLowerCase().contains(searchQuery.toLowerCase()) == true ||
             receipt.amount?.toString().contains(searchQuery) == true;
    }).toList();
    
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredReceipts.length,
      itemBuilder: (context, index) {
        ReceiptPhoto receipt = filteredReceipts[index];
        return _buildReceiptCard(receipt);
      },
    );
  }
  
  Widget _buildReceiptCard(ReceiptPhoto receipt) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openReceiptDetail(receipt),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail immagine
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(receipt.filePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                  
                  // Overlay con info estratte
                  if (receipt.amount != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '€${receipt.amount!.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Info card
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Merchant name o transaction description
                    Text(
                      receipt.merchant ?? receipt.description ?? 'Ricevuta',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Data
                    Text(
                      DateFormat('dd/MM/yyyy').format(receipt.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Nessuna ricevuta salvata',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Le foto delle ricevute appaiono qui quando aggiungi transazioni',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _openReceiptDetail(ReceiptPhoto receipt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptDetailPage(receipt: receipt),
      ),
    );
  }
  
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempQuery = searchQuery;
        return AlertDialog(
          title: Text('Cerca ricevute'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Nome esercente, importo, descrizione...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => tempQuery = value,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => searchQuery = '');
                Navigator.pop(context);
              },
              child: Text('Cancella'),
            ),
            TextButton(
              onPressed: () {
                setState(() => searchQuery = tempQuery);
                Navigator.pop(context);
              },
              child: Text('Cerca'),
            ),
          ],
        );
      },
    );
  }
  
  void _handleMenuAction(String action) {
    switch (action) {
      case 'cleanup':
        _showCleanupDialog();
        break;
      case 'export':
        _exportAllReceipts();
        break;
    }
  }
  
  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pulizia automatica'),
        content: Text(
          'Eliminare le foto delle ricevute associate a transazioni cancellate?\n\n'
          'Questa operazione non può essere annullata.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performCleanup();
            },
            child: Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _performCleanup() async {
    try {
      int deletedCount = await ReceiptService.cleanupOrphanedReceipts();
      _showSuccessSnackbar('Eliminate $deletedCount foto obsolete');
      _loadReceipts(); // Ricarica lista
    } catch (e) {
      _showErrorSnackbar('Errore durante pulizia: $e');
    }
  }
  
  Future<void> _exportAllReceipts() async {
    try {
      String exportPath = await ReceiptService.exportAllReceipts();
      _showSuccessSnackbar('Ricevute esportate in: $exportPath');
    } catch (e) {
      _showErrorSnackbar('Errore esportazione: $e');
    }
  }
  
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class ReceiptPhoto {
  final String id;
  final String filePath;
  final DateTime createdAt;
  final double? amount;
  final String? merchant;
  final String? description;
  final String transactionId;
  
  ReceiptPhoto({
    required this.id,
    required this.filePath,
    required this.createdAt,
    this.amount,
    this.merchant,
    this.description,
    required this.transactionId,
  });
}
```

### 2.4 RF004 - AI Local Categorization

#### RF004.1 - Machine Learning Model Locale
**ID**: RF004.1  
**Priorità**: MEDIA  
**User Story**: "Come utente, voglio che l'app impari dalle mie abitudini e categorizzi automaticamente le spese future"

**TensorFlow Lite Model Architecture**:
```dart
import 'package:tflite_flutter/tflite_flutter.dart';

class LocalMLCategorizationService {
  static const String MODEL_FILE = 'categorization_model.tflite';
  static const int MAX_SEQUENCE_LENGTH = 50;
  static const int VOCAB_SIZE = 10000;
  static const int EMBEDDING_DIM = 64;
  static const int NUM_CATEGORIES = 12;
  
  late Interpreter _interpreter;
  Map<String, int> _wordToIndex = {};
  Map<int, String> _categoryMapping = {};
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    try {
      // 1. Load TFLite model
      _interpreter = await Interpreter.fromAsset(MODEL_FILE);
      
      // 2. Load vocabulary mapping
      await _loadVocabulary();
      
      // 3. Load category mapping
      await _loadCategoryMapping();
      
      _isInitialized = true;
      print('ML Categorization Service initialized');
    } catch (e) {
      print('Error initializing ML service: $e');
      _isInitialized = false;
    }
  }
  
  Future<CategoryPrediction?> predictCategory(String description, double amount) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) return null;
    }
    
    try {
      // 1. Preprocess input text
      List<int> tokenized = _tokenizeText(description);
      
      // 2. Create input tensor
      List<List<double>> input = [_createFeatureVector(tokenized, amount)];
      
      // 3. Create output tensor
      List<List<double>> output = List.generate(1, (index) => List.filled(NUM_CATEGORIES, 0.0));
      
      // 4. Run inference
      _interpreter.run(input, output);
      
      // 5. Process results
      return _processOutput(output[0], description);
      
    } catch (e) {
      print('Error during prediction: $e');
      return null;
    }
  }
  
  List<int> _tokenizeText(String text) {
    // Simple tokenization per italiano
    text = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    List<String> words = text.split(' ').where((word) => word.isNotEmpty).toList();
    
    List<int> tokens = [];
    for (String word in words) {
      int? token = _wordToIndex[word];
      if (token != null) {
        tokens.add(token);
      }
      
      // Limit to max sequence length
      if (tokens.length >= MAX_SEQUENCE_LENGTH) break;
    }
    
    // Pad sequence to fixed length
    while (tokens.length < MAX_SEQUENCE_LENGTH) {
      tokens.add(0); // 0 = padding token
    }
    
    return tokens;
  }
  
  List<double> _createFeatureVector(List<int> tokens, double amount) {
    List<double> features = [];
    
    // 1. Add tokenized text (converted to doubles)
    features.addAll(tokens.map((token) => token.toDouble()));
    
    // 2. Add amount feature (normalized)
    double normalizedAmount = _normalizeAmount(amount);
    features.add(normalizedAmount);
    
    // 3. Add day of week feature (current context)
    int dayOfWeek = DateTime.now().weekday;
    features.add(dayOfWeek.toDouble() / 7.0);
    
    // 4. Add time of day feature
    int hourOfDay = DateTime.now().hour;
    features.add(hourOfDay.toDouble() / 24.0);
    
    return features;
  }
  
  double _normalizeAmount(double amount) {
    // Log normalization per amounts
    double absAmount = amount.abs();
    if (absAmount <= 0) return 0.0;
    
    double logAmount = math.log(absAmount + 1);
    double maxLogAmount = math.log(1001); // Max expected ~€1000
    
    return math.min(1.0, logAmount / maxLogAmount);
  }
  
  CategoryPrediction _processOutput(List<double> output, String originalDescription) {
    // Find category with highest confidence
    int bestCategoryIndex = 0;
    double bestConfidence = output[0];
    
    for (int i = 1; i < output.length; i++) {
      if (output[i] > bestConfidence) {
        bestConfidence = output[i];
        bestCategoryIndex = i;
      }
    }
    
    String categoryId = _categoryMapping[bestCategoryIndex] ?? 'other';
    
    // Calculate explanation
    String explanation = _generateExplanation(originalDescription, categoryId, bestConfidence);
    
    return CategoryPrediction(
      categoryId: categoryId,
      confidence: bestConfidence,
      explanation: explanation,
      alternativeCategories: _getAlternativeCategories(output, bestCategoryIndex),
    );
  }
  
  String _generateExplanation(String description, String categoryId, double confidence) {
    // Generate human-readable explanation
    Map<String, String> explanationTemplates = {
      'food': 'Basato su parole chiave come "spesa", "supermercato", "ristorante"',
      'transport': 'Basato su parole chiave come "benzina", "bus", "taxi", "parcheggio"',
      'home': 'Basato su parole chiave come "bolletta", "affitto", "casa"',
      'health': 'Basato su parole chiave come "farmacia", "medico", "ospedale"',
      'entertainment': 'Basato su parole chiave come "cinema", "teatro", "bar"',
    };
    
    String baseExplanation = explanationTemplates[categoryId] ?? 
        'Basato su pattern simili nelle transazioni precedenti';
    
    if (confidence > 0.8) {
      return '$baseExplanation (alta confidenza)';
    } else if (confidence > 0.6) {
      return '$baseExplanation (media confidenza)';
    } else {
      return '$baseExplanation (bassa confidenza - verifica)';
    }
  }
  
  List<AlternativeCategory> _getAlternativeCategories(List<double> output, int bestIndex) {
    List<AlternativeCategory> alternatives = [];
    
    // Sort by confidence, exclude best match
    for (int i = 0; i < output.length; i++) {
      if (i != bestIndex && output[i] > 0.1) { // Only meaningful alternatives
        alternatives.add(AlternativeCategory(
          categoryId: _categoryMapping[i] ?? 'other',
          confidence: output[i],
        ));
      }
    }
    
    alternatives.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    // Return top 3 alternatives
    return alternatives.take(3).toList();
  }
  
  Future<void> _loadVocabulary() async {
    // In una implementazione reale, questo sarebbe caricato da un asset file
    // Per esempio da un file JSON pre-computed durante training
    
    String vocabJson = await DefaultAssetBundle.of(context)
        .loadString('assets/ml_models/vocabulary.json');
    Map<String, dynamic> vocab = json.decode(vocabJson);
    
    _wordToIndex = Map<String, int>.from(vocab);
  }
  
  Future<void> _loadCategoryMapping() async {
    // Mapping da index numerico a category ID
    _categoryMapping = {
      0: 'food',
      1: 'transport', 
      2: 'home',
      3: 'health',
      4: 'entertainment',
      5: 'clothing',
      6: 'education',
      7: 'sport',
      8: 'pets',
      9: 'gifts',
      10: 'salary',
      11: 'other_income',
    };
  }
  
  // Learning from user corrections
  Future<void> recordUserFeedback({
    required String description,
    required double amount,
    required String predictedCategoryId,
    required String actualCategoryId,
    required double confidence,
  }) async {
    // Store feedback per future model retraining
    final feedbackData = {
      'description': description,
      'amount': amount,
      'predicted_category': predictedCategoryId,
      'actual_category': actualCategoryId,
      'confidence': confidence,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    // Save to local database per future model updates
    await DatabaseHelper.instance.insertMLFeedback(feedbackData);
    
    print('User feedback recorded for future learning');
  }
  
  void dispose() {
    _interpreter.close();
  }
}

class CategoryPrediction {
  final String categoryId;
  final double confidence;
  final String explanation;
  final List<AlternativeCategory> alternativeCategories;
  
  CategoryPrediction({
    required this.categoryId,
    required this.confidence,
    required this.explanation,
    required this.alternativeCategories,
  });
}

class AlternativeCategory {
  final String categoryId;
  final double confidence;
  
  AlternativeCategory({
    required this.categoryId,
    required this.confidence,
  });
}
```

#### RF004.2 - Pattern Recognition System
**ID**: RF004.2  
**Priorità**: MEDIA  
**User Story**: "Come utente, voglio che l'app riconosca le mie spese ricorrenti e mi suggerisca automatizzazioni"

**Recurring Pattern Detection**:
```dart
class RecurringTransactionDetector {
  static const int MIN_OCCURRENCES = 3;
  static const int MAX_DAY_VARIANCE = 5;
  static const double MAX_AMOUNT_VARIANCE = 0.1; // 10%
  
  Future<List<RecurringPattern>> detectRecurringPatterns(
    List<Transaction> transactions
  ) async {
    Map<String, List<Transaction>> groupedByDescription = {};
    
    // 1. Group transactions by similar descriptions
    for (Transaction transaction in transactions) {
      String normalizedDesc = _normalizeDescription(transaction.description ?? '');
      if (normalizedDesc.isEmpty) continue;
      
      String groupKey = _findSimilarGroup(groupedByDescription.keys, normalizedDesc);
      
      if (groupKey.isEmpty) {
        groupedByDescription[normalizedDesc] = [transaction];
      } else {
        groupedByDescription[groupKey]!.add(transaction);
      }
    }
    
    // 2. Analyze each group per recurring patterns
    List<RecurringPattern> patterns = [];
    
    for (String description in groupedByDescription.keys) {
      List<Transaction> groupTransactions = groupedByDescription[description]!;
      if (groupTransactions.length < MIN_OCCURRENCES) continue;
      
      RecurringPattern? pattern = _analyzeGroupForPattern(groupTransactions);
      if (pattern != null) {
        patterns.add(pattern);
      }
    }
    
    // 3. Sort by confidence/frequency
    patterns.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    return patterns;
  }
  
  String _normalizeDescription(String description) {
    return description
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
  
  String _findSimilarGroup(Iterable<String> existingGroups, String newDesc) {
    for (String existingDesc in existingGroups) {
      double similarity = _calculateSimilarity(existingDesc, newDesc);
      if (similarity > 0.8) { // 80% similarity threshold
        return existingDesc;
      }
    }
    return '';
  }
  
  double _calculateSimilarity(String str1, String str2) {
    // Simple Jaccard similarity per ora
    Set<String> words1 = str1.split(' ').toSet();
    Set<String> words2 = str2.split(' ').toSet();
    
    Set<String> intersection = words1.intersection(words2);
    Set<String> union = words1.union(words2);
    
    return union.isEmpty ? 0.0 : intersection.length / union.length;
  }
  
  RecurringPattern? _analyzeGroupForPattern(List<Transaction> transactions) {
    transactions.sort((a, b) => a.date.compareTo(b.date));
    
    // Calculate intervals between transactions
    List<int> intervals = [];
    for (int i = 1; i < transactions.length; i++) {
      int daysDiff = transactions[i].date.difference(transactions[i-1].date).inDays;
      intervals.add(daysDiff);
    }
    
    // Analyze interval patterns
    PatternType patternType = _detectIntervalPattern(intervals);
    if (patternType == PatternType.none) return null;
    
    // Calculate average amount e variance
    double avgAmount = transactions.fold(0.0, (sum, t) => sum + t.amount) / transactions.length;
    double amountVariance = _calculateAmountVariance(transactions, avgAmount);
    
    if (amountVariance > MAX_AMOUNT_VARIANCE) return null;
    
    // Calculate confidence based on consistency
    double confidence = _calculatePatternConfidence(intervals, amountVariance);
    
    return RecurringPattern(
      description: transactions.first.description ?? '',
      categoryId: transactions.first.categoryId,
      averageAmount: avgAmount,
      patternType: patternType,
      intervalDays: _calculateTypicalInterval(intervals),
      occurrences: transactions.length,
      confidence: confidence,
      lastOccurrence: transactions.last.date,
      nextExpectedDate: _predictNextOccurrence(transactions.last.date, patternType),
      transactions: transactions,
    );
  }
  
  PatternType _detectIntervalPattern(List<int> intervals) {
    if (intervals.isEmpty) return PatternType.none;
    
    // Check for monthly pattern (28-31 days)
    if (_isConsistentInterval(intervals, 30, 5)) {
      return PatternType.monthly;
    }
    
    // Check for weekly pattern (7 days ±2)
    if (_isConsistentInterval(intervals, 7, 2)) {
      return PatternType.weekly;
    }
    
    // Check for bi-weekly pattern (14 days ±3)
    if (_isConsistentInterval(intervals, 14, 3)) {
      return PatternType.biweekly;
    }
    
    // Check for quarterly pattern (~90 days)
    if (_isConsistentInterval(intervals, 90, 10)) {
      return PatternType.quarterly;
    }
    
    return PatternType.none;
  }
  
  bool _isConsistentInterval(List<int> intervals, int expectedInterval, int tolerance) {
    int consistentCount = 0;
    for (int interval in intervals) {
      if ((interval - expectedInterval).abs() <= tolerance) {
        consistentCount++;
      }
    }
    
    // Almeno 70% degli intervalli devono essere consistenti
    return consistentCount / intervals.length >= 0.7;
  }
  
  double _calculateAmountVariance(List<Transaction> transactions, double avgAmount) {
    double sumSquaredDiff = 0.0;
    for (Transaction t in transactions) {
      double diff = t.amount - avgAmount;
      sumSquaredDiff += diff * diff;
    }
    
    double variance = sumSquaredDiff / transactions.length;
    double stdDev = math.sqrt(variance);
    
    return avgAmount != 0 ? stdDev / avgAmount.abs() : 0.0;
  }
  
  double _calculatePatternConfidence(List<int> intervals, double amountVariance) {
    // Base confidence on interval consistency
    double intervalConsistency = 1.0 - (intervals.isEmpty ? 0 : 
        intervals.map((i) => (i - intervals.first).abs()).reduce((a, b) => a + b) / 
        (intervals.length * intervals.first));
    
    // Factor in amount consistency
    double amountConsistency = 1.0 - amountVariance;
    
    // Weighted average
    return (intervalConsistency * 0.7 + amountConsistency * 0.3).clamp(0.0, 1.0);
  }
  
  int _calculateTypicalInterval(List<int> intervals) {
    if (intervals.isEmpty) return 0;
    
    intervals.sort();
    int medianIndex = intervals.length ~/ 2;
    return intervals[medianIndex];
  }
  
  DateTime _predictNextOccurrence(DateTime lastDate, PatternType patternType) {
    switch (patternType) {
      case PatternType.weekly:
        return lastDate.add(Duration(days: 7));
      case PatternType.biweekly:
        return lastDate.add(Duration(days: 14));
      case PatternType.monthly:
        return DateTime(lastDate.year, lastDate.month + 1, lastDate.day);
      case PatternType.quarterly:
        return DateTime(lastDate.year, lastDate.month + 3, lastDate.day);
      default:
        return lastDate;
    }
  }
}

class RecurringPattern {
  final String description;
  final String categoryId;
  final double averageAmount;
  final PatternType patternType;
  final int intervalDays;
  final int occurrences;
  final double confidence;
  final DateTime lastOccurrence;
  final DateTime nextExpectedDate;
  final List<Transaction> transactions;
  
  RecurringPattern({
    required this.description,
    required this.categoryId,
    required this.averageAmount,
    required this.patternType,
    required this.intervalDays,
    required this.occurrences,
    required this.confidence,
    required this.lastOccurrence,
    required this.nextExpectedDate,
    required this.transactions,
  });
  
  bool get isOverdue {
    return DateTime.now().isAfter(nextExpectedDate.add(Duration(days: 3)));
  }
  
  String get patternDescription {
    switch (patternType) {
      case PatternType.weekly:
        return 'Settimanale';
      case PatternType.biweekly:
        return 'Quindicinale';
      case PatternType.monthly:
        return 'Mensile';
      case PatternType.quarterly:
        return 'Trimestrale';
      default:
        return 'Irregolare';
    }
  }
}

enum PatternType {
  none,
  weekly,
  biweekly,
  monthly,
  quarterly,
}
```

---

## CONTINUA...

Questo è il primo documento della serie. Vuoi che continui con gli altri documenti di specifica?

I prossimi documenti saranno:
1. **Specifica Tecnica e Architettura** (database schema, API design, performance)
2. **Design System e UI/UX Specifications** (component library, wireframes, style guide)  
3. **Testing Plan e Quality Assurance** (unit tests, integration tests, acceptance criteria)
4. **Deployment e Release Management** (build configs, store submissions, CI/CD)
5. **Project Management e Timeline** (milestone details, resource allocation)
6. **Business Requirements Document** (market analysis, pricing strategy, success metrics)

Dimmi quale vuoi che completi per prossimo!
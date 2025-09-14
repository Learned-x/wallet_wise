# Budget Tracker Smart v1.0.0 - Specifica Tecnica e Architettura

**Documento**: Specifica Tecnica e Architettura v1.0.0  
**Progetto**: Budget Tracker Smart  
**Versione Documento**: 1.0  
**Data**: 13 Settembre 2025  
**Autore**: Development Team  
**Stato**: APPROVATO per implementazione

---

## 1. PANORAMICA ARCHITETTURALE

### 1.1 Principi Architetturali
- **Offline-First**: Tutte le funzionalità devono operare senza connessione internet
- **Privacy by Design**: Nessun dato utente lascia mai il dispositivo
- **Performance-Oriented**: Response time <500ms per tutte le operazioni principali
- **Scalable Local**: Supporto fino a 50.000 transazioni per utente
- **Clean Architecture**: Separazione netta tra UI, Business Logic e Data Layer

### 1.2 Stack Tecnologico Completo

#### 1.2.1 Frontend Mobile
```yaml
Framework: Flutter 3.24.3+
Language: Dart 3.5.0+
State Management: Riverpod 2.4.9
UI Framework: Material Design 3
Navigation: Go Router 12.1.1
Local Database: SQLite + sqflite 2.3.0
File Storage: path_provider 2.1.1
```

#### 1.2.2 Machine Learning & AI
```yaml
OCR Engine: Google ML Kit Text Recognition 0.12.0
ML Framework: TensorFlow Lite Flutter 0.10.1
Image Processing: image 4.1.3
Camera: camera 0.10.5+8
```

#### 1.2.3 Data & Storage
```yaml
Local Database: SQLite 3.43+
ORM: drift 2.12.1
Encryption: sqlcipher via sqlite3_flutter_libs 0.5.15
File Encryption: encrypt 5.0.1
Secure Storage: flutter_secure_storage 9.0.0
```

#### 1.2.4 Utilities & Tools
```yaml
Charts: fl_chart 0.66.0
Date Handling: intl 0.18.1
File Operations: path 1.8.3
Image Compression: flutter_image_compress 2.0.4
Sharing: share_plus 7.2.1
Permissions: permission_handler 11.0.1
```

### 1.3 Architettura a Livelli

```
┌─────────────────────────────────────────────────────────┐
│                 PRESENTATION LAYER                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
│  │   Screens   │ │   Widgets   │ │   Controllers   │   │
│  │   (Pages)   │ │  (Components│ │   (Providers)   │   │
│  └─────────────┘ └─────────────┘ └─────────────────┘   │
├─────────────────────────────────────────────────────────┤
│                 BUSINESS LOGIC LAYER                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
│  │   Services  │ │  Use Cases  │ │  Repositories   │   │
│  │             │ │             │ │   (Abstract)    │   │
│  └─────────────┘ └─────────────┘ └─────────────────┘   │
├─────────────────────────────────────────────────────────┤
│                    DATA LAYER                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
│  │   SQLite    │ │File Storage │ │   ML Models     │   │
│  │  Database   │ │   System    │ │   (TFLite)      │   │
│  └─────────────┘ └─────────────┘ └─────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 2. LAYER DETTAGLIATO - PRESENTATION

### 2.1 Screen Architecture

#### 2.1.1 Struttura Directory Screens
```
lib/
├── presentation/
│   ├── screens/
│   │   ├── dashboard/
│   │   │   ├── dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── health_score_widget.dart
│   │   │       ├── insights_cards_widget.dart
│   │   │       ├── mood_indicator_widget.dart
│   │   │       └── weekly_trend_widget.dart
│   │   ├── transactions/
│   │   │   ├── transactions_list_screen.dart
│   │   │   ├── add_transaction_screen.dart
│   │   │   ├── edit_transaction_screen.dart
│   │   │   └── widgets/
│   │   │       ├── transaction_form_widget.dart
│   │   │       ├── category_selector_widget.dart
│   │   │       ├── amount_input_widget.dart
│   │   │       └── transaction_list_item_widget.dart
│   │   ├── receipts/
│   │   │   ├── camera_screen.dart
│   │   │   ├── receipt_gallery_screen.dart
│   │   │   ├── receipt_detail_screen.dart
│   │   │   └── widgets/
│   │   │       ├── camera_overlay_widget.dart
│   │   │       ├── ocr_results_widget.dart
│   │   │       └── receipt_thumbnail_widget.dart
│   │   ├── reports/
│   │   │   ├── reports_screen.dart
│   │   │   ├── monthly_report_screen.dart
│   │   │   ├── yearly_report_screen.dart
│   │   │   └── widgets/
│   │   │       ├── expense_chart_widget.dart
│   │   │       ├── category_breakdown_widget.dart
│   │   │       └── export_options_widget.dart
│   │   ├── settings/
│   │   │   ├── settings_screen.dart
│   │   │   ├── categories_screen.dart
│   │   │   ├── backup_screen.dart
│   │   │   └── widgets/
│   │   │       ├── settings_tile_widget.dart
│   │   │       ├── category_editor_widget.dart
│   │   │       └── backup_progress_widget.dart
│   │   └── onboarding/
│   │       ├── onboarding_screen.dart
│   │       ├── welcome_screen.dart
│   │       └── setup_categories_screen.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_app_bar.dart
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   └── empty_state_widget.dart
│   │   └── specialized/
│   │       ├── currency_input_widget.dart
│   │       ├── date_picker_widget.dart
│   │       ├── icon_selector_widget.dart
│   │       └── color_picker_widget.dart
│   └── providers/
│       ├── dashboard_provider.dart
│       ├── transactions_provider.dart
│       ├── receipts_provider.dart
│       ├── reports_provider.dart
│       ├── settings_provider.dart
│       └── app_state_provider.dart
```

#### 2.1.2 Base Screen Template
```dart
// Base class per tutti gli screens
abstract class BaseScreen extends ConsumerStatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);
  
  @override
  BaseScreenState createState();
}

abstract class BaseScreenState<T extends BaseScreen> extends ConsumerState<T> {
  bool _isLoading = false;
  String? _errorMessage;
  
  // Lifecycle methods che ogni screen può override
  @override
  void initState() {
    super.initState();
    onInitState();
  }
  
  void onInitState() {
    // Override in subclasses per initialization logic
  }
  
  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
        if (loading) _errorMessage = null;
      });
    }
  }
  
  void setError(String error) {
    if (mounted) {
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });
    }
  }
  
  void clearError() {
    if (mounted) {
      setState(() => _errorMessage = null);
    }
  }
  
  // Template method pattern
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: buildFloatingActionButton(context),
      bottomNavigationBar: buildBottomNavigation(context),
    );
  }
  
  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return ErrorWidget(
        message: _errorMessage!,
        onRetry: onRetryAfterError,
      );
    }
    
    return buildContent(context);
  }
  
  // Abstract methods da implementare nelle subclasses
  PreferredSizeWidget? buildAppBar(BuildContext context);
  Widget buildContent(BuildContext context);
  Widget? buildFloatingActionButton(BuildContext context) => null;
  Widget? buildBottomNavigation(BuildContext context) => null;
  
  // Error handling
  void onRetryAfterError() {
    clearError();
    onInitState();
  }
  
  // Common utility methods
  void showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Conferma',
    String cancelText = 'Annulla',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}
```

### 2.2 State Management con Riverpod

#### 2.2.1 Provider Architecture
```dart
// Core providers structure

// Database provider - singleton
final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Repository providers
final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  final database = ref.read(databaseProvider);
  return TransactionsRepositoryImpl(database);
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  final database = ref.read(databaseProvider);
  return CategoriesRepositoryImpl(database);
});

final receiptsRepositoryProvider = Provider<ReceiptsRepository>((ref) {
  final database = ref.read(databaseProvider);
  return ReceiptsRepositoryImpl(database);
});

// Service providers
final ocrServiceProvider = Provider<OCRService>((ref) {
  return GoogleMLKitOCRService();
});

final mlCategorizationProvider = Provider<MLCategorizationService>((ref) {
  return LocalMLCategorizationService();
});

final healthScoreServiceProvider = Provider<HealthScoreService>((ref) {
  final transactionsRepo = ref.read(transactionsRepositoryProvider);
  return HealthScoreServiceImpl(transactionsRepo);
});

// State providers (business logic)
final transactionsProvider = StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>((ref) {
  final repository = ref.read(transactionsRepositoryProvider);
  final mlService = ref.read(mlCategorizationProvider);
  return TransactionsNotifier(repository, mlService);
});

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  final repository = ref.read(categoriesRepositoryProvider);
  return CategoriesNotifier(repository);
});

final healthScoreProvider = StateNotifierProvider<HealthScoreNotifier, AsyncValue<HealthScore>>((ref) {
  final service = ref.read(healthScoreServiceProvider);
  return HealthScoreNotifier(service);
});

final receiptsProvider = StateNotifierProvider<ReceiptsNotifier, AsyncValue<List<ReceiptPhoto>>>((ref) {
  final repository = ref.read(receiptsRepositoryProvider);
  final ocrService = ref.read(ocrServiceProvider);
  return ReceiptsNotifier(repository, ocrService);
});

// UI state providers
final selectedDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

final transactionFiltersProvider = StateProvider<TransactionFilters>((ref) {
  return TransactionFilters();
});

final dashboardRefreshProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Reports providers
final monthlyReportProvider = FutureProvider.family<MonthlyReport, DateTime>((ref, month) {
  final repository = ref.read(transactionsRepositoryProvider);
  final service = ReportsService(repository);
  return service.generateMonthlyReport(month);
});

final yearlyReportProvider = FutureProvider.family<YearlyReport, int>((ref, year) {
  final repository = ref.read(transactionsRepositoryProvider);
  final service = ReportsService(repository);
  return service.generateYearlyReport(year);
});
```

#### 2.2.2 StateNotifier Implementation Example
```dart
class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final TransactionsRepository _repository;
  final MLCategorizationService _mlService;
  
  TransactionsNotifier(this._repository, this._mlService) 
      : super(const AsyncValue.loading()) {
    loadTransactions();
  }
  
  Future<void> loadTransactions({TransactionFilters? filters}) async {
    try {
      state = const AsyncValue.loading();
      final transactions = await _repository.getTransactions(filters: filters);
      state = AsyncValue.data(transactions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> addTransaction(TransactionInput input) async {
    try {
      // Predict category if not provided
      String? predictedCategory;
      if (input.categoryId == null && input.description != null) {
        final prediction = await _mlService.predictCategory(
          input.description!, 
          input.amount,
        );
        predictedCategory = prediction?.categoryId;
      }
      
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: input.amount,
        categoryId: input.categoryId ?? predictedCategory ?? 'other',
        description: input.description,
        date: input.date ?? DateTime.now(),
        receiptPhotoPath: input.receiptPhotoPath,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _repository.insertTransaction(transaction);
      await loadTransactions(); // Reload to reflect changes
      
      // Record ML feedback se prediction was made
      if (predictedCategory != null && input.categoryId != null) {
        await _mlService.recordUserFeedback(
          description: input.description ?? '',
          amount: input.amount,
          predictedCategoryId: predictedCategory,
          actualCategoryId: input.categoryId!,
          confidence: 0.8, // Placeholder
        );
      }
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> updateTransaction(String id, TransactionInput input) async {
    try {
      final existingTransaction = await _repository.getTransactionById(id);
      if (existingTransaction == null) {
        throw Exception('Transaction not found');
      }
      
      final updatedTransaction = existingTransaction.copyWith(
        amount: input.amount,
        categoryId: input.categoryId ?? existingTransaction.categoryId,
        description: input.description,
        date: input.date ?? existingTransaction.date,
        receiptPhotoPath: input.receiptPhotoPath,
        updatedAt: DateTime.now(),
      );
      
      await _repository.updateTransaction(updatedTransaction);
      await loadTransactions();
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      await loadTransactions();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
  
  Future<void> refreshTransactions() async {
    await loadTransactions();
  }
}

class HealthScoreNotifier extends StateNotifier<AsyncValue<HealthScore>> {
  final HealthScoreService _service;
  Timer? _refreshTimer;
  
  HealthScoreNotifier(this._service) : super(const AsyncValue.loading()) {
    calculateHealthScore();
    _startPeriodicRefresh();
  }
  
  Future<void> calculateHealthScore() async {
    try {
      state = const AsyncValue.loading();
      final healthScore = await _service.calculateHealthScore();
      state = AsyncValue.data(healthScore);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(
      Duration(minutes: 5), // Refresh every 5 minutes
      (_) => calculateHealthScore(),
    );
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
```

### 2.3 Navigation Architecture

#### 2.3.1 GoRouter Configuration
```dart
// app/router.dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    debugLogDiagnostics: kDebugMode,
    routes: [
      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            builder: (context, state) => const TransactionsListScreen(),
            routes: [
              GoRoute(
                path: '/add',
                name: 'add-transaction',
                builder: (context, state) => const AddTransactionScreen(),
              ),
              GoRoute(
                path: '/edit/:id',
                name: 'edit-transaction',
                builder: (context, state) {
                  final transactionId = state.pathParameters['id']!;
                  return EditTransactionScreen(transactionId: transactionId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/receipts',
            name: 'receipts',
            builder: (context, state) => const ReceiptGalleryScreen(),
            routes: [
              GoRoute(
                path: '/camera',
                name: 'camera',
                builder: (context, state) => const CameraScreen(),
              ),
              GoRoute(
                path: '/detail/:id',
                name: 'receipt-detail',
                builder: (context, state) {
                  final receiptId = state.pathParameters['id']!;
                  return ReceiptDetailScreen(receiptId: receiptId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
            routes: [
              GoRoute(
                path: '/monthly/:year/:month',
                name: 'monthly-report',
                builder: (context, state) {
                  final year = int.parse(state.pathParameters['year']!);
                  final month = int.parse(state.pathParameters['month']!);
                  return MonthlyReportScreen(year: year, month: month);
                },
              ),
              GoRoute(
                path: '/yearly/:year',
                name: 'yearly-report',
                builder: (context, state) {
                  final year = int.parse(state.pathParameters['year']!);
                  return YearlyReportScreen(year: year);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: '/categories',
                name: 'categories',
                builder: (context, state) => const CategoriesScreen(),
              ),
              GoRoute(
                path: '/backup',
                name: 'backup',
                builder: (context, state) => const BackupScreen(),
              ),
            ],
          ),
        ],
      ),
      
      // Onboarding flow (outside main shell)
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Full-screen routes
      GoRoute(
        path: '/camera-fullscreen',
        name: 'camera-fullscreen',
        builder: (context, state) => const CameraScreen(fullscreen: true),
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    
    // Redirect logic
    redirect: (context, state) {
      final isFirstLaunch = ref.read(settingsProvider).isFirstLaunch;
      
      // Redirect to onboarding if first launch
      if (isFirstLaunch && !state.location.startsWith('/onboarding')) {
        return '/onboarding';
      }
      
      return null; // No redirect needed
    },
  );
});

// Main shell with bottom navigation
class MainShell extends ConsumerWidget {
  final Widget child;
  
  const MainShell({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter.of(context);
    final currentLocation = GoRouterState.of(context).location;
    
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _getCurrentIndex(currentLocation),
        onTap: (index) => _onTabTap(index, router),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transazioni',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Ricevute',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
      ),
    );
  }
  
  int _getCurrentIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/receipts')) return 2;
    if (location.startsWith('/reports')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }
  
  void _onTabTap(int index, GoRouter router) {
    switch (index) {
      case 0:
        router.go('/dashboard');
        break;
      case 1:
        router.go('/transactions');
        break;
      case 2:
        router.go('/receipts');
        break;
      case 3:
        router.go('/reports');
        break;
      case 4:
        router.go('/settings');
        break;
    }
  }
}
```

---

## 3. LAYER DETTAGLIATO - BUSINESS LOGIC

### 3.1 Domain Layer Architecture

#### 3.1.1 Entities (Core Domain Objects)
```dart
// Core domain entities

class Transaction {
  final String id;
  final double amount;
  final String categoryId;
  final String? description;
  final DateTime date;
  final String? receiptPhotoPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  
  const Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    this.description,
    required this.date,
    this.receiptPhotoPath,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  
  // Business logic methods
  bool get isExpense => amount < 0;
  bool get isIncome => amount > 0;
  bool get isDeleted => deletedAt != null;
  bool get hasReceipt => receiptPhotoPath != null;
  
  double get absoluteAmount => amount.abs();
  
  bool isInDateRange(DateTime start, DateTime end) {
    return date.isAfter(start.subtract(Duration(days: 1))) && 
           date.isBefore(end.add(Duration(days: 1)));
  }
  
  Transaction copyWith({
    String? id,
    double? amount,
    String? categoryId,
    String? description,
    DateTime? date,
    String? receiptPhotoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      date: date ?? this.date,
      receiptPhotoPath: receiptPhotoPath ?? this.receiptPhotoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}

class Category {
  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final bool isIncome;
  final bool isCustom;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  
  const Category({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.isIncome,
    required this.isCustom,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  
  // Business logic methods
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
  bool get isDeleted => deletedAt != null;
  bool get isPredefined => !isCustom;
  
  Category copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
    bool? isIncome,
    bool? isCustom,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      isIncome: isIncome ?? this.isIncome,
      isCustom: isCustom ?? this.isCustom,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class HealthScore {
  final double score;
  final HealthMood mood;
  final String message;
  final List<HealthInsight> insights;
  final DateTime calculatedAt;
  final HealthScoreBreakdown breakdown;
  
  const HealthScore({
    required this.score,
    required this.mood,
    required this.message,
    required this.insights,
    required this.calculatedAt,
    required this.breakdown,
  });
  
  // Business logic methods
  bool get isExcellent => score >= 80;
  bool get isGood => score >= 60 && score < 80;
  bool get isAverage => score >= 40 && score < 60;
  bool get isPoor => score >= 20 && score < 40;
  bool get isCritical => score < 20;
  
  Color get color {
    if (isExcellent) return Color(0xFF4CAF50);
    if (isGood) return Color(0xFF8BC34A);
    if (isAverage) return Color(0xFFFF9800);
    if (isPoor) return Color(0xFFFF5722);
    return Color(0xFFF44336);
  }
  
  String get emoji {
    switch (mood) {
      case HealthMood.excellent:
        return '😊';
      case HealthMood.good:
        return '🙂';
      case HealthMood.average:
        return '😐';
      case HealthMood.poor:
        return '😟';
      case HealthMood.critical:
        return '😰';
    }
  }
}

enum HealthMood {
  excellent,
  good,
  average,
  poor,
  critical,
}

class HealthScoreBreakdown {
  final double budgetAdherence;
  final double savingsRate;
  final double spendingConsistency;
  final double improvementTrend;
  
  const HealthScoreBreakdown({
    required this.budgetAdherence,
    required this.savingsRate,
    required this.spendingConsistency,
    required this.improvementTrend,
  });
}

class HealthInsight {
  final String title;
  final String description;
  final HealthInsightType type;
  final HealthInsightPriority priority;
  
  const HealthInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
  });
}

enum HealthInsightType {
  budget,
  savings,
  spending,
  trend,
}

enum HealthInsightPriority {
  low,
  medium,
  high,
  critical,
}
```

#### 3.1.2 Repository Interfaces (Domain Contracts)
```dart
// Domain repository interfaces

abstract class TransactionsRepository {
  Future<List<Transaction>> getTransactions({
    TransactionFilters? filters,
    int? limit,
    int? offset,
  });
  
  Future<Transaction?> getTransactionById(String id);
  
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  
  Future<List<Transaction>> getTransactionsByCategory(String categoryId);
  
  Future<void> insertTransaction(Transaction transaction);
  
  Future<void> updateTransaction(Transaction transaction);
  
  Future<void> deleteTransaction(String id);
  
  Future<void> softDeleteTransaction(String id);
  
  Future<int> getTransactionCount();
  
  Future<double> getTotalSpending({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  });
  
  Future<double> getTotalIncome({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  });
  
  Future<List<Transaction>> searchTransactions(String query);
  
  Future<Map<String, double>> getSpendingByCategory({
    DateTime? startDate,
    DateTime? endDate,
  });
}

abstract class CategoriesRepository {
  Future<List<Category>> getCategories({bool includeDeleted = false});
  
  Future<Category?> getCategoryById(String id);
  
  Future<List<Category>> getIncomeCategories();
  
  Future<List<Category>> getExpenseCategories();
  
  Future<List<Category>> getCustomCategories();
  
  Future<void> insertCategory(Category category);
  
  Future<void> updateCategory(Category category);
  
  Future<void> deleteCategory(String id);
  
  Future<void> reorderCategories(List<String> categoryIds);
  
  Future<bool> isCategoryInUse(String categoryId);
}

abstract class ReceiptsRepository {
  Future<List<ReceiptPhoto>> getReceipts();
  
  Future<ReceiptPhoto?> getReceiptById(String id);
  
  Future<List<ReceiptPhoto>> getReceiptsByTransaction(String transactionId);
  
  Future<void> insertReceipt(ReceiptPhoto receipt);
  
  Future<void> updateReceipt(ReceiptPhoto receipt);
  
  Future<void> deleteReceipt(String id);
  
  Future<void> deleteReceiptsByTransaction(String transactionId);
  
  Future<int> cleanupOrphanedReceipts();
  
  Future<String> exportAllReceipts();
}
```

### 3.2 Use Cases (Application Services)

#### 3.2.1 Transaction Use Cases
```dart
// Use case per gestione transazioni

class AddTransactionUseCase {
  final TransactionsRepository _transactionsRepo;
  final CategoriesRepository _categoriesRepo;
  final MLCategorizationService _mlService;
  final HealthScoreService _healthScoreService;
  
  AddTransactionUseCase({
    required TransactionsRepository transactionsRepo,
    required CategoriesRepository categoriesRepo,
    required MLCategorizationService mlService,
    required HealthScoreService healthScoreService,
  }) : _transactionsRepo = transactionsRepo,
       _categoriesRepo = categoriesRepo,
       _mlService = mlService,
       _healthScoreService = healthScoreService;
  
  Future<Transaction> execute(AddTransactionInput input) async {
    // 1. Validate input
    _validateInput(input);
    
    // 2. Predict category if not provided
    String categoryId = input.categoryId ?? await _predictCategory(input);
    
    // 3. Validate category exists
    final category = await _categoriesRepo.getCategoryById(categoryId);
    if (category == null || category.isDeleted) {
      throw DomainException('Invalid category');
    }
    
    // 4. Create transaction
    final transaction = Transaction(
      id: _generateTransactionId(),
      amount: input.amount,
      categoryId: categoryId,
      description: input.description,
      date: input.date ?? DateTime.now(),
      receiptPhotoPath: input.receiptPhotoPath,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // 5. Save transaction
    await _transactionsRepo.insertTransaction(transaction);
    
    // 6. Record ML feedback if prediction was made
    if (input.categoryId == null && input.description != null) {
      await _mlService.recordUserFeedback(
        description: input.description!,
        amount: input.amount,
        predictedCategoryId: categoryId,
        actualCategoryId: categoryId,
        confidence: 0.8,
      );
    }
    
    // 7. Trigger health score recalculation (async)
    _healthScoreService.invalidateCache();
    
    return transaction;
  }
  
  void _validateInput(AddTransactionInput input) {
    if (input.amount == 0) {
      throw DomainException('Amount cannot be zero');
    }
    
    if (input.amount.abs() > 999999.99) {
      throw DomainException('Amount too large');
    }
    
    if (input.description != null && input.description!.length > 200) {
      throw DomainException('Description too long');
    }
    
    if (input.date != null) {
      final now = DateTime.now();
      if (input.date!.isAfter(now.add(Duration(days: 7)))) {
        throw DomainException('Date cannot be more than 7 days in the future');
      }
      
      if (input.date!.isBefore(DateTime(2020, 1, 1))) {
        throw DomainException('Date cannot be before 2020');
      }
    }
  }
  
  Future<String> _predictCategory(AddTransactionInput input) async {
    if (input.description == null || input.description!.isEmpty) {
      return 'other'; // Default fallback
    }
    
    try {
      final prediction = await _mlService.predictCategory(
        input.description!,
        input.amount,
      );
      
      if (prediction != null && prediction.confidence > 0.6) {
        return prediction.categoryId;
      }
    } catch (e) {
      // ML prediction failed, use fallback
      print('ML prediction failed: $e');
    }
    
    return 'other';
  }
  
  String _generateTransactionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

class GetTransactionsUseCase {
  final TransactionsRepository _repository;
  
  GetTransactionsUseCase({required TransactionsRepository repository})
      : _repository = repository;
  
  Future<List<Transaction>> execute({
    TransactionFilters? filters,
    TransactionSortOptions? sortOptions,
    int? limit,
    int? offset,
  }) async {
    // 1. Get transactions from repository
    List<Transaction> transactions = await _repository.getTransactions(
      filters: filters,
      limit: limit,
      offset: offset,
    );
    
    // 2. Apply sorting
    if (sortOptions != null) {
      transactions = _applySorting(transactions, sortOptions);
    }
    
    return transactions;
  }
  
  List<Transaction> _applySorting(
    List<Transaction> transactions,
    TransactionSortOptions options,
  ) {
    switch (options.sortBy) {
      case TransactionSortBy.date:
        transactions.sort((a, b) {
          final comparison = options.ascending 
              ? a.date.compareTo(b.date)
              : b.date.compareTo(a.date);
          return comparison;
        });
        break;
      case TransactionSortBy.amount:
        transactions.sort((a, b) {
          final comparison = options.ascending
              ? a.absoluteAmount.compareTo(b.absoluteAmount)
              : b.absoluteAmount.compareTo(a.absoluteAmount);
          return comparison;
        });
        break;
      case TransactionSortBy.category:
        transactions.sort((a, b) {
          final comparison = options.ascending
              ? a.categoryId.compareTo(b.categoryId)
              : b.categoryId.compareTo(a.categoryId);
          return comparison;
        });
        break;
    }
    
    return transactions;
  }
}

class UpdateTransactionUseCase {
  final TransactionsRepository _transactionsRepo;
  final CategoriesRepository _categoriesRepo;
  final HealthScoreService _healthScoreService;
  
  UpdateTransactionUseCase({
    required TransactionsRepository transactionsRepo,
    required CategoriesRepository categoriesRepo,
    required HealthScoreService healthScoreService,
  }) : _transactionsRepo = transactionsRepo,
       _categoriesRepo = categoriesRepo,
       _healthScoreService = healthScoreService;
  
  Future<Transaction> execute(String transactionId, UpdateTransactionInput input) async {
    // 1. Get existing transaction
    final existingTransaction = await _transactionsRepo.getTransactionById(transactionId);
    if (existingTransaction == null || existingTransaction.isDeleted) {
      throw DomainException('Transaction not found');
    }
    
    // 2. Check if transaction is too old to edit (business rule)
    final twelveMonthsAgo = DateTime.now().subtract(Duration(days: 365));
    if (existingTransaction.date.isBefore(twelveMonthsAgo)) {
      throw DomainException('Cannot edit transactions older than 12 months');
    }
    
    // 3. Validate new category if provided
    if (input.categoryId != null) {
      final category = await _categoriesRepo.getCategoryById(input.categoryId!);
      if (category == null || category.isDeleted) {
        throw DomainException('Invalid category');
      }
    }
    
    // 4. Create updated transaction
    final updatedTransaction = existingTransaction.copyWith(
      amount: input.amount ?? existingTransaction.amount,
      categoryId: input.categoryId ?? existingTransaction.categoryId,
      description: input.description ?? existingTransaction.description,
      date: input.date ?? existingTransaction.date,
      receiptPhotoPath: input.receiptPhotoPath ?? existingTransaction.receiptPhotoPath,
      updatedAt: DateTime.now(),
    );
    
    // 5. Save updated transaction
    await _transactionsRepo.updateTransaction(updatedTransaction);
    
    // 6. Trigger health score recalculation if significant change
    if (_isSignificantChange(existingTransaction, updatedTransaction)) {
      _healthScoreService.invalidateCache();
    }
    
    return updatedTransaction;
  }
  
  bool _isSignificantChange(Transaction old, Transaction updated) {
    // Significant if amount or category changed
    return old.amount != updated.amount || old.categoryId != updated.categoryId;
  }
}

class DeleteTransactionUseCase {
  final TransactionsRepository _transactionsRepo;
  final ReceiptsRepository _receiptsRepo;
  final HealthScoreService _healthScoreService;
  
  DeleteTransactionUseCase({
    required TransactionsRepository transactionsRepo,
    required ReceiptsRepository receiptsRepo,
    required HealthScoreService healthScoreService,
  }) : _transactionsRepo = transactionsRepo,
       _receiptsRepo = receiptsRepo,
       _healthScoreService = healthScoreService;
  
  Future<void> execute(String transactionId) async {
    // 1. Get transaction to verify it exists
    final transaction = await _transactionsRepo.getTransactionById(transactionId);
    if (transaction == null || transaction.isDeleted) {
      throw DomainException('Transaction not found');
    }
    
    // 2. Soft delete transaction
    await _transactionsRepo.softDeleteTransaction(transactionId);
    
    // 3. Keep receipt photos for potential recovery
    // Note: Receipts are not deleted immediately to allow for undo
    
    // 4. Trigger health score recalculation
    _healthScoreService.invalidateCache();
  }
}
```

#### 3.2.2 Health Score Use Cases
```dart
class CalculateHealthScoreUseCase {
  final TransactionsRepository _transactionsRepo;
  
  CalculateHealthScoreUseCase({
    required TransactionsRepository transactionsRepo,
  }) : _transactionsRepo = transactionsRepo;
  
  Future<HealthScore> execute() async {
    // Get transactions from last 90 days per analysis
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: 90));
    
    final transactions = await _transactionsRepo.getTransactionsByDateRange(
      startDate,
      endDate,
    );
    
    // Calculate each component
    final budgetAdherence = await _calculateBudgetAdherence(transactions);
    final savingsRate = _calculateSavingsRate(transactions);
    final spendingConsistency = _calculateSpendingConsistency(transactions);
    final improvementTrend = _calculateImprovementTrend(transactions);
    
    // Calculate weighted score
    final score = (budgetAdherence * 0.4) +
                  (savingsRate * 0.3) +
                  (spendingConsistency * 0.2) +
                  (improvementTrend * 0.1);
    
    // Create breakdown
    final breakdown = HealthScoreBreakdown(
      budgetAdherence: budgetAdherence,
      savingsRate: savingsRate,
      spendingConsistency: spendingConsistency,
      improvementTrend: improvementTrend,
    );
    
    // Generate insights
    final insights = _generateInsights(breakdown, transactions);
    
    // Determine mood and message
    final mood = _determineMood(score);
    final message = _generateMessage(mood, score);
    
    return HealthScore(
      score: score,
      mood: mood,
      message: message,
      insights: insights,
      calculatedAt: DateTime.now(),
      breakdown: breakdown,
    );
  }
  
  Future<double> _calculateBudgetAdherence(List<Transaction> transactions) async {
    // For v1.0.0, assume default budgets or return neutral score
    // In future versions, this would check against user-set budgets
    
    final currentMonth = DateTime.now();
    final monthStart = DateTime(currentMonth.year, currentMonth.month, 1);
    final monthEnd = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    
    final monthlyTransactions = transactions.where(
      (t) => t.isInDateRange(monthStart, monthEnd)
    ).toList();
    
    final totalSpending = monthlyTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.absoluteAmount);
    
    final totalIncome = monthlyTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    if (totalIncome <= 0) return 50.0; // Neutral if no income data
    
    final spendingRatio = totalSpending / totalIncome;
    
    // Good adherence if spending less than 80% of income
    if (spendingRatio <= 0.8) return 100.0;
    if (spendingRatio <= 0.9) return 80.0;
    if (spendingRatio <= 1.0) return 60.0;
    if (spendingRatio <= 1.2) return 30.0;
    return 0.0;
  }
  
  double _calculateSavingsRate(List<Transaction> transactions) {
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalExpenses = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.absoluteAmount);
    
    if (totalIncome <= 0) return 0.0;
    
    final savings = totalIncome - totalExpenses;
    final savingsRate = (savings / totalIncome) * 100;
    
    return math.max(0.0, math.min(100.0, savingsRate));
  }
  
  double _calculateSpendingConsistency(List<Transaction> transactions) {
    // Group transactions by day
    final Map<String, double> dailySpending = {};
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      dailySpending[dateKey] = (dailySpending[dateKey] ?? 0) + transaction.absoluteAmount;
    }
    
    final values = dailySpending.values.toList();
    if (values.length < 7) return 70.0; // Default for insufficient data
    
    final mean = values.fold(0.0, (a, b) => a + b) / values.length;
    final variance = values
        .map((x) => math.pow(x - mean, 2))
        .fold(0.0, (a, b) => a + b) / values.length;
    
    final stdDev = math.sqrt(variance);
    final coefficientOfVariation = mean > 0 ? stdDev / mean : 0.0;
    
    // Lower variation = higher consistency = higher score
    return math.max(0.0, 100.0 - (coefficientOfVariation * 100));
  }
  
  double _calculateImprovementTrend(List<Transaction> transactions) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30));
    final sixtyDaysAgo = now.subtract(Duration(days: 60));
    
    final recentSpending = transactions
        .where((t) => t.isExpense && t.date.isAfter(thirtyDaysAgo))
        .fold(0.0, (sum, t) => sum + t.absoluteAmount);
    
    final previousSpending = transactions
        .where((t) => t.isExpense && 
                     t.date.isAfter(sixtyDaysAgo) && 
                     t.date.isBefore(thirtyDaysAgo))
        .fold(0.0, (sum, t) => sum + t.absoluteAmount);
    
    if (previousSpending <= 0) return 50.0; // Neutral
    
    final improvement = ((previousSpending - recentSpending) / previousSpending) * 100;
    
    // Normalize to 0-100 scale
    return math.max(0.0, math.min(100.0, 50.0 + (improvement * 2.5)));
  }
  
  HealthMood _determineMood(double score) {
    if (score >= 80) return HealthMood.excellent;
    if (score >= 60) return HealthMood.good;
    if (score >= 40) return HealthMood.average;
    if (score >= 20) return HealthMood.poor;
    return HealthMood.critical;
  }
  
  String _generateMessage(HealthMood mood, double score) {
    switch (mood) {
      case HealthMood.excellent:
        return 'Eccellente controllo delle finanze!';
      case HealthMood.good:
        return 'Stai gestendo bene il tuo budget.';
      case HealthMood.average:
        return 'Puoi migliorare il controllo delle spese.';
      case HealthMood.poor:
        return 'È necessario rivedere le tue abitudini.';
      case HealthMood.critical:
        return 'Situazione finanziaria critica.';
    }
  }
  
  List<HealthInsight> _generateInsights(
    HealthScoreBreakdown breakdown,
    List<Transaction> transactions,
  ) {
    final insights = <HealthInsight>[];
    
    // Budget adherence insights
    if (breakdown.budgetAdherence < 50) {
      insights.add(HealthInsight(
        title: 'Controllo Budget',
        description: 'Le tue spese superano regolarmente il budget disponibile',
        type: HealthInsightType.budget,
        priority: HealthInsightPriority.high,
      ));
    }
    
    // Savings rate insights
    if (breakdown.savingsRate < 20) {
      insights.add(HealthInsight(
        title: 'Tasso di Risparmio',
        description: 'Stai risparmiando meno del 20% delle tue entrate',
        type: HealthInsightType.savings,
        priority: HealthInsightPriority.medium,
      ));
    }
    
    // Spending consistency insights
    if (breakdown.spendingConsistency < 60) {
      insights.add(HealthInsight(
        title: 'Spese Irregolari',
        description: 'Le tue spese variano molto da giorno a giorno',
        type: HealthInsightType.spending,
        priority: HealthInsightPriority.medium,
      ));
    }
    
    // Improvement trend insights
    if (breakdown.improvementTrend > 70) {
      insights.add(HealthInsight(
        title: 'Tendenza Positiva',
        description: 'Stai migliorando le tue abitudini di spesa!',
        type: HealthInsightType.trend,
        priority: HealthInsightPriority.low,
      ));
    }
    
    return insights;
  }
}
```

---

## 4. LAYER DETTAGLIATO - DATA

### 4.1 Database Architecture

#### 4.1.1 SQLite Database Schema Completo
```sql
-- Database Version: 1.0.0
-- SQLite Version: 3.43+
-- Encoding: UTF-8

PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA temp_store = MEMORY;
PRAGMA mmap_size = 268435456; -- 256MB

-- ==========================================
-- MAIN TABLES
-- ==========================================

CREATE TABLE IF NOT EXISTS transactions (
    -- Primary key
    id TEXT PRIMARY KEY,
    
    -- Core transaction data
    amount REAL NOT NULL CHECK(amount != 0),
    category_id TEXT NOT NULL,
    description TEXT,
    merchant_name TEXT,  -- Extracted from OCR or user input
    
    -- Date and time
    transaction_date INTEGER NOT NULL, -- Unix timestamp
    created_at INTEGER NOT NULL,       -- Unix timestamp
    updated_at INTEGER NOT NULL,       -- Unix timestamp
    deleted_at INTEGER DEFAULT NULL,   -- Soft delete timestamp
    
    -- Receipt and ML data
    receipt_photo_path TEXT,           -- Relative path to photo
    ocr_extracted_data TEXT,           -- JSON blob with OCR results
    ml_predicted_category TEXT,        -- Original ML prediction
    ml_confidence_score REAL,          -- Confidence of ML prediction
    
    -- Recurring transaction support
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_pattern TEXT,            -- JSON blob with recurrence rules
    parent_recurring_id TEXT,          -- Reference to recurring template
    
    -- User annotations
    user_notes TEXT,
    tags TEXT,                         -- JSON array of tags
    
    -- Version and sync (for future v2.0.0)
    version INTEGER DEFAULT 1,
    sync_status INTEGER DEFAULT 0,     -- 0=local, 1=synced, 2=pending
    
    -- Foreign key constraints
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT,
    FOREIGN KEY (parent_recurring_id) REFERENCES transactions(id) ON DELETE SET NULL,
    
    -- Check constraints
    CHECK(amount BETWEEN -999999.99 AND 999999.99),
    CHECK(transaction_date > 946684800), -- After 2000-01-01
    CHECK(ml_confidence_score BETWEEN 0.0 AND 1.0 OR ml_confidence_score IS NULL)
);

CREATE TABLE IF NOT EXISTS categories (
    -- Primary key
    id TEXT PRIMARY KEY,
    
    -- Display data
    name TEXT NOT NULL CHECK(LENGTH(name) > 0),
    icon_code_point INTEGER NOT NULL,
    color_value INTEGER NOT NULL,      -- ARGB color as integer
    
    -- Type and metadata
    is_income BOOLEAN NOT NULL DEFAULT FALSE,
    is_custom BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    
    -- Descriptions and help
    description TEXT,
    help_text TEXT,                    -- User guidance for this category
    
    -- Date and time
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER DEFAULT NULL,
    
    -- Usage statistics (maintained by triggers)
    usage_count INTEGER DEFAULT 0,
    last_used_at INTEGER,
    
    -- Version and sync
    version INTEGER DEFAULT 1,
    sync_status INTEGER DEFAULT 0,
    
    -- Constraints
    CHECK(sort_order >= 0),
    CHECK(usage_count >= 0),
    UNIQUE(name, is_income, deleted_at)  -- Prevent duplicate names per type
);

CREATE TABLE IF NOT EXISTS budgets (
    -- Primary key
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- Budget definition
    category_id TEXT,                  -- NULL means overall budget
    period_type TEXT NOT NULL,         -- 'monthly', 'yearly', 'weekly'
    period_value TEXT NOT NULL,        -- '2025-09' for monthly, '2025' for yearly
    budget_amount REAL NOT NULL CHECK(budget_amount > 0),
    
    -- Status and tracking
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    auto_rollover BOOLEAN DEFAULT TRUE, -- Roll unused budget to next period
    alert_threshold REAL DEFAULT 0.8,  -- Alert when 80% spent
    
    -- Metadata
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    created_by_user BOOLEAN DEFAULT TRUE, -- vs auto-generated
    
    -- Constraints
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    UNIQUE(category_id, period_type, period_value),
    CHECK(alert_threshold BETWEEN 0.1 AND 1.0)
);

CREATE TABLE IF NOT EXISTS app_settings (
    -- Primary key
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- Setting data
    key TEXT UNIQUE NOT NULL,
    value TEXT NOT NULL,
    data_type TEXT NOT NULL CHECK(data_type IN ('string', 'int', 'double', 'bool', 'json')),
    
    -- Metadata
    description TEXT,
    is_user_configurable BOOLEAN DEFAULT TRUE,
    requires_restart BOOLEAN DEFAULT FALSE,
    
    -- Date and time
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    
    -- Version and validation
    version INTEGER DEFAULT 1,
    validation_rule TEXT,              -- JSON schema for validation
    
    -- Constraints
    CHECK(LENGTH(key) > 0),
    CHECK(LENGTH(value) >= 0)
);

CREATE TABLE IF NOT EXISTS ml_training_data (
    -- Primary key
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- Training sample data
    transaction_id TEXT NOT NULL,
    features_json TEXT NOT NULL,      -- Input features for ML model
    predicted_category_id TEXT,       -- What ML predicted
    actual_category_id TEXT NOT NULL, -- What user chose
    confidence_score REAL,            -- ML confidence
    
    -- Feedback metadata
    feedback_type TEXT NOT NULL CHECK(feedback_type IN ('correction', 'confirmation')),
    feedback_timestamp INTEGER NOT NULL,
    user_explicit_feedback BOOLEAN DEFAULT FALSE, -- User actively corrected vs passive
    
    -- Context data
    app_version TEXT,
    model_version TEXT,
    device_info TEXT,                 -- Anonymous device characteristics
    
    -- Processing status
    is_processed BOOLEAN DEFAULT FALSE,
    processing_timestamp INTEGER,
    
    -- Constraints
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
    FOREIGN KEY (predicted_category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (actual_category_id) REFERENCES categories(id) ON DELETE CASCADE,
    CHECK(confidence_score BETWEEN 0.0 AND 1.0 OR confidence_score IS NULL)
);

CREATE TABLE IF NOT EXISTS receipt_photos (
    -- Primary key
    id TEXT PRIMARY KEY,
    
    -- Associated transaction
    transaction_id TEXT NOT NULL,
    
    -- File information
    file_path TEXT NOT NULL,           -- Relative path from app directory
    file_name TEXT NOT NULL,
    file_size INTEGER NOT NULL CHECK(file_size > 0),
    mime_type TEXT NOT NULL,
    
    -- Image metadata
    width INTEGER,
    height INTEGER,
    compression_quality INTEGER,       -- 0-100
    
    -- OCR processing results
    ocr_status TEXT DEFAULT 'pending', -- pending, processing, completed, failed
    ocr_text TEXT,                     -- Full extracted text
    ocr_confidence REAL,               -- Overall OCR confidence
    ocr_processing_time INTEGER,       -- Milliseconds
    
    -- Extracted structured data
    extracted_amount REAL,
    extracted_date INTEGER,           -- Unix timestamp
    extracted_merchant TEXT,
    extracted_items TEXT,             -- JSON array of line items
    
    -- Metadata
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    
    -- Processing and sync
    version INTEGER DEFAULT 1,
    sync_status INTEGER DEFAULT 0,
    
    -- Constraints
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
    CHECK(ocr_status IN ('pending', 'processing', 'completed', 'failed')),
    CHECK(compression_quality BETWEEN 1 AND 100 OR compression_quality IS NULL),
    CHECK(ocr_confidence BETWEEN 0.0 AND 1.0 OR ocr_confidence IS NULL)
);

CREATE TABLE IF NOT EXISTS recurring_templates (
    -- Primary key
    id TEXT PRIMARY KEY,
    
    -- Template definition
    name TEXT NOT NULL,
    description TEXT,
    category_id TEXT NOT NULL,
    default_amount REAL NOT NULL,
    
    -- Recurrence pattern
    recurrence_type TEXT NOT NULL CHECK(recurrence_type IN ('daily', 'weekly', 'monthly', 'yearly')),
    recurrence_interval INTEGER NOT NULL DEFAULT 1 CHECK(recurrence_interval > 0),
    recurrence_day INTEGER,           -- Day of week (1-7) or day of month (1-31)
    
    -- Status and control
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    auto_create BOOLEAN DEFAULT FALSE, -- Automatically create transactions
    next_due_date INTEGER,            -- Next expected transaction date
    last_created_at INTEGER,          -- Last time transaction was created
    
    -- Statistics
    total_created INTEGER DEFAULT 0,
    missed_count INTEGER DEFAULT 0,
    
    -- Metadata
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    created_by_user BOOLEAN DEFAULT TRUE,
    
    -- Constraints
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    CHECK(total_created >= 0),
    CHECK(missed_count >= 0)
);

-- ==========================================
-- INDEXES FOR PERFORMANCE
-- ==========================================

-- Transaction indexes
CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_amount ON transactions(amount);
CREATE INDEX IF NOT EXISTS idx_transactions_deleted ON transactions(deleted_at);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_recurring ON transactions(is_recurring, parent_recurring_id);
CREATE INDEX IF NOT EXISTS idx_transactions_sync ON transactions(sync_status);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_transactions_active_by_date ON transactions(transaction_date DESC) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_transactions_category_date ON transactions(category_id, transaction_date DESC) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_transactions_amount_date ON transactions(amount, transaction_date DESC) WHERE deleted_at IS NULL;

-- Category indexes
CREATE INDEX IF NOT EXISTS idx_categories_type ON categories(is_income, is_active, sort_order);
CREATE INDEX IF NOT EXISTS idx_categories_custom ON categories(is_custom, deleted_at);
CREATE INDEX IF NOT EXISTS idx_categories_usage ON categories(usage_count DESC, last_used_at DESC);
CREATE INDEX IF NOT EXISTS idx_categories_active ON categories(is_active, deleted_at, sort_order);

-- Budget indexes
CREATE INDEX IF NOT EXISTS idx_budgets_period ON budgets(period_type, period_value);
CREATE INDEX IF NOT EXISTS idx_budgets_category ON budgets(category_id, is_active);
CREATE INDEX IF NOT EXISTS idx_budgets_active ON budgets(is_active, period_type);

-- Settings indexes
CREATE INDEX IF NOT EXISTS idx_settings_key ON app_settings(key);
CREATE INDEX IF NOT EXISTS idx_settings_configurable ON app_settings(is_user_configurable);

-- ML training data indexes
CREATE INDEX IF NOT EXISTS idx_ml_training_transaction ON ml_training_data(transaction_id);
CREATE INDEX IF NOT EXISTS idx_ml_training_feedback ON ml_training_data(feedback_timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_ml_training_processed ON ml_training_data(is_processed, feedback_timestamp);

-- Receipt photo indexes
CREATE INDEX IF NOT EXISTS idx_receipts_transaction ON receipt_photos(transaction_id);
CREATE INDEX IF NOT EXISTS idx_receipts_ocr_status ON receipt_photos(ocr_status);
CREATE INDEX IF NOT EXISTS idx_receipts_created ON receipt_photos(created_at DESC);

-- Recurring template indexes
CREATE INDEX IF NOT EXISTS idx_recurring_active ON recurring_templates(is_active, next_due_date);
CREATE INDEX IF NOT EXISTS idx_recurring_auto ON recurring_templates(auto_create, next_due_date);

-- ==========================================
-- TRIGGERS FOR BUSINESS LOGIC
-- ==========================================

-- Auto-update timestamps
CREATE TRIGGER IF NOT EXISTS update_transactions_timestamp 
    AFTER UPDATE ON transactions
    FOR EACH ROW
BEGIN
    UPDATE transactions 
    SET updated_at = strftime('%s', 'now')
    WHERE id = NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS update_categories_timestamp
    AFTER UPDATE ON categories
    FOR EACH ROW
BEGIN
    UPDATE categories 
    SET updated_at = strftime('%s', 'now')
    WHERE id = NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS update_budgets_timestamp
    AFTER UPDATE ON budgets
    FOR EACH ROW
BEGIN
    UPDATE budgets 
    SET updated_at = strftime('%s', 'now')
    WHERE id = NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS update_settings_timestamp
    AFTER UPDATE ON app_settings
    FOR EACH ROW
BEGIN
    UPDATE app_settings 
    SET updated_at = strftime('%s', 'now')
    WHERE id = NEW.id;
END;

-- Update category usage statistics
CREATE TRIGGER IF NOT EXISTS update_category_usage
    AFTER INSERT ON transactions
    FOR EACH ROW
    WHEN NEW.deleted_at IS NULL
BEGIN
    UPDATE categories 
    SET usage_count = usage_count + 1,
        last_used_at = NEW.created_at
    WHERE id = NEW.category_id;
END;

-- Decrease category usage on transaction delete
CREATE TRIGGER IF NOT EXISTS decrease_category_usage
    AFTER UPDATE ON transactions
    FOR EACH ROW
    WHEN OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL
BEGIN
    UPDATE categories 
    SET usage_count = MAX(0, usage_count - 1)
    WHERE id = OLD.category_id;
END;

-- Prevent deletion of categories in use
CREATE TRIGGER IF NOT EXISTS prevent_category_delete
    BEFORE DELETE ON categories
    FOR EACH ROW
    WHEN OLD.usage_count > 0
BEGIN
    SELECT RAISE(ABORT, 'Cannot delete category that is in use');
END;

-- Auto-create ML training data
CREATE TRIGGER IF NOT EXISTS create_ml_training_data
    AFTER INSERT ON transactions
    FOR EACH ROW
    WHEN NEW.ml_predicted_category IS NOT NULL
BEGIN
    INSERT INTO ml_training_data (
        transaction_id,
        features_json,
        predicted_category_id,
        actual_category_id,
        confidence_score,
        feedback_type,
        feedback_timestamp,
        user_explicit_feedback,
        app_version,
        model_version
    ) VALUES (
        NEW.id,
        '{}', -- Will be populated by application
        NEW.ml_predicted_category,
        NEW.category_id,
        NEW.ml_confidence_score,
        CASE 
            WHEN NEW.ml_predicted_category = NEW.category_id THEN 'confirmation'
            ELSE 'correction'
        END,
        NEW.created_at,
        NEW.ml_predicted_category != NEW.category_id,
        '1.0.0', -- App version
        '1.0.0'  -- Model version
    );
END;

-- ==========================================
-- INITIAL DATA SEEDING
-- ==========================================

-- Default categories (Italian localized)
INSERT OR IGNORE INTO categories (
    id, name, icon_code_point, color_value, is_income, is_custom, sort_order, 
    created_at, updated_at, description, help_text
) VALUES
-- Expense categories
('cat_food', 'Alimentari & Ristoranti', 0xE57F, 4294943296, FALSE, FALSE, 1, 
 strftime('%s', 'now'), strftime('%s', 'now'),
 'Spese per cibo, supermercato, ristoranti, bar',
 'Include: spesa, ristoranti, bar, caffè, mense, delivery'),

('cat_transport', 'Trasporti & Carburante', 0xE530, 4294945280, FALSE, FALSE, 2,
 strftime('%s', 'now'), strftime('%s', 'now'),
 'Spese per trasporti pubblici, carburante, parcheggi',
 'Include: benzina, bus, metro, taxi, parcheggi, pedaggi'),

('cat_home', 'Casa & Bollette', 0xE88A, 4294954450, FALSE, FALSE, 3,
 strftime('%s', 'now'), strftime('%s', 'now'),
 'Spese per casa, affitto, bollette, manutenzioni',
 'Include: affitto, bollette, internet, telefono, riparazioni'),

('cat_health', 'Salute & Farmaci', 0xE2C8, 4294198070, FALSE, FALSE, 4,
 strftime('%s', 'now'), strftime('%s', 'now'),
 'Spese mediche, farmaci, visite, dentista',
 'Include: farmacia, visite mediche, dentista, assicurazione sanitaria'),

('cat_entertainment', 'Intrattenimento & Hobby', 0xE02E, 4294940672, FALSE, FALSE, 5,
 strftime('%s', 'now'), strftime('%s', 'now'),
 'Spese per svago, cinema, hobby, sport',
 'Include: cinema, teatro, sport, libri, giochi, abbonamenti streaming'),

('cat_clothing', 'Abbigliamento & Beauty', 0xE540, 4294951175, FALSE, FALSE, 6,
 strftime('%s', 'now'), strftime('%s', 'now'),
 'Spese per vestiti, scarpe, cosmetici, parrucchiere',
 'Include: abbigliamento, scarpe, parrucchiere, cosmetici, profumi'),

('cat_education', 'Educazione & Libri', 0xE80C, 4285315140, FALSE, FALSE, 7,
 strftime('%s', 'now'), strftime('%s', 'now'),
 'Spese per istruzione, corsi, libri, materiali',
 'Include: tasse scolastiche, corsi, libri, materiale didattico'),

('cat_sport', 'Sport & Fitness', 0xE84F, 4289781825, FALSE, FALSE, 8,
 strftime('%s', 'now'), strftime('%s', 'now'),
 'Spese per palestra, sport, attrezzature',
 'Include: palestra, piscina, attrezzature sportive, gare'),

('cat_pets', 'Animali Domestici', 0xE91D, 4294940672, FALSE, FALSE, 9,
 strftime('%s', 'now'), strftime('%s', 'now'),
 'Spese per animali domestici, veterinario, cibo',
 'Include: cibo animali, veterinario, toelettatura, accessori'),

('cat_gifts', 'Regali & Donazioni', 0xE7FB, 4294198070, FALSE, FALSE, 10,
 strftime('%s', 'now'), strftime('%s', 'now'),
 'Spese per regali, donazioni, beneficenza',
 'Include: regali compleanni, matrimoni, donazioni, beneficenza'),

-- Income categories  
('cat_salary', 'Stipendio & Lavoro', 0xE263, 4285315140, TRUE, FALSE, 11,
 strftime('%s', 'now'), strftime('%s', 'now'),
 'Stipendio, freelance, bonus lavorativi',
 'Include: stipendio, freelance, bonus, straordinari, tredicesima'),

('cat_other_income', 'Altri Ricavi', 0xE8D0, 4285315140, TRUE, FALSE, 12,
 strftime('%s', 'now'), strftime('%s', 'now'),
 'Altri tipi di entrate e ricavi',
 'Include: dividendi, interessi, vendite, rimborsi, regali ricevuti');

-- Default app settings
INSERT OR IGNORE INTO app_settings (
    key, value, data_type, description, is_user_configurable, 
    created_at, updated_at
) VALUES
('currency_code', 'EUR', 'string', 'Currency code for formatting', TRUE, 
 strftime('%s', 'now'), strftime('%s', 'now')),

('currency_symbol', '€', 'string', 'Currency symbol for display', TRUE,
 strftime('%s', 'now'), strftime('%s', 'now')),

('date_format', 'dd/MM/yyyy', 'string', 'Date format for display', TRUE,
 strftime('%s', 'now'), strftime('%s', 'now')),

('first_day_of_week', '1', 'int', 'First day of week (1=Monday)', TRUE,
 strftime('%s', 'now'), strftime('%s', 'now')),

('notifications_enabled', 'true', 'bool', 'Enable push notifications', TRUE,
 strftime('%s', 'now'), strftime('%s', 'now')),

('biometric_lock_enabled', 'false', 'bool', 'Enable biometric app lock', TRUE,
 strftime('%s', 'now'), strftime('%s', 'now')),

('auto_backup_enabled', 'true', 'bool', 'Enable automatic backups', TRUE,
 strftime('%s', 'now'), strftime('%s', 'now')),

('ml_categorization_enabled', 'true', 'bool', 'Enable ML auto-categorization', TRUE,
 strftime('%s', 'now'), strftime('%s', 'now')),

('health_score_enabled', 'true', 'bool', 'Enable health score calculation', TRUE,
 strftime('%s', 'now'), strftime('%s', 'now')),

('onboarding_completed', 'false', 'bool', 'User completed onboarding', FALSE,
 strftime('%s', 'now'), strftime('%s', 'now')),

('database_version', '1', 'int', 'Current database schema version', FALSE,
 strftime('%s', 'now'), strftime('%s', 'now')),

('app_first_launch', 'true', 'bool', 'Is this the first app launch', FALSE,
 strftime('%s', 'now'), strftime('%s', 'now'));

-- Create views for common queries
CREATE VIEW IF NOT EXISTS active_transactions AS
SELECT * FROM transactions 
WHERE deleted_at IS NULL
ORDER BY transaction_date DESC;

CREATE VIEW IF NOT EXISTS active_categories AS  
SELECT * FROM categories
WHERE deleted_at IS NULL AND is_active = TRUE
ORDER BY is_income ASC, sort_order ASC;

CREATE VIEW IF NOT EXISTS expense_categories AS
SELECT * FROM categories
WHERE deleted_at IS NULL AND is_active = TRUE AND is_income = FALSE
ORDER BY sort_order ASC;

CREATE VIEW IF NOT EXISTS income_categories AS
SELECT * FROM categories  
WHERE deleted_at IS NULL AND is_active = TRUE AND is_income = TRUE
ORDER BY sort_order ASC;

-- ==========================================
-- MAINTENANCE PROCEDURES
-- ==========================================

-- These would be called periodically by the application

-- Clean up old ML training data (keep last 1000 records)
-- DELETE FROM ml_training_data 
-- WHERE id NOT IN (
--     SELECT id FROM ml_training_data 
--     ORDER BY feedback_timestamp DESC 
--     LIMIT 1000
-- );

-- Clean up processed OCR data older than 90 days
-- UPDATE receipt_photos 
-- SET ocr_text = NULL, extracted_items = NULL
-- WHERE created_at < strftime('%s', 'now', '-90 days') 
-- AND ocr_status = 'completed';

-- Update database statistics
-- ANALYZE;

-- Optimize database
-- VACUUM;
```

#### 4.1.2 Database Helper Implementation
```dart
// Database helper using sqflite and drift

import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:path/path.dart' as p;

part 'database_helper.g.dart';

// Table definitions
class Transactions extends Table {
  TextColumn get id => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text().named('category_id')();
  TextColumn get description => text().nullable()();
  TextColumn get merchantName => text().nullable().named('merchant_name')();
  DateTimeColumn get transactionDate => dateTime().named('transaction_date')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  TextColumn get receiptPhotoPath => text().nullable().named('receipt_photo_path')();
  TextColumn get ocrExtractedData => text().nullable().named('ocr_extracted_data')();
  TextColumn get mlPredictedCategory => text().nullable().named('ml_predicted_category')();
  RealColumn get mlConfidenceScore => real().nullable().named('ml_confidence_score')();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false)).named('is_recurring')();
  TextColumn get recurringPattern => text().nullable().named('recurring_pattern')();
  TextColumn get parentRecurringId => text().nullable().named('parent_recurring_id')();
  TextColumn get userNotes => text().nullable().named('user_notes')();
  TextColumn get tags => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get syncStatus => integer().withDefault(const Constant(0)).named('sync_status')();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get iconCodePoint => integer().named('icon_code_point')();
  IntColumn get colorValue => integer().named('color_value')();
  BoolColumn get isIncome => boolean().withDefault(const Constant(false)).named('is_income')();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false)).named('is_custom')();
  BoolColumn get isActive => boolean().withDefault(const Constant(true)).named('is_active')();
  IntColumn get sortOrder => integer().withDefault(const Constant(0)).named('sort_order')();
  TextColumn get description => text().nullable()();
  TextColumn get helpText => text().nullable().named('help_text')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();
  IntColumn get usageCount => integer().withDefault(const Constant(0)).named('usage_count')();
  DateTimeColumn get lastUsedAt => dateTime().nullable().named('last_used_at')();
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get syncStatus => integer().withDefault(const Constant(0)).named('sync_status')();

  @override
  Set<Column> get primaryKey => {id};
}

// Main database class
@DriftDatabase(
  tables: [
    Transactions,
    Categories,
    // Add other tables here
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedInitialData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle future migrations here
      if (from < 2) {
        // Migration logic for version 2
      }
    },
  );

  // Transaction operations
  Future<List<Transaction>> getAllTransactions({
    int? limit,
    int? offset,
  }) async {
    final query = select(transactions)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.get();
  }

  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return (select(transactions)
          ..where((t) => 
              t.deletedAt.isNull() &
              t.transactionDate.isBetween(
                Variable(startDate),
                Variable(endDate),
              ))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    return (select(transactions)
          ..where((t) => 
              t.deletedAt.isNull() &
              t.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  Future<Transaction?> getTransactionById(String id) async {
    return (select(transactions)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<void> insertTransaction(TransactionsCompanion transaction) async {
    await into(transactions).insert(transaction);
  }

  Future<bool> updateTransaction(TransactionsCompanion transaction) async {
    return update(transactions).replace(transaction);
  }

  Future<int> softDeleteTransaction(String id) async {
    return (update(transactions)
          ..where((t) => t.id.equals(id)))
        .write(TransactionsCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));
  }

  Future<int> hardDeleteTransaction(String id) async {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  // Category operations
  Future<List<Category>> getAllCategories({bool includeDeleted = false}) async {
    final query = select(categories);
    
    if (!includeDeleted) {
      query.where((c) => c.deletedAt.isNull() & c.isActive.equals(true));
    }
    
    query.orderBy([(c) => OrderingTerm.asc(c.isIncome), (c) => OrderingTerm.asc(c.sortOrder)]);
    
    return query.get();
  }

  Future<List<Category>> getIncomeCategories() async {
    return (select(categories)
          ..where((c) => 
              c.deletedAt.isNull() & 
              c.isActive.equals(true) & 
              c.isIncome.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  Future<List<Category>> getExpenseCategories() async {
    return (select(categories)
          ..where((c) => 
              c.deletedAt.isNull() & 
              c.isActive.equals(true) & 
              c.isIncome.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  Future<Category?> getCategoryById(String id) async {
    return (select(categories)
          ..where((c) => c.id.equals(id) & c.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<void> insertCategory(CategoriesCompanion category) async {
    await into(categories).insert(category);
  }

  Future<bool> updateCategory(CategoriesCompanion category) async {
    return update(categories).replace(category);
  }

  // Analytics queries
  Future<double> getTotalSpending({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.deletedAt.isNull() & transactions.amount.isSmallerThanValue(0));

    if (startDate != null && endDate != null) {
      query.where(transactions.transactionDate.isBetween(
        Variable(startDate),
        Variable(endDate),
      ));
    }

    if (categoryId != null) {
      query.where(transactions.categoryId.equals(categoryId));
    }

    final result = await query.getSingle();
    return (result.read(transactions.amount.sum()) ?? 0.0).abs();
  }

  Future<double> getTotalIncome({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
  }) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.deletedAt.isNull() & transactions.amount.isBiggerThanValue(0));

    if (startDate != null && endDate != null) {
      query.where(transactions.transactionDate.isBetween(
        Variable(startDate),
        Variable(endDate),
      ));
    }

    if (categoryId != null) {
      query.where(transactions.categoryId.equals(categoryId));
    }

    final result = await query.getSingle();
    return result.read(transactions.amount.sum()) ?? 0.0;
  }

  Future<Map<String, double>> getSpendingByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = selectOnly(transactions)
      ..addColumns([transactions.categoryId, transactions.amount.sum()])
      ..where(transactions.deletedAt.isNull())
      ..groupBy([transactions.categoryId]);

    if (startDate != null && endDate != null) {
      query.where(transactions.transactionDate.isBetween(
        Variable(startDate),
        Variable(endDate),
      ));
    }

    final results = await query.get();
    final spendingMap = <String, double>{};

    for (final row in results) {
      final categoryId = row.read(transactions.categoryId)!;
      final amount = row.read(transactions.amount.sum()) ?? 0.0;
      spendingMap[categoryId] = amount.abs();
    }

    return spendingMap;
  }

  // Utility methods
  Future<void> _seedInitialData() async {
    // Seed default categories if they don't exist
    final existingCategories = await getAllCategories();
    if (existingCategories.isEmpty) {
      await batch((batch) {
        // Add all default categories
        // (Implementation would insert all predefined categories)
      });
    }
  }

  Future<void> vacuum() async {
    await customStatement('VACUUM');
  }

  Future<void> analyze() async {
    await customStatement('ANALYZE');
  }
}

// Connection configuration
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'budget_tracker.sqlite'));

    // Make sure to use the bundled sqlite3 library on Android
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(
      file,
      logStatements: kDebugMode,
      setup: (database) {
        // Enable foreign keys
        database.execute('PRAGMA foreign_keys = ON');
        // Set WAL mode for better performance
        database.execute('PRAGMA journal_mode = WAL');
        // Optimize for mobile usage
        database.execute('PRAGMA synchronous = NORMAL');
        database.execute('PRAGMA temp_store = MEMORY');
        database.execute('PRAGMA mmap_size = 268435456'); // 256MB
      },
    );
  });
}

// Singleton database instance
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static AppDatabase? _database;

  DatabaseHelper._internal();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
```

---

Questo è il documento di Specifica Tecnica e Architettura. È molto dettagliato e copre tutti gli aspetti tecnici necessari per l'implementazione.

Vuoi che continui con gli altri documenti di specifica? I prossimi sarebbero:
1. **Design System e UI/UX Specifications**
2. **Testing Plan e Quality Assurance** 
3. **Deployment e Release Management**
4. **Project Management e Timeline**

Quale preferisci vedere completato per prossimo?
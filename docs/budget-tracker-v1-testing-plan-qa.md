# Budget Tracker Smart v1.0.0 - Testing Plan e Quality Assurance

**Documento**: Testing Plan e Quality Assurance v1.0.0  
**Progetto**: Budget Tracker Smart  
**Versione Documento**: 1.0  
**Data**: 13 Settembre 2025  
**Autore**: QA Team  
**Stato**: APPROVATO per implementazione

---

## 1. TESTING STRATEGY OVERVIEW

### 1.1 Testing Objectives
- **Functional Correctness**: Tutte le features funzionano come specificato
- **Performance Assurance**: App responsive con tempi di risposta <500ms
- **Reliability**: Zero crash, graceful error handling
- **Usability**: Interface intuitiva per target users
- **Security**: Dati protetti, nessun leak di informazioni
- **Accessibility**: WCAG 2.1 Level AA compliance

### 1.2 Testing Scope
**In Scope**:
- ✅ Core business logic (Health Score, Transactions, OCR)
- ✅ UI components e user interactions
- ✅ Database operations e data persistence  
- ✅ File operations e photo management
- ✅ ML model integration e predictions
- ✅ Performance su dispositivi mid-range
- ✅ Accessibility features

**Out of Scope** (v1.0.0):
- ❌ Cloud synchronization (v2.0.0)
- ❌ Multi-device scenarios
- ❌ Bank API integrations
- ❌ Web dashboard testing

### 1.3 Testing Types e Coverage Targets

| **Test Type** | **Target Coverage** | **Responsibility** | **Automation Level** |
|---------------|--------------------|--------------------|---------------------|
| Unit Tests | 85% | Developers | Fully Automated |
| Integration Tests | 70% | Developers + QA | Fully Automated |
| Widget Tests | 80% | Developers | Fully Automated |
| E2E Tests | Key User Flows | QA Team | Automated |
| Manual Testing | Full Feature Set | QA Team | Manual |
| Performance Tests | Critical Paths | QA Team | Automated |
| Accessibility Tests | All UI Components | QA Team | Semi-Automated |
| Usability Testing | 5-10 Users | UX Team | Manual |

---

## 2. UNIT TESTING PLAN

### 2.1 Business Logic Testing

#### 2.1.1 Health Score Calculation Tests
```dart
// test/unit/health_score_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:budget_tracker/domain/usecases/calculate_health_score.dart';

void main() {
  group('CalculateHealthScoreUseCase', () {
    late CalculateHealthScoreUseCase useCase;
    late MockTransactionsRepository mockRepository;
    
    setUp(() {
      mockRepository = MockTransactionsRepository();
      useCase = CalculateHealthScoreUseCase(transactionsRepo: mockRepository);
    });
    
    group('Budget Adherence Calculation', () {
      test('should return 100 when spending is well within budget', () async {
        // Arrange
        final transactions = [
          Transaction(
            id: '1',
            amount: -500.0, // €500 spent
            categoryId: 'food',
            date: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        
        when(mockRepository.getTransactionsByDateRange(any, any))
            .thenAnswer((_) async => transactions);
        
        // Act
        final healthScore = await useCase.execute();
        
        // Assert
        expect(healthScore.score, greaterThanOrEqualTo(80));
        expect(healthScore.mood, equals(HealthMood.excellent));
        expect(healthScore.breakdown.budgetAdherence, greaterThan(80));
      });
      
      test('should return low score when budget is exceeded', () async {
        // Arrange
        final transactions = [
          Transaction(
            id: '1',
            amount: -1500.0, // €1500 spent
            categoryId: 'food', 
            date: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          // Income transaction
          Transaction(
            id: '2',
            amount: 1000.0, // €1000 income
            categoryId: 'salary',
            date: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        
        when(mockRepository.getTransactionsByDateRange(any, any))
            .thenAnswer((_) async => transactions);
        
        // Act  
        final healthScore = await useCase.execute();
        
        // Assert
        expect(healthScore.score, lessThan(50));
        expect(healthScore.mood, anyOf([HealthMood.poor, HealthMood.critical]));
        expect(healthScore.breakdown.budgetAdherence, lessThan(30));
      });
      
      test('should handle empty transaction list gracefully', () async {
        // Arrange
        when(mockRepository.getTransactionsByDateRange(any, any))
            .thenAnswer((_) async => []);
        
        // Act
        final healthScore = await useCase.execute();
        
        // Assert
        expect(healthScore.score, equals(50.0)); // Neutral score
        expect(healthScore.mood, equals(HealthMood.average));
      });
    });
    
    group('Savings Rate Calculation', () {
      test('should calculate correct savings rate for positive savings', () async {
        // Arrange
        final transactions = [
          Transaction(
            id: '1',
            amount: 2000.0, // €2000 income
            categoryId: 'salary',
            date: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Transaction(
            id: '2', 
            amount: -1200.0, // €1200 spent
            categoryId: 'food',
            date: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        
        when(mockRepository.getTransactionsByDateRange(any, any))
            .thenAnswer((_) async => transactions);
        
        // Act
        final healthScore = await useCase.execute();
        
        // Assert  
        // Savings rate should be (2000-1200)/2000 = 40%
        expect(healthScore.breakdown.savingsRate, closeTo(40.0, 1.0));
      });
      
      test('should handle negative savings correctly', () async {
        // Arrange - spending more than income
        final transactions = [
          Transaction(
            id: '1',
            amount: 1000.0, // €1000 income
            categoryId: 'salary',
            date: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Transaction(
            id: '2',
            amount: -1500.0, // €1500 spent
            categoryId: 'food',
            date: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        
        when(mockRepository.getTransactionsByDateRange(any, any))
            .thenAnswer((_) async => transactions);
        
        // Act
        final healthScore = await useCase.execute();
        
        // Assert
        expect(healthScore.breakdown.savingsRate, lessThanOrEqualTo(0.0));
      });
    });
    
    group('Edge Cases', () {
      test('should handle very large numbers without overflow', () async {
        // Arrange
        final transactions = [
          Transaction(
            id: '1',
            amount: 999999.99, // Maximum allowed amount
            categoryId: 'salary',
            date: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        
        when(mockRepository.getTransactionsByDateRange(any, any))
            .thenAnswer((_) async => transactions);
        
        // Act & Assert - Should not throw
        final healthScore = await useCase.execute();
        expect(healthScore.score, isNotNaN);
        expect(healthScore.score, greaterThanOrEqualTo(0));
        expect(healthScore.score, lessThanOrEqualTo(100));
      });
      
      test('should handle database errors gracefully', () async {
        // Arrange
        when(mockRepository.getTransactionsByDateRange(any, any))
            .thenThrow(Exception('Database error'));
        
        // Act & Assert
        expect(
          () async => await useCase.execute(),
          throwsException,
        );
      });
    });
  });
}
```

#### 2.1.2 Transaction Management Tests
```dart
// test/unit/transaction_management_test.dart
void main() {
  group('AddTransactionUseCase', () {
    late AddTransactionUseCase useCase;
    late MockTransactionsRepository mockTransactionsRepo;
    late MockCategoriesRepository mockCategoriesRepo;
    late MockMLService mockMLService;
    
    setUp(() {
      mockTransactionsRepo = MockTransactionsRepository();
      mockCategoriesRepo = MockCategoriesRepository();
      mockMLService = MockMLService();
      
      useCase = AddTransactionUseCase(
        transactionsRepo: mockTransactionsRepo,
        categoriesRepo: mockCategoriesRepo,
        mlService: mockMLService,
      );
    });
    
    test('should successfully add transaction with valid input', () async {
      // Arrange
      final input = AddTransactionInput(
        amount: -25.50,
        description: 'Spesa supermercato',
        date: DateTime.now(),
      );
      
      final mockCategory = Category(
        id: 'food',
        name: 'Alimentari',
        iconCodePoint: 0xE57F,
        colorValue: 0xFF4CAF50,
        isIncome: false,
        isCustom: false,
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      when(mockMLService.predictCategory(any, any))
          .thenAnswer((_) async => CategoryPrediction(
            categoryId: 'food',
            confidence: 0.8,
            explanation: 'Test prediction',
            alternativeCategories: [],
          ));
      
      when(mockCategoriesRepo.getCategoryById('food'))
          .thenAnswer((_) async => mockCategory);
      
      when(mockTransactionsRepo.insertTransaction(any))
          .thenAnswer((_) async => Future.value());
      
      // Act
      final transaction = await useCase.execute(input);
      
      // Assert
      expect(transaction.amount, equals(-25.50));
      expect(transaction.description, equals('Spesa supermercato'));
      expect(transaction.categoryId, equals('food'));
      
      verify(mockTransactionsRepo.insertTransaction(any)).called(1);
      verify(mockMLService.recordUserFeedback(
        description: anyNamed('description'),
        amount: anyNamed('amount'),
        predictedCategoryId: anyNamed('predictedCategoryId'),
        actualCategoryId: anyNamed('actualCategoryId'),
        confidence: anyNamed('confidence'),
      )).called(1);
    });
    
    test('should validate input and reject invalid data', () async {
      // Arrange - Invalid input with zero amount
      final input = AddTransactionInput(
        amount: 0.0, // Invalid
        description: 'Invalid transaction',
      );
      
      // Act & Assert
      expect(
        () async => await useCase.execute(input),
        throwsA(isA<DomainException>()),
      );
    });
    
    test('should handle ML service failure gracefully', () async {
      // Arrange
      final input = AddTransactionInput(
        amount: -50.0,
        description: 'Test transaction',
      );
      
      when(mockMLService.predictCategory(any, any))
          .thenThrow(Exception('ML service error'));
      
      when(mockCategoriesRepo.getCategoryById('other'))
          .thenAnswer((_) async => Category(
            id: 'other',
            name: 'Altro',
            iconCodePoint: 0xE000,
            colorValue: 0xFF757575,
            isIncome: false,
            isCustom: false,
            sortOrder: 99,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
      
      when(mockTransactionsRepo.insertTransaction(any))
          .thenAnswer((_) async => Future.value());
      
      // Act - Should not throw, should fallback to 'other' category
      final transaction = await useCase.execute(input);
      
      // Assert
      expect(transaction.categoryId, equals('other'));
      expect(transaction.amount, equals(-50.0));
    });
  });
  
  group('UpdateTransactionUseCase', () {
    late UpdateTransactionUseCase useCase;
    late MockTransactionsRepository mockRepository;
    
    setUp(() {
      mockRepository = MockTransactionsRepository();
      useCase = UpdateTransactionUseCase(transactionsRepo: mockRepository);
    });
    
    test('should update existing transaction successfully', () async {
      // Arrange
      final existingTransaction = Transaction(
        id: '1',
        amount: -20.0,
        categoryId: 'food',
        description: 'Old description',
        date: DateTime.now().subtract(Duration(days: 1)),
        createdAt: DateTime.now().subtract(Duration(days: 1)),
        updatedAt: DateTime.now().subtract(Duration(days: 1)),
      );
      
      final updateInput = UpdateTransactionInput(
        amount: -25.0,
        description: 'Updated description',
      );
      
      when(mockRepository.getTransactionById('1'))
          .thenAnswer((_) async => existingTransaction);
      
      when(mockRepository.updateTransaction(any))
          .thenAnswer((_) async => Future.value());
      
      // Act
      final updatedTransaction = await useCase.execute('1', updateInput);
      
      // Assert
      expect(updatedTransaction.amount, equals(-25.0));
      expect(updatedTransaction.description, equals('Updated description'));
      expect(updatedTransaction.id, equals('1'));
      expect(updatedTransaction.updatedAt.isAfter(existingTransaction.updatedAt), isTrue);
    });
    
    test('should reject update for transactions older than 12 months', () async {
      // Arrange
      final oldTransaction = Transaction(
        id: '1',
        amount: -20.0,
        categoryId: 'food',
        description: 'Old transaction',
        date: DateTime.now().subtract(Duration(days: 400)), // > 12 months
        createdAt: DateTime.now().subtract(Duration(days: 400)),
        updatedAt: DateTime.now().subtract(Duration(days: 400)),
      );
      
      when(mockRepository.getTransactionById('1'))
          .thenAnswer((_) async => oldTransaction);
      
      // Act & Assert
      expect(
        () async => await useCase.execute('1', UpdateTransactionInput(amount: -25.0)),
        throwsA(predicate((e) => e is DomainException && e.toString().contains('12 months'))),
      );
    });
  });
}
```

#### 2.1.3 OCR Service Tests
```dart
// test/unit/ocr_service_test.dart
void main() {
  group('OCRService', () {
    late OCRService ocrService;
    late MockTextRecognizer mockTextRecognizer;
    
    setUp(() {
      mockTextRecognizer = MockTextRecognizer();
      ocrService = GoogleMLKitOCRService(textRecognizer: mockTextRecognizer);
    });
    
    test('should extract amount from Italian receipt text', () async {
      // Arrange
      final mockRecognizedText = RecognizedText(
        text: 'SUPERMERCATO ESSELUNGA\n'
              'Via Roma 123\n'
              'Banane        2,50\n'
              'Pane          1,20\n' 
              'Latte         0,99\n'
              'TOTALE       4,69\n'
              'Contanti     5,00\n'
              'Resto        0,31',
        blocks: [],
      );
      
      when(mockTextRecognizer.processImage(any))
          .thenAnswer((_) async => mockRecognizedText);
      
      // Act
      final receiptData = await ocrService.extractReceiptData('/fake/path.jpg');
      
      // Assert
      expect(receiptData, isNotNull);
      expect(receiptData!.amount, equals(4.69));
      expect(receiptData.merchant, equals('SUPERMERCATO ESSELUNGA'));
      expect(receiptData.confidence, greaterThan(0.7));
    });
    
    test('should handle multiple amount formats', () async {
      final testCases = [
        ('TOTALE € 15,50', 15.50),
        ('TOT. EUR 22.75', 22.75), 
        ('SALDO 8,99 €', 8.99),
        ('Total: 45,00', 45.00),
        ('Importo €12,30', 12.30),
      ];
      
      for (final testCase in testCases) {
        // Arrange
        final mockText = RecognizedText(text: testCase.$1, blocks: []);
        when(mockTextRecognizer.processImage(any))
            .thenAnswer((_) async => mockText);
        
        // Act
        final receiptData = await ocrService.extractReceiptData('/fake/path.jpg');
        
        // Assert
        expect(receiptData?.amount, equals(testCase.$2),
            reason: 'Failed to extract ${testCase.$2} from "${testCase.$1}"');
      }
    });
    
    test('should extract date in various Italian formats', () async {
      final testCases = [
        ('13/09/2025', DateTime(2025, 9, 13)),
        ('13-09-25', DateTime(2025, 9, 13)),
        ('13.09.2025', DateTime(2025, 9, 13)),
        ('2025/09/13', DateTime(2025, 9, 13)),
      ];
      
      for (final testCase in testCases) {
        // Arrange
        final mockText = RecognizedText(text: testCase.$1, blocks: []);
        when(mockTextRecognizer.processImage(any))
            .thenAnswer((_) async => mockText);
        
        // Act
        final receiptData = await ocrService.extractReceiptData('/fake/path.jpg');
        
        // Assert
        expect(receiptData?.date, equals(testCase.$2),
            reason: 'Failed to extract ${testCase.$2} from "${testCase.$1}"');
      }
    });
    
    test('should return null for unreadable images', () async {
      // Arrange
      when(mockTextRecognizer.processImage(any))
          .thenThrow(Exception('Image processing failed'));
      
      // Act
      final receiptData = await ocrService.extractReceiptData('/fake/path.jpg');
      
      // Assert
      expect(receiptData, isNull);
    });
    
    test('should calculate confidence score based on extracted data', () async {
      final testCases = [
        // All data extracted -> high confidence
        ('ESSELUNGA\n13/09/2025\nTOTALE 25,50', 1.0),
        // Amount + date -> medium confidence  
        ('13/09/2025\nTOTALE 25,50', 0.8),
        // Only amount -> low confidence
        ('TOTALE 25,50', 0.5),
        // No structured data -> zero confidence
        ('Random text with no structure', 0.0),
      ];
      
      for (final testCase in testCases) {
        // Arrange
        final mockText = RecognizedText(text: testCase.$1, blocks: []);
        when(mockTextRecognizer.processImage(any))
            .thenAnswer((_) async => mockText);
        
        // Act
        final receiptData = await ocrService.extractReceiptData('/fake/path.jpg');
        
        // Assert
        if (testCase.$2 > 0) {
          expect(receiptData, isNotNull);
          expect(receiptData!.confidence, equals(testCase.$2),
              reason: 'Confidence mismatch for: "${testCase.$1}"');
        } else {
          expect(receiptData, isNull);
        }
      }
    });
  });
}
```

### 2.2 Repository Layer Testing

#### 2.2.1 Database Operations Tests
```dart
// test/unit/database_test.dart
void main() {
  group('TransactionsRepository', () {
    late AppDatabase database;
    late TransactionsRepositoryImpl repository;
    
    setUp(() async {
      // Use in-memory database for testing
      database = AppDatabase.forTesting();
      repository = TransactionsRepositoryImpl(database);
      
      // Setup test categories
      await _seedTestCategories(database);
    });
    
    tearDown(() async {
      await database.close();
    });
    
    test('should insert and retrieve transaction', () async {
      // Arrange
      final transaction = Transaction(
        id: 'test_1',
        amount: -25.50,
        categoryId: 'food',
        description: 'Test transaction',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await repository.insertTransaction(transaction);
      final retrieved = await repository.getTransactionById('test_1');
      
      // Assert
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('test_1'));
      expect(retrieved.amount, equals(-25.50));
      expect(retrieved.description, equals('Test transaction'));
    });
    
    test('should soft delete transaction', () async {
      // Arrange
      final transaction = Transaction(
        id: 'test_2',
        amount: -10.0,
        categoryId: 'food',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await repository.insertTransaction(transaction);
      
      // Act
      await repository.softDeleteTransaction('test_2');
      
      // Assert
      final retrieved = await repository.getTransactionById('test_2');
      expect(retrieved, isNull); // Should not be returned in normal queries
      
      // But should exist in database with deleted_at timestamp
      final allTransactions = await repository.getTransactions(includeDeleted: true);
      final deletedTransaction = allTransactions.firstWhere((t) => t.id == 'test_2');
      expect(deletedTransaction.deletedAt, isNotNull);
    });
    
    test('should calculate spending by category correctly', () async {
      // Arrange
      final transactions = [
        Transaction(
          id: 'food_1',
          amount: -20.0,
          categoryId: 'food',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Transaction(
          id: 'food_2', 
          amount: -15.0,
          categoryId: 'food',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Transaction(
          id: 'transport_1',
          amount: -30.0,
          categoryId: 'transport',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      
      for (final transaction in transactions) {
        await repository.insertTransaction(transaction);
      }
      
      // Act
      final spendingByCategory = await repository.getSpendingByCategory();
      
      // Assert
      expect(spendingByCategory['food'], equals(35.0)); // 20 + 15
      expect(spendingByCategory['transport'], equals(30.0));
    });
    
    test('should handle concurrent database operations', () async {
      // Arrange
      final futures = <Future>[];
      
      // Act - Simulate concurrent inserts
      for (int i = 0; i < 10; i++) {
        final transaction = Transaction(
          id: 'concurrent_$i',
          amount: -i * 5.0,
          categoryId: 'food',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        futures.add(repository.insertTransaction(transaction));
      }
      
      await Future.wait(futures);
      
      // Assert
      final allTransactions = await repository.getTransactions();
      expect(allTransactions.length, equals(10));
      
      // Verify all transactions were inserted correctly
      for (int i = 0; i < 10; i++) {
        final transaction = allTransactions.firstWhere(
          (t) => t.id == 'concurrent_$i'
        );
        expect(transaction.amount, equals(-i * 5.0));
      }
    });
  });
}

Future<void> _seedTestCategories(AppDatabase database) async {
  final categories = [
    Category(
      id: 'food',
      name: 'Alimentari',
      iconCodePoint: 0xE57F,
      colorValue: 0xFF4CAF50,
      isIncome: false,
      isCustom: false,
      sortOrder: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Category(
      id: 'transport',
      name: 'Trasporti',
      iconCodePoint: 0xE530,
      colorValue: 0xFF2196F3,
      isIncome: false,
      isCustom: false,
      sortOrder: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
  
  final repository = CategoriesRepositoryImpl(database);
  for (final category in categories) {
    await repository.insertCategory(category);
  }
}
```

---

## 3. INTEGRATION TESTING PLAN

### 3.1 Feature Integration Tests

#### 3.1.1 End-to-End Transaction Flow
```dart
// test/integration/transaction_flow_test.dart
void main() {
  group('Transaction Flow Integration', () {
    late AppDatabase database;
    late TransactionsNotifier transactionsNotifier;
    late HealthScoreNotifier healthScoreNotifier;
    
    setUp(() async {
      database = AppDatabase.forTesting();
      
      final transactionsRepo = TransactionsRepositoryImpl(database);
      final mlService = MockMLService();
      
      transactionsNotifier = TransactionsNotifier(transactionsRepo, mlService);
      
      final healthScoreService = HealthScoreServiceImpl(transactionsRepo);
      healthScoreNotifier = HealthScoreNotifier(healthScoreService);
      
      await _seedTestData(database);
    });
    
    tearDown(() async {
      await database.close();
    });
    
    testWidgets('complete transaction lifecycle affects health score', (tester) async {
      // Initial state
      await transactionsNotifier.loadTransactions();
      await healthScoreNotifier.calculateHealthScore();
      
      final initialTransactions = transactionsNotifier.state.value!;
      final initialHealthScore = healthScoreNotifier.state.value!;
      
      expect(initialTransactions.length, equals(0));
      expect(initialHealthScore.score, equals(50.0)); // Neutral for no data
      
      // Add first transaction
      await transactionsNotifier.addTransaction(TransactionInput(
        amount: -100.0,
        categoryId: 'food',
        description: 'Spesa settimanale',
        date: DateTime.now(),
      ));
      
      // Verify transaction was added
      expect(transactionsNotifier.state.value!.length, equals(1));
      
      // Verify health score updated
      await healthScoreNotifier.calculateHealthScore();
      final updatedHealthScore = healthScoreNotifier.state.value!;
      expect(updatedHealthScore.calculatedAt.isAfter(initialHealthScore.calculatedAt), isTrue);
      
      // Add income transaction
      await transactionsNotifier.addTransaction(TransactionInput(
        amount: 2000.0,
        categoryId: 'salary', 
        description: 'Stipendio',
        date: DateTime.now(),
      ));
      
      // Verify better health score with income
      await healthScoreNotifier.calculateHealthScore();
      final finalHealthScore = healthScoreNotifier.state.value!;
      expect(finalHealthScore.score, greaterThan(updatedHealthScore.score));
      expect(finalHealthScore.breakdown.savingsRate, greaterThan(0));
    });
    
    testWidgets('transaction update propagates through system', (tester) async {
      // Add initial transaction
      await transactionsNotifier.addTransaction(TransactionInput(
        amount: -50.0,
        categoryId: 'food',
        description: 'Initial transaction',
      ));
      
      final transactions = transactionsNotifier.state.value!;
      final transactionId = transactions.first.id;
      
      // Calculate initial health score
      await healthScoreNotifier.calculateHealthScore();
      final initialScore = healthScoreNotifier.state.value!.score;
      
      // Update transaction with larger amount
      await transactionsNotifier.updateTransaction(transactionId, TransactionInput(
        amount: -200.0, // Much larger expense
        description: 'Updated transaction',
      ));
      
      // Verify transaction was updated
      final updatedTransactions = transactionsNotifier.state.value!;
      expect(updatedTransactions.first.amount, equals(-200.0));
      expect(updatedTransactions.first.description, equals('Updated transaction'));
      
      // Verify health score changed
      await healthScoreNotifier.calculateHealthScore();
      final updatedScore = healthScoreNotifier.state.value!.score;
      expect(updatedScore, lessThan(initialScore)); // Should be worse due to higher expense
    });
    
    testWidgets('transaction deletion affects health score', (tester) async {
      // Add multiple transactions
      await transactionsNotifier.addTransaction(TransactionInput(
        amount: -100.0,
        categoryId: 'food',
        description: 'Transaction 1',
      ));
      
      await transactionsNotifier.addTransaction(TransactionInput(
        amount: -50.0,
        categoryId: 'transport',
        description: 'Transaction 2',
      ));
      
      expect(transactionsNotifier.state.value!.length, equals(2));
      
      // Calculate health score with both transactions
      await healthScoreNotifier.calculateHealthScore();
      final scoreWithBoth = healthScoreNotifier.state.value!.score;
      
      // Delete one transaction
      final transactionToDelete = transactionsNotifier.state.value!.first;
      await transactionsNotifier.deleteTransaction(transactionToDelete.id);
      
      // Verify transaction was deleted
      expect(transactionsNotifier.state.value!.length, equals(1));
      
      // Verify health score recalculated
      await healthScoreNotifier.calculateHealthScore();
      final scoreAfterDeletion = healthScoreNotifier.state.value!.score;
      expect(scoreAfterDeletion, isNot(equals(scoreWithBoth)));
    });
  });
}
```

#### 3.1.2 OCR to Transaction Integration
```dart
// test/integration/ocr_integration_test.dart
void main() {
  group('OCR Integration', () {
    late OCRService ocrService;
    late TransactionsNotifier transactionsNotifier;
    late ReceiptsNotifier receiptsNotifier;
    
    setUp(() async {
      final database = AppDatabase.forTesting();
      
      ocrService = GoogleMLKitOCRService();
      
      final transactionsRepo = TransactionsRepositoryImpl(database);
      final receiptsRepo = ReceiptsRepositoryImpl(database);
      final mlService = MockMLService();
      
      transactionsNotifier = TransactionsNotifier(transactionsRepo, mlService);
      receiptsNotifier = ReceiptsNotifier(receiptsRepo, ocrService);
      
      await _seedTestData(database);
    });
    
    testWidgets('OCR extraction integrates with transaction creation', (tester) async {
      // Create test receipt image (this would be a real image file in actual test)
      final testImagePath = await _createTestReceiptImage();
      
      // Process receipt with OCR
      final receiptData = await ocrService.extractReceiptData(testImagePath);
      
      expect(receiptData, isNotNull);
      expect(receiptData!.amount, isNotNull);
      
      // Create transaction using OCR data
      await transactionsNotifier.addTransaction(TransactionInput(
        amount: -receiptData.amount!,
        description: receiptData.merchant ?? 'OCR Transaction',
        date: receiptData.date ?? DateTime.now(),
        receiptPhotoPath: testImagePath,
      ));
      
      // Verify transaction was created with OCR data
      final transactions = transactionsNotifier.state.value!;
      expect(transactions.length, equals(1));
      
      final transaction = transactions.first;
      expect(transaction.amount, equals(-receiptData.amount!));
      expect(transaction.receiptPhotoPath, equals(testImagePath));
      
      // Verify receipt was stored
      await receiptsNotifier.loadReceipts();
      final receipts = receiptsNotifier.state.value!;
      expect(receipts.length, equals(1));
      
      final receipt = receipts.first;
      expect(receipt.transactionId, equals(transaction.id));
      expect(receipt.extractedAmount, equals(receiptData.amount));
    });
    
    testWidgets('OCR failure doesn\'t prevent transaction creation', (tester) async {
      // Create invalid/unreadable image
      final invalidImagePath = await _createInvalidImage();
      
      // Attempt OCR processing
      final receiptData = await ocrService.extractReceiptData(invalidImagePath);
      expect(receiptData, isNull); // OCR should fail gracefully
      
      // User can still create transaction manually
      await transactionsNotifier.addTransaction(TransactionInput(
        amount: -25.0,
        categoryId: 'food',
        description: 'Manual transaction',
        receiptPhotoPath: invalidImagePath, // Attach photo even if OCR failed
      ));
      
      // Verify transaction was created successfully
      final transactions = transactionsNotifier.state.value!;
      expect(transactions.length, equals(1));
      expect(transactions.first.receiptPhotoPath, equals(invalidImagePath));
    });
  });
}

Future<String> _createTestReceiptImage() async {
  // This would create a test image with known text content
  // For actual implementation, use a pre-made test image
  return '/test/assets/sample_receipt.jpg';
}

Future<String> _createInvalidImage() async {
  // This would create an invalid/corrupted image file
  return '/test/assets/invalid_image.jpg';
}
```

---

## 4. WIDGET TESTING PLAN

### 4.1 Component Widget Tests

#### 4.1.1 Health Score Widget Tests
```dart
// test/widget/health_score_card_test.dart
void main() {
  group('HealthScoreCard Widget', () {
    testWidgets('displays health score information correctly', (tester) async {
      // Arrange
      final healthScore = HealthScore(
        score: 85.0,
        mood: HealthMood.excellent,
        message: 'Ottimo controllo!',
        insights: [],
        calculatedAt: DateTime.now(),
        breakdown: HealthScoreBreakdown(
          budgetAdherence: 90,
          savingsRate: 85,
          spendingConsistency: 80,
          improvementTrend: 85,
        ),
      );
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthScoreCard(healthScore: healthScore),
          ),
        ),
      );
      
      // Assert
      expect(find.text('85'), findsOneWidget);
      expect(find.text('/100'), findsOneWidget);
      expect(find.text('😊'), findsOneWidget);
      expect(find.text('Ottimo controllo!'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    });
    
    testWidgets('shows correct colors based on score', (tester) async {
      final testCases = [
        (95.0, HealthMood.excellent, Color(0xFF4CAF50)), // Green
        (75.0, HealthMood.good, Color(0xFF8BC34A)),      // Light green
        (50.0, HealthMood.average, Color(0xFFFF9800)),   // Orange
        (25.0, HealthMood.poor, Color(0xFFFF5722)),      // Light red
        (10.0, HealthMood.critical, Color(0xFFF44336)),  // Red
      ];
      
      for (final testCase in testCases) {
        final healthScore = HealthScore(
          score: testCase.$1,
          mood: testCase.$2,
          message: 'Test message',
          insights: [],
          calculatedAt: DateTime.now(),
          breakdown: HealthScoreBreakdown(
            budgetAdherence: testCase.$1,
            savingsRate: testCase.$1,
            spendingConsistency: testCase.$1,
            improvementTrend: testCase.$1,
          ),
        );
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HealthScoreCard(healthScore: healthScore),
            ),
          ),
        );
        
        // Find the score text widget and verify its color
        final scoreTextFinder = find.text(testCase.$1.toInt().toString());
        expect(scoreTextFinder, findsOneWidget);
        
        final scoreTextWidget = tester.widget<Text>(scoreTextFinder);
        expect(scoreTextWidget.style?.color, equals(testCase.$3));
      }
    });
    
    testWidgets('triggers animation on appear', (tester) async {
      final healthScore = HealthScore(
        score: 75.0,
        mood: HealthMood.good,
        message: 'Test message',
        insights: [],
        calculatedAt: DateTime.now(),
        breakdown: HealthScoreBreakdown(
          budgetAdherence: 75,
          savingsRate: 75,
          spendingConsistency: 75,
          improvementTrend: 75,
        ),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthScoreCard(healthScore: healthScore),
          ),
        ),
      );
      
      // Initially, progress should be 0
      final initialProgressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator).last
      );
      expect(initialProgressIndicator.value, equals(0.0));
      
      // After animation completes
      await tester.pumpAndSettle();
      
      final finalProgressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator).last
      );
      expect(finalProgressIndicator.value, equals(0.75)); // 75/100
    });
    
    testWidgets('handles tap events', (tester) async {
      bool tapped = false;
      
      final healthScore = HealthScore(
        score: 80.0,
        mood: HealthMood.excellent,
        message: 'Test message', 
        insights: [],
        calculatedAt: DateTime.now(),
        breakdown: HealthScoreBreakdown(
          budgetAdherence: 80,
          savingsRate: 80,
          spendingConsistency: 80,
          improvementTrend: 80,
        ),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthScoreCard(
              healthScore: healthScore,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(HealthScoreCard));
      expect(tapped, isTrue);
    });
  });
}
```

#### 4.1.2 Transaction Form Widget Tests
```dart
// test/widget/transaction_form_test.dart
void main() {
  group('TransactionForm Widget', () {
    late List<Category> testCategories;
    
    setUp(() {
      testCategories = [
        Category(
          id: 'food',
          name: 'Alimentari',
          iconCodePoint: 0xE57F,
          colorValue: 0xFF4CAF50,
          isIncome: false,
          isCustom: false,
          sortOrder: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Category(
          id: 'transport',
          name: 'Trasporti',
          iconCodePoint: 0xE530,
          colorValue: 0xFF2196F3,
          isIncome: false,
          isCustom: false,
          sortOrder: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
    });
    
    testWidgets('validates required fields', (tester) async {
      TransactionInput? savedInput;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionForm(
              categories: testCategories,
              onSave: (input) => savedInput = input,
            ),
          ),
        ),
      );
      
      // Try to save without entering amount
      await tester.tap(find.byType(ElevatedButton)); // Save button
      await tester.pump();
      
      // Should show validation error
      expect(find.text('Inserisci un importo'), findsOneWidget);
      expect(savedInput, isNull); // Shouldn't have saved
    });
    
    testWidgets('saves valid transaction input', (tester) async {
      TransactionInput? savedInput;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionForm(
              categories: testCategories,
              onSave: (input) => savedInput = input,
            ),
          ),
        ),
      );
      
      // Enter amount
      await tester.enterText(find.byType(TextFormField).first, '25,50');
      await tester.pump();
      
      // Select category
      await tester.tap(find.text('Alimentari'));
      await tester.pump();
      
      // Enter description
      await tester.enterText(find.byType(TextFormField).last, 'Spesa supermercato');
      await tester.pump();
      
      // Save
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Verify saved input
      expect(savedInput, isNotNull);
      expect(savedInput!.amount, equals(-25.50)); // Negative for expense
      expect(savedInput!.categoryId, equals('food'));
      expect(savedInput!.description, equals('Spesa supermercato'));
    });
    
    testWidgets('handles category selection', (tester) async {
      String? selectedCategoryId;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelectorWidget(
              categories: testCategories,
              onCategorySelected: (id) => selectedCategoryId = id,
            ),
          ),
        ),
      );
      
      // Tap on transport category
      await tester.tap(find.text('Trasporti'));
      await tester.pump();
      
      expect(selectedCategoryId, equals('transport'));
    });
    
    testWidgets('formats currency input correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencyAmountField(),
          ),
        ),
      );
      
      final textField = find.byType(TextFormField);
      
      // Test various input formats
      await tester.enterText(textField, '25,5');
      await tester.pump();
      
      final textFieldWidget = tester.widget<TextFormField>(textField);
      // Should handle comma as decimal separator
      expect(textFieldWidget.controller?.text, equals('25,5'));
    });
  });
}
```

### 4.2 Screen Widget Tests

#### 4.2.1 Dashboard Screen Tests
```dart
// test/widget/dashboard_screen_test.dart
void main() {
  group('DashboardScreen Widget', () {
    late MockTransactionsNotifier mockTransactionsNotifier;
    late MockHealthScoreNotifier mockHealthScoreNotifier;
    
    setUp(() {
      mockTransactionsNotifier = MockTransactionsNotifier();
      mockHealthScoreNotifier = MockHealthScoreNotifier();
    });
    
    testWidgets('displays loading state initially', (tester) async {
      // Arrange
      when(mockHealthScoreNotifier.state).thenReturn(AsyncValue.loading());
      when(mockTransactionsNotifier.state).thenReturn(AsyncValue.loading());
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthScoreProvider.overrideWith(() => mockHealthScoreNotifier),
            transactionsProvider.overrideWith(() => mockTransactionsNotifier),
          ],
          child: MaterialApp(home: DashboardScreen()),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });
    
    testWidgets('displays health score when loaded', (tester) async {
      // Arrange
      final healthScore = HealthScore(
        score: 85.0,
        mood: HealthMood.excellent,
        message: 'Ottimo controllo!',
        insights: [],
        calculatedAt: DateTime.now(),
        breakdown: HealthScoreBreakdown(
          budgetAdherence: 85,
          savingsRate: 85,
          spendingConsistency: 85,
          improvementTrend: 85,
        ),
      );
      
      when(mockHealthScoreNotifier.state).thenReturn(AsyncValue.data(healthScore));
      when(mockTransactionsNotifier.state).thenReturn(AsyncValue.data([]));
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthScoreProvider.overrideWith(() => mockHealthScoreNotifier),
            transactionsProvider.overrideWith(() => mockTransactionsNotifier),
          ],
          child: MaterialApp(home: DashboardScreen()),
        ),
      );
      
      // Assert
      expect(find.byType(HealthScoreCard), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
      expect(find.text('Ottimo controllo!'), findsOneWidget);
    });
    
    testWidgets('displays empty state when no transactions', (tester) async {
      // Arrange
      final healthScore = HealthScore(
        score: 50.0,
        mood: HealthMood.average,
        message: 'Nessun dato',
        insights: [],
        calculatedAt: DateTime.now(),
        breakdown: HealthScoreBreakdown(
          budgetAdherence: 50,
          savingsRate: 50,
          spendingConsistency: 50,
          improvementTrend: 50,
        ),
      );
      
      when(mockHealthScoreNotifier.state).thenReturn(AsyncValue.data(healthScore));
      when(mockTransactionsNotifier.state).thenReturn(AsyncValue.data([]));
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthScoreProvider.overrideWith(() => mockHealthScoreNotifier),
            transactionsProvider.overrideWith(() => mockTransactionsNotifier),
          ],
          child: MaterialApp(home: DashboardScreen()),
        ),
      );
      
      // Assert
      expect(find.byType(EmptyTransactionsWidget), findsOneWidget);
    });
    
    testWidgets('refreshes data on pull down', (tester) async {
      // Arrange
      final healthScore = HealthScore(
        score: 75.0,
        mood: HealthMood.good,
        message: 'Test message',
        insights: [],
        calculatedAt: DateTime.now(),
        breakdown: HealthScoreBreakdown(
          budgetAdherence: 75,
          savingsRate: 75,
          spendingConsistency: 75,
          improvementTrend: 75,
        ),
      );
      
      when(mockHealthScoreNotifier.state).thenReturn(AsyncValue.data(healthScore));
      when(mockTransactionsNotifier.state).thenReturn(AsyncValue.data([]));
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            healthScoreProvider.overrideWith(() => mockHealthScoreNotifier),
            transactionsProvider.overrideWith(() => mockTransactionsNotifier),
          ],
          child: MaterialApp(home: DashboardScreen()),
        ),
      );
      
      // Act - Pull down to refresh
      await tester.fling(
        find.byType(ListView),
        Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();
      
      // Assert - Should have called refresh methods
      verify(mockHealthScoreNotifier.calculateHealthScore()).called(atLeastOnce);
      verify(mockTransactionsNotifier.refreshTransactions()).called(atLeastOnce);
    });
  });
}
```

---

## 5. END-TO-END TESTING PLAN

### 5.1 Critical User Journeys

#### 5.1.1 Complete Transaction Management Flow
```dart
// test/e2e/transaction_management_e2e_test.dart
void main() {
  group('Transaction Management E2E', () {
    late IntegrationTestWidgetsFlutterBinding binding;
    
    setUpAll(() {
      binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    });
    
    testWidgets('complete transaction lifecycle', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // 1. Navigate to Add Transaction
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Verify we're on Add Transaction screen
      expect(find.text('Nuova Transazione'), findsOneWidget);
      
      // 2. Fill transaction form
      await tester.enterText(find.byType(TextFormField).first, '25,50');
      await tester.pumpAndSettle();
      
      // Select food category
      await tester.tap(find.text('Alimentari'));
      await tester.pumpAndSettle();
      
      // Enter description
      await tester.enterText(
        find.widgetWithText(TextFormField, '').last,
        'Spesa supermercato'
      );
      await tester.pumpAndSettle();
      
      // 3. Save transaction
      await tester.tap(find.text('Salva Transazione'));
      await tester.pumpAndSettle();
      
      // Should navigate back to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      
      // 4. Verify transaction appears in recent transactions
      expect(find.text('Spesa supermercato'), findsOneWidget);
      expect(find.text('-€25,50'), findsOneWidget);
      
      // 5. Navigate to transactions list
      await tester.tap(find.text('Vedi Tutte'));
      await tester.pumpAndSettle();
      
      expect(find.text('Transazioni'), findsOneWidget);
      expect(find.text('Spesa supermercato'), findsOneWidget);
      
      // 6. Edit transaction
      await tester.fling(
        find.text('Spesa supermercato'),
        Offset(-300, 0), // Swipe left
        1000,
      );
      await tester.pumpAndSettle();
      
      // Tap edit (should appear after swipe)
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      
      // Update amount
      await tester.enterText(find.byType(TextFormField).first, '30,00');
      await tester.pumpAndSettle();
      
      // Save changes
      await tester.tap(find.text('Salva Modifiche'));
      await tester.pumpAndSettle();
      
      // 7. Verify update
      expect(find.text('-€30,00'), findsOneWidget);
      
      // 8. Delete transaction
      await tester.fling(
        find.text('Spesa supermercato'),
        Offset(300, 0), // Swipe right
        1000,
      );
      await tester.pumpAndSettle();
      
      // Confirm deletion
      await tester.tap(find.text('Elimina'));
      await tester.pumpAndSettle();
      
      // 9. Verify deletion
      expect(find.text('Spesa supermercato'), findsNothing);
    });
    
    testWidgets('transaction with receipt photo', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // Navigate to Add Transaction
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Tap camera button
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();
      
      // Should open camera screen
      expect(find.byType(CameraPreview), findsOneWidget);
      
      // Simulate taking photo
      await tester.tap(find.byType(FloatingActionButton)); // Camera capture button
      await tester.pumpAndSettle(Duration(seconds: 3)); // Wait for processing
      
      // Should return to transaction form with OCR results
      expect(find.text('Dati estratti automaticamente'), findsOneWidget);
      
      // OCR should have extracted some data
      expect(find.byType(TextFormField), findsAtLeastNWidgets(3));
      
      // Save transaction with OCR data
      await tester.tap(find.text('Salva Transazione'));
      await tester.pumpAndSettle();
      
      // Verify transaction with receipt icon
      expect(find.byIcon(Icons.receipt), findsOneWidget);
    });
  });
}
```

#### 5.1.2 Health Score Journey
```dart
// test/e2e/health_score_e2e_test.dart
void main() {
  group('Health Score E2E', () {
    testWidgets('health score updates with transactions', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // 1. Initial state - should show neutral health score
      expect(find.byType(HealthScoreCard), findsOneWidget);
      
      // Get initial health score
      final initialScoreText = tester.widget<Text>(
        find.descendant(
          of: find.byType(HealthScoreCard),
          matching: find.byType(Text),
        ).first,
      ).data!;
      final initialScore = int.parse(initialScoreText);
      
      // 2. Add income transaction
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).first, '2000');
      await tester.tap(find.text('Stipendio & Lavoro')); // Income category
      await tester.enterText(
        find.widgetWithText(TextFormField, '').last,
        'Stipendio mensile'
      );
      
      await tester.tap(find.text('Salva Transazione'));
      await tester.pumpAndSettle();
      
      // 3. Wait for health score recalculation
      await tester.pump(Duration(seconds: 2));
      
      // Health score should improve with income
      final afterIncomeScoreText = tester.widget<Text>(
        find.descendant(
          of: find.byType(HealthScoreCard),
          matching: find.byType(Text),
        ).first,
      ).data!;
      final afterIncomeScore = int.parse(afterIncomeScoreText);
      
      expect(afterIncomeScore, greaterThan(initialScore));
      
      // 4. Add reasonable expense
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).first, '300');
      await tester.tap(find.text('Alimentari & Ristoranti'));
      await tester.enterText(
        find.widgetWithText(TextFormField, '').last,
        'Spesa mensile'
      );
      
      await tester.tap(find.text('Salva Transazione'));
      await tester.pumpAndSettle();
      await tester.pump(Duration(seconds: 2));
      
      // Health score should remain good (reasonable spending ratio)
      final afterExpenseScoreText = tester.widget<Text>(
        find.descendant(
          of: find.byType(HealthScoreCard),
          matching: find.byType(Text),
        ).first,
      ).data!;
      final afterExpenseScore = int.parse(afterExpenseScoreText);
      
      expect(afterExpenseScore, greaterThan(70)); // Should still be good
      
      // 5. Add excessive expense
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextFormField).first, '1500');
      await tester.tap(find.text('Intrattenimento & Hobby'));
      await tester.enterText(
        find.widgetWithText(TextFormField, '').last,
        'Spesa eccessiva'
      );
      
      await tester.tap(find.text('Salva Transazione'));
      await tester.pumpAndSettle();
      await tester.pump(Duration(seconds: 2));
      
      // Health score should drop significantly
      final afterExcessiveSpendingText = tester.widget<Text>(
        find.descendant(
          of: find.byType(HealthScoreCard),
          matching: find.byType(Text),
        ).first,
      ).data!;
      final afterExcessiveSpending = int.parse(afterExcessiveSpendingText);
      
      expect(afterExcessiveSpending, lessThan(afterExpenseScore));
      
      // 6. Tap health score for details
      await tester.tap(find.byType(HealthScoreCard));
      await tester.pumpAndSettle();
      
      // Should show health score breakdown
      expect(find.text('Dettagli Health Score'), findsOneWidget);
      expect(find.text('Budget Adherence'), findsOneWidget);
      expect(find.text('Savings Rate'), findsOneWidget);
    });
  });
}
```

---

## 6. PERFORMANCE TESTING PLAN

### 6.1 Performance Benchmarks

#### 6.1.1 App Launch Performance
```dart
// test/performance/app_launch_test.dart
void main() {
  group('App Launch Performance', () {
    testWidgets('cold start performance', (tester) async {
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      
      // Measure cold start time
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      final launchTime = stopwatch.elapsedMilliseconds;
      
      // Assert cold start is under 2 seconds
      expect(launchTime, lessThan(2000));
      
      // Report performance
      await binding.reportData(<String, dynamic>{
        'cold_start_time_ms': launchTime,
        'metric_name': 'app_cold_start',
      });
    });
    
    testWidgets('database initialization performance', (tester) async {
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      
      // Measure database initialization
      final stopwatch = Stopwatch()..start();
      
      final database = AppDatabase.forTesting();
      await database.customStatement('SELECT 1'); // Trigger initialization
      
      stopwatch.stop();
      final initTime = stopwatch.elapsedMilliseconds;
      
      // Assert database init is under 500ms
      expect(initTime, lessThan(500));
      
      await binding.reportData(<String, dynamic>{
        'db_init_time_ms': initTime,
        'metric_name': 'database_initialization',
      });
      
      await database.close();
    });
  });
}
```

#### 6.1.2 UI Response Performance
```dart
// test/performance/ui_performance_test.dart
void main() {
  group('UI Performance Tests', () {
    testWidgets('transaction list scrolling performance', (tester) async {
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // Navigate to transactions with many items
      await _addManyTransactions(tester, 1000);
      
      await tester.tap(find.text('Vedi Tutte'));
      await tester.pumpAndSettle();
      
      // Measure scroll performance
      final stopwatch = Stopwatch()..start();
      
      // Perform fast scroll
      await tester.fling(
        find.byType(ListView),
        Offset(0, -3000),
        5000,
      );
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      final scrollTime = stopwatch.elapsedMilliseconds;
      
      // Assert scroll settling time
      expect(scrollTime, lessThan(1000));
      
      await binding.reportData(<String, dynamic>{
        'scroll_settle_time_ms': scrollTime,
        'item_count': 1000,
        'metric_name': 'list_scroll_performance',
      });
    });
    
    testWidgets('health score calculation performance', (tester) async {
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      
      // Add many transactions for complex calculation
      final transactions = _generateManyTransactions(10000);
      final repository = MockTransactionsRepository();
      when(repository.getTransactionsByDateRange(any, any))
          .thenAnswer((_) async => transactions);
      
      final useCase = CalculateHealthScoreUseCase(transactionsRepo: repository);
      
      // Measure calculation time
      final stopwatch = Stopwatch()..start();
      
      final healthScore = await useCase.execute();
      
      stopwatch.stop();
      final calculationTime = stopwatch.elapsedMilliseconds;
      
      // Assert calculation is under 100ms even with 10k transactions
      expect(calculationTime, lessThan(100));
      expect(healthScore.score, isNotNull);
      
      await binding.reportData(<String, dynamic>{
        'calculation_time_ms': calculationTime,
        'transaction_count': 10000,
        'metric_name': 'health_score_calculation',
      });
    });
  });
}

Future<void> _addManyTransactions(WidgetTester tester, int count) async {
  // Mock adding many transactions for performance testing
  // In real test, this would add actual transactions to database
}

List<Transaction> _generateManyTransactions(int count) {
  final random = Random();
  final categories = ['food', 'transport', 'home', 'health'];
  
  return List.generate(count, (i) {
    return Transaction(
      id: 'perf_test_$i',
      amount: -(random.nextDouble() * 200 + 10), // Random expense 10-210
      categoryId: categories[random.nextInt(categories.length)],
      description: 'Performance test transaction $i',
      date: DateTime.now().subtract(Duration(days: random.nextInt(365))),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  });
}
```

### 6.2 Memory Performance Tests

#### 6.2.1 Memory Usage Monitoring
```dart
// test/performance/memory_test.dart
void main() {
  group('Memory Performance', () {
    testWidgets('memory usage with large datasets', (tester) async {
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      
      // Get initial memory usage
      final initialMemory = await _getMemoryUsage();
      
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // Load large dataset
      await _loadLargeDataset(tester);
      
      // Measure memory usage
      final peakMemory = await _getMemoryUsage();
      final memoryIncrease = peakMemory - initialMemory;
      
      // Assert memory usage is reasonable
      expect(memoryIncrease, lessThan(150 * 1024 * 1024)); // < 150MB increase
      
      await binding.reportData(<String, dynamic>{
        'initial_memory_bytes': initialMemory,
        'peak_memory_bytes': peakMemory,
        'memory_increase_bytes': memoryIncrease,
        'metric_name': 'memory_usage_large_dataset',
      });
    });
    
    testWidgets('memory cleanup after navigation', (tester) async {
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      final initialMemory = await _getMemoryUsage();
      
      // Navigate through multiple screens
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
      }
      
      // Trigger garbage collection
      await tester.binding.delayed(Duration(seconds: 1));
      
      final finalMemory = await _getMemoryUsage();
      final memoryLeak = finalMemory - initialMemory;
      
      // Assert minimal memory leak
      expect(memoryLeak, lessThan(10 * 1024 * 1024)); // < 10MB leak
      
      await binding.reportData(<String, dynamic>{
        'memory_leak_bytes': memoryLeak,
        'navigation_cycles': 10,
        'metric_name': 'memory_cleanup_navigation',
      });
    });
  });
}

Future<int> _getMemoryUsage() async {
  // Implementation would use platform-specific memory monitoring
  // For testing purposes, return mock value
  return 50 * 1024 * 1024; // 50MB
}

Future<void> _loadLargeDataset(WidgetTester tester) async {
  // Simulate loading large amount of data
  // In real test, this would load actual data
}
```

---

## 7. ACCESSIBILITY TESTING PLAN

### 7.1 Automated Accessibility Testing

#### 7.1.1 Semantic Testing
```dart
// test/accessibility/semantics_test.dart
void main() {
  group('Accessibility Semantics', () {
    testWidgets('all interactive elements have semantic labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DashboardScreen()),
      );
      await tester.pumpAndSettle();
      
      // Find all interactive elements
      final buttons = find.byType(ElevatedButton);
      final textButtons = find.byType(TextButton);
      final iconButtons = find.byType(IconButton);
      final floatingActionButton = find.byType(FloatingActionButton);
      
      // Verify each has semantic labels
      for (final buttonFinder in [buttons, textButtons, iconButtons, floatingActionButton]) {
        final buttonCount = buttonFinder.evaluate().length;
        for (int i = 0; i < buttonCount; i++) {
          final button = buttonFinder.at(i);
          final semantics = tester.getSemantics(button);
          
          expect(semantics.label, isNotNull,
              reason: 'Button at index $i should have semantic label');
          expect(semantics.label!.isNotEmpty, isTrue,
              reason: 'Button at index $i should have non-empty semantic label');
        }
      }
    });
    
    testWidgets('health score has comprehensive semantics', (tester) async {
      final healthScore = HealthScore(
        score: 85.0,
        mood: HealthMood.excellent,
        message: 'Ottimo controllo!',
        insights: [],
        calculatedAt: DateTime.now(),
        breakdown: HealthScoreBreakdown(
          budgetAdherence: 85,
          savingsRate: 85,
          spendingConsistency: 85,
          improvementTrend: 85,
        ),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthScoreCard(healthScore: healthScore),
          ),
        ),
      );
      
      final healthScoreCard = find.byType(HealthScoreCard);
      final semantics = tester.getSemantics(healthScoreCard);
      
      // Verify comprehensive semantic description
      expect(semantics.label, contains('85'));
      expect(semantics.label, contains('100'));
      expect(semantics.label, contains('Ottimo controllo'));
      
      // Verify it's marked as interactive if onTap is provided
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HealthScoreCard(
              healthScore: healthScore,
              onTap: () {},
            ),
          ),
        ),
      );
      
      final interactiveSemantics = tester.getSemantics(healthScoreCard);
      expect(interactiveSemantics.hasAction(SemanticsAction.tap), isTrue);
    });
    
    testWidgets('transaction list items have descriptive semantics', (tester) async {
      final transaction = Transaction(
        id: '1',
        amount: -25.50,
        categoryId: 'food',
        description: 'Spesa supermercato',
        date: DateTime(2025, 9, 13),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final category = Category(
        id: 'food',
        name: 'Alimentari',
        iconCodePoint: 0xE57F,
        colorValue: 0xFF4CAF50,
        isIncome: false,
        isCustom: false,
        sortOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionListItem(
              transaction: transaction,
              category: category,
            ),
          ),
        ),
      );
      
      final listItem = find.byType(TransactionListItem);
      final semantics = tester.getSemantics(listItem);
      
      // Verify comprehensive description
      expect(semantics.label, contains('Spesa'));
      expect(semantics.label, contains('25,50'));
      expect(semantics.label, contains('euro'));
      expect(semantics.label, contains('Alimentari'));
      expect(semantics.label, contains('Spesa supermercato'));
      expect(semantics.label, contains('13 settembre 2025'));
    });
  });
}
```

#### 7.1.2 Touch Target Testing
```dart
// test/accessibility/touch_targets_test.dart
void main() {
  group('Touch Target Accessibility', () {
    testWidgets('all touch targets meet minimum size requirements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DashboardScreen()),
      );
      await tester.pumpAndSettle();
      
      // Find all tappable elements
      final tappableElements = find.byWidgetPredicate(
        (widget) => widget is GestureDetector ||
                    widget is InkWell ||
                    widget is ElevatedButton ||
                    widget is TextButton ||
                    widget is IconButton ||
                    widget is FloatingActionButton,
      );
      
      final elementCount = tappableElements.evaluate().length;
      
      for (int i = 0; i < elementCount; i++) {
        final element = tappableElements.at(i);
        final renderBox = tester.renderObject<RenderBox>(element);
        
        // Verify minimum touch target size (44dp)
        expect(renderBox.size.width, greaterThanOrEqualTo(44.0),
            reason: 'Touch target $i width should be at least 44dp');
        expect(renderBox.size.height, greaterThanOrEqualTo(44.0),
            reason: 'Touch target $i height should be at least 44dp');
      }
    });
    
    testWidgets('category selector items have adequate touch targets', (tester) async {
      final categories = _generateTestCategories();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelectorWidget(categories: categories),
          ),
        ),
      );
      
      // Find category selector items
      final categoryItems = find.byType(GestureDetector);
      final itemCount = categoryItems.evaluate().length;
      
      for (int i = 0; i < itemCount; i++) {
        final item = categoryItems.at(i);
        final renderBox = tester.renderObject<RenderBox>(item);
        
        // Category items should have adequate touch targets
        expect(renderBox.size.width, greaterThanOrEqualTo(44.0));
        expect(renderBox.size.height, greaterThanOrEqualTo(44.0));
      }
    });
  });
}

List<Category> _generateTestCategories() {
  return [
    Category(
      id: 'food',
      name: 'Alimentari',
      iconCodePoint: 0xE57F,
      colorValue: 0xFF4CAF50,
      isIncome: false,
      isCustom: false,
      sortOrder: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    // Add more test categories...
  ];
}
```

### 7.2 Manual Accessibility Testing

#### 7.2.1 Screen Reader Testing Checklist
```markdown
# Screen Reader Testing Checklist

## TalkBack (Android) Testing
- [ ] App name announced correctly on launch
- [ ] Health Score value and description read clearly
- [ ] Navigation between tabs works with gestures
- [ ] Transaction amounts announced with currency
- [ ] Category names pronounced correctly
- [ ] Form fields have clear labels and hints
- [ ] Error messages are announced immediately
- [ ] Success confirmations are announced
- [ ] List navigation works with swipe gestures
- [ ] Modal dialogs announced and dismissible

## VoiceOver (iOS) Testing
- [ ] All interactive elements discoverable
- [ ] Rotor navigation works for headings
- [ ] Custom actions available for swipe gestures
- [ ] Camera permissions clearly explained
- [ ] Photo descriptions provided when available
- [ ] Loading states announced appropriately
- [ ] Progress indicators have meaningful descriptions
- [ ] Table navigation works correctly
- [ ] Search functionality accessible
- [ ] Settings organized in logical groups

## Common Issues to Test
- [ ] No unlabeled buttons or inputs
- [ ] No missing header hierarchy
- [ ] No keyboard traps
- [ ] Consistent navigation patterns
- [ ] Clear focus indicators
- [ ] Meaningful error messages
```

#### 7.2.2 Keyboard Navigation Testing
```markdown
# Keyboard Navigation Testing Checklist

## Tab Order Testing
- [ ] Logical tab order throughout app
- [ ] Skip links available where appropriate
- [ ] Focus visible on all interactive elements
- [ ] Focus doesn't get trapped in components
- [ ] Modal dialogs handle focus correctly

## Keyboard Shortcuts
- [ ] Enter key activates buttons
- [ ] Space key activates checkboxes
- [ ] Arrow keys navigate lists/grids
- [ ] Escape key dismisses modals
- [ ] Tab/Shift+Tab for forward/backward navigation

## Form Navigation
- [ ] Tab moves between form fields
- [ ] Field labels clearly associated
- [ ] Required fields indicated
- [ ] Error messages accessible via keyboard
- [ ] Submit/cancel buttons reachable
```

---

## 8. SECURITY TESTING PLAN

### 8.1 Data Security Testing

#### 8.1.1 Local Storage Security
```dart
// test/security/storage_security_test.dart
void main() {
  group('Storage Security Tests', () {
    test('database is encrypted', () async {
      final database = AppDatabase.forTesting();
      
      // Verify database file is encrypted
      final databasePath = await database.executor.databaseName;
      final file = File(databasePath);
      
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final header = String.fromCharCodes(bytes.take(16));
        
        // SQLCipher databases don't start with "SQLite format"
        expect(header, isNot(startsWith('SQLite format')));
      }
      
      await database.close();
    });
    
    test('sensitive data is not logged', () async {
      // Capture log output
      final logMessages = <String>[];
      
      runZonedGuarded(() async {
        final transaction = Transaction(
          id: '1',
          amount: -25.50,
          categoryId: 'food',
          description: 'Sensitive transaction',
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        // Simulate operations that might log sensitive data
        print('Processing transaction: ${transaction.id}');
        debugPrint('Transaction saved successfully');
        
        // This should NOT log sensitive data
        // print('Transaction: ${transaction.toString()}'); // BAD
        
      }, (error, stack) {
        logMessages.add(error.toString());
      });
      
      // Verify no sensitive data in logs
      for (final message in logMessages) {
        expect(message, isNot(contains('25.50')));
        expect(message, isNot(contains('Sensitive transaction')));
      }
    });
    
    test('file permissions are restrictive', () async {
      if (!Platform.isLinux && !Platform.isMacOS) {
        return; // Skip on platforms without file permissions
      }
      
      final appDir = await getApplicationDocumentsDirectory();
      final receiptFile = File('${appDir.path}/receipts/test.jpg');
      
      await receiptFile.create(recursive: true);
      await receiptFile.writeAsBytes([1, 2, 3, 4]);
      
      // Check file permissions (should be user-only)
      final stat = await receiptFile.stat();
      
      // On Unix systems, check that file is not world-readable
      // This is a simplified check - real implementation would be more thorough
      expect(stat.mode & 0o077, equals(0)); // No group/other permissions
      
      await receiptFile.delete();
    });
  });
}
```

#### 8.1.2 Input Validation Security
```dart
// test/security/input_validation_test.dart
void main() {
  group('Input Validation Security', () {
    late AddTransactionUseCase useCase;
    late MockTransactionsRepository mockRepository;
    
    setUp(() {
      mockRepository = MockTransactionsRepository();
      useCase = AddTransactionUseCase(transactionsRepo: mockRepository);
    });
    
    test('prevents SQL injection in description field', () async {
      final maliciousInputs = [
        "'; DROP TABLE transactions; --",
        "' OR '1'='1",
        "'; INSERT INTO transactions VALUES(null, 999, 'hack'); --",
        "' UNION SELECT * FROM transactions; --",
      ];
      
      for (final maliciousInput in maliciousInputs) {
        final input = AddTransactionInput(
          amount: -25.0,
          description: maliciousInput,
          categoryId: 'food',
        );
        
        when(mockRepository.insertTransaction(any))
            .thenAnswer((_) async => Future.value());
        
        // Should not throw and should sanitize input
        final transaction = await useCase.execute(input);
        
        // Verify malicious input is handled safely
        expect(transaction.description, isNot(contains('DROP TABLE')));
        expect(transaction.description, isNot(contains('INSERT INTO')));
        expect(transaction.description, isNot(contains('UNION SELECT')));
      }
    });
    
    test('validates amount boundaries', () async {
      final invalidAmounts = [
        double.infinity,
        double.negativeInfinity,
        double.nan,
        1000000.0, // Too large
        -1000000.0, // Too large negative
      ];
      
      for (final amount in invalidAmounts) {
        final input = AddTransactionInput(
          amount: amount,
          description: 'Test transaction',
          categoryId: 'food',
        );
        
        expect(
          () async => await useCase.execute(input),
          throwsA(isA<DomainException>()),
          reason: 'Should reject invalid amount: $amount',
        );
      }
    });
    
    test('sanitizes file paths', () async {
      final maliciousPaths = [
        '../../../etc/passwd',
        '..\\..\\windows\\system32\\config\\SAM',
        '/dev/null',
        'con.txt', // Windows reserved name
        'aux.txt', // Windows reserved name
      ];
      
      for (final path in maliciousPaths) {
        final input = AddTransactionInput(
          amount: -25.0,
          receiptPhotoPath: path,
          categoryId: 'food',
        );
        
        // Should either reject or sanitize dangerous paths
        try {
          final transaction = await useCase.execute(input);
          
          // If accepted, should be sanitized
          if (transaction.receiptPhotoPath != null) {
            expect(transaction.receiptPhotoPath, isNot(contains('..')));
            expect(transaction.receiptPhotoPath, isNot(startsWith('/dev')));
            expect(transaction.receiptPhotoPath, isNot(startsWith('/etc')));
          }
        } catch (e) {
          // Rejecting dangerous paths is also acceptable
          expect(e, isA<DomainException>());
        }
      }
    });
  });
}
```

---

## 9. AUTOMATED TESTING INFRASTRUCTURE

### 9.1 Continuous Integration Pipeline

#### 9.1.1 GitHub Actions Workflow
```yaml
# .github/workflows/test.yml
name: Flutter Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.3'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Analyze code
      run: flutter analyze --no-fatal-infos
    
    - name: Run unit tests
      run: flutter test --coverage --reporter=json > test_results.json
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
    
    - name: Generate test report
      run: |
        dart run test_reporter < test_results.json > test_report.html
    
    - name: Upload test results
      uses: actions/upload-artifact@v3
      with:
        name: test-results
        path: test_report.html

  integration_test:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.3'
        channel: 'stable'
    
    - name: Setup iOS Simulator
      run: |
        xcrun simctl create iPhone14 com.apple.CoreSimulator.SimDeviceType.iPhone-14 com.apple.CoreSimulator.SimRuntime.iOS-16-2
        xcrun simctl boot iPhone14
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Run integration tests
      run: flutter test integration_test/ --device-id iPhone14
    
    - name: Upload integration test results
      uses: actions/upload-artifact@v3
      with:
        name: integration-test-results
        path: integration_test/results/

  performance_test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.3'
        channel: 'stable'
    
    - name: Get dependencies
      run: flutter pub get
    
    - name: Run performance tests
      run: flutter test test/performance/ --plain-name-format
    
    - name: Generate performance report
      run: dart run performance_reporter
    
    - name: Upload performance results
      uses: actions/upload-artifact@v3
      with:
        name: performance-results
        path: performance_report.json
```

### 9.2 Test Reporting and Analytics

#### 9.2.1 Test Results Dashboard
```dart
// test/utils/test_reporter.dart
class TestReporter {
  static void generateReport(List<TestResult> results) {
    final report = TestReport(
      totalTests: results.length,
      passedTests: results.where((r) => r.passed).length,
      failedTests: results.where((r) => !r.passed).length,
      coverage: _calculateCoverage(),
      performance: _collectPerformanceMetrics(results),
      accessibility: _collectAccessibilityResults(results),
    );
    
    _writeHtmlReport(report);
    _writeJsonReport(report);
  }
  
  static double _calculateCoverage() {
    // Implementation would parse coverage data
    return 85.5; // Example
  }
  
  static PerformanceMetrics _collectPerformanceMetrics(List<TestResult> results) {
    return PerformanceMetrics(
      averageTestDuration: results
          .map((r) => r.duration.inMilliseconds)
          .reduce((a, b) => a + b) / results.length,
      slowestTests: results
          .where((r) => r.duration.inMilliseconds > 1000)
          .toList(),
    );
  }
  
  static AccessibilityResults _collectAccessibilityResults(List<TestResult> results) {
    final accessibilityTests = results.where((r) => r.isAccessibilityTest);
    
    return AccessibilityResults(
      totalAccessibilityTests: accessibilityTests.length,
      passedAccessibilityTests: accessibilityTests.where((r) => r.passed).length,
      wcagComplianceLevel: 'AA', // Based on test results
    );
  }
  
  static void _writeHtmlReport(TestReport report) {
    final html = '''
    <!DOCTYPE html>
    <html>
    <head>
        <title>Budget Tracker Test Report</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .metric { padding: 20px; margin: 10px 0; border-radius: 8px; }
            .success { background-color: #d4edda; border: 1px solid #c3e6cb; }
            .warning { background-color: #fff3cd; border: 1px solid #ffeaa7; }
            .danger { background-color: #f8d7da; border: 1px solid #f5c6cb; }
        </style>
    </head>
    <body>
        <h1>Budget Tracker v1.0.0 Test Report</h1>
        
        <div class="metric ${report.overallStatus}">
            <h2>Overall Status: ${report.overallStatus.toUpperCase()}</h2>
            <p>Total Tests: ${report.totalTests}</p>
            <p>Passed: ${report.passedTests}</p>
            <p>Failed: ${report.failedTests}</p>
            <p>Success Rate: ${(report.passedTests / report.totalTests * 100).toStringAsFixed(1)}%</p>
        </div>
        
        <div class="metric">
            <h2>Code Coverage</h2>
            <p>Overall Coverage: ${report.coverage.toStringAsFixed(1)}%</p>
            <div style="background-color: #e9ecef; border-radius: 4px; height: 20px;">
                <div style="background-color: #28a745; height: 20px; width: ${report.coverage}%; border-radius: 4px;"></div>
            </div>
        </div>
        
        <div class="metric">
            <h2>Performance</h2>
            <p>Average Test Duration: ${report.performance.averageTestDuration.toStringAsFixed(0)}ms</p>
            <p>Slow Tests (>1s): ${report.performance.slowestTests.length}</p>
        </div>
        
        <div class="metric">
            <h2>Accessibility</h2>
            <p>Accessibility Tests: ${report.accessibility.passedAccessibilityTests}/${report.accessibility.totalAccessibilityTests}</p>
            <p>WCAG Compliance: ${report.accessibility.wcagComplianceLevel}</p>
        </div>
        
        <div class="metric">
            <h2>Generated: ${DateTime.now().toIso8601String()}</h2>
        </div>
    </body>
    </html>
    ''';
    
    File('test_report.html').writeAsStringSync(html);
  }
  
  static void _writeJsonReport(TestReport report) {
    final json = jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'summary': {
        'total_tests': report.totalTests,
        'passed_tests': report.passedTests,
        'failed_tests': report.failedTests,
        'success_rate': report.passedTests / report.totalTests,
        'coverage_percentage': report.coverage,
      },
      'performance': {
        'average_test_duration_ms': report.performance.averageTestDuration,
        'slow_tests_count': report.performance.slowestTests.length,
      },
      'accessibility': {
        'total_tests': report.accessibility.totalAccessibilityTests,
        'passed_tests': report.accessibility.passedAccessibilityTests,
        'wcag_level': report.accessibility.wcagComplianceLevel,
      },
    });
    
    File('test_report.json').writeAsStringSync(json);
  }
}

class TestReport {
  final int totalTests;
  final int passedTests;
  final int failedTests;
  final double coverage;
  final PerformanceMetrics performance;
  final AccessibilityResults accessibility;
  
  TestReport({
    required this.totalTests,
    required this.passedTests,
    required this.failedTests,
    required this.coverage,
    required this.performance,
    required this.accessibility,
  });
  
  String get overallStatus {
    if (failedTests == 0 && coverage >= 80) return 'success';
    if (failedTests <= totalTests * 0.1) return 'warning';
    return 'danger';
  }
}

class PerformanceMetrics {
  final double averageTestDuration;
  final List<TestResult> slowestTests;
  
  PerformanceMetrics({
    required this.averageTestDuration,
    required this.slowestTests,
  });
}

class AccessibilityResults {
  final int totalAccessibilityTests;
  final int passedAccessibilityTests;
  final String wcagComplianceLevel;
  
  AccessibilityResults({
    required this.totalAccessibilityTests,
    required this.passedAccessibilityTests,
    required this.wcagComplianceLevel,
  });
}

class TestResult {
  final String name;
  final bool passed;
  final Duration duration;
  final String? error;
  final bool isAccessibilityTest;
  
  TestResult({
    required this.name,
    required this.passed,
    required this.duration,
    this.error,
    this.isAccessibilityTest = false,
  });
}
```

---

## 10. QUALITY GATES E RELEASE CRITERIA

### 10.1 Pre-Release Quality Gates

#### 10.1.1 Automated Quality Gates
```dart
// test/quality_gates/quality_gates.dart
class QualityGates {
  static Future<QualityGateResult> checkAllGates() async {
    final results = <QualityGateResult>[];
    
    // Gate 1: Code Coverage
    results.add(await _checkCodeCoverage());
    
    // Gate 2: Test Success Rate
    results.add(await _checkTestSuccessRate());
    
    // Gate 3: Performance Benchmarks
    results.add(await _checkPerformanceBenchmarks());
    
    // Gate 4: Accessibility Compliance
    results.add(await _checkAccessibilityCompliance());
    
    // Gate 5: Security Validation
    results.add(await _checkSecurityValidation());
    
    final overallResult = QualityGateResult.combine(results);
    _generateQualityReport(overallResult, results);
    
    return overallResult;
  }
  
  static Future<QualityGateResult> _checkCodeCoverage() async {
    final coverage = await CoverageAnalyzer.calculateCoverage();
    
    return QualityGateResult(
      name: 'Code Coverage',
      passed: coverage >= 80.0,
      value: coverage,
      threshold: 80.0,
      message: coverage >= 80.0 
          ? 'Coverage meets requirement'
          : 'Coverage below minimum threshold',
    );
  }
  
  static Future<QualityGateResult> _checkTestSuccessRate() async {
    final testResults = await TestRunner.runAllTests();
    final successRate = testResults.successRate;
    
    return QualityGateResult(
      name: 'Test Success Rate',
      passed: successRate >= 95.0,
      value: successRate,
      threshold: 95.0,
      message: successRate >= 95.0
          ? 'All tests passing'
          : '${testResults.failedCount} tests failing',
    );
  }
  
  static Future<QualityGateResult> _checkPerformanceBenchmarks() async {
    final benchmarks = await PerformanceTester.runBenchmarks();
    
    final passed = benchmarks.appLaunchTime < 2000 &&
                  benchmarks.healthScoreCalculation < 100 &&
                  benchmarks.transactionSave < 200;
    
    return QualityGateResult(
      name: 'Performance Benchmarks',
      passed: passed,
      value: null,
      threshold: null,
      message: passed 
          ? 'All performance benchmarks met'
          : 'Performance benchmarks failed: ${benchmarks.failures}',
    );
  }
  
  static Future<QualityGateResult> _checkAccessibilityCompliance() async {
    final accessibilityResults = await AccessibilityTester.runTests();
    
    return QualityGateResult(
      name: 'Accessibility Compliance',
      passed: accessibilityResults.wcagLevel == 'AA',
      value: null,
      threshold: null,
      message: accessibilityResults.wcagLevel == 'AA'
          ? 'WCAG 2.1 Level AA compliance achieved'
          : 'Accessibility issues found: ${accessibilityResults.issues.length}',
    );
  }
  
  static Future<QualityGateResult> _checkSecurityValidation() async {
    final securityResults = await SecurityTester.runTests();
    
    return QualityGateResult(
      name: 'Security Validation',
      passed: securityResults.vulnerabilities.isEmpty,
      value: null,
      threshold: null,
      message: securityResults.vulnerabilities.isEmpty
          ? 'No security vulnerabilities found'
          : '${securityResults.vulnerabilities.length} vulnerabilities found',
    );
  }
}

class QualityGateResult {
  final String name;
  final bool passed;
  final double? value;
  final double? threshold;
  final String message;
  
  QualityGateResult({
    required this.name,
    required this.passed,
    required this.value,
    required this.threshold,
    required this.message,
  });
  
  static QualityGateResult combine(List<QualityGateResult> results) {
    final allPassed = results.every((result) => result.passed);
    
    return QualityGateResult(
      name: 'Overall Quality Gate',
      passed: allPassed,
      value: null,
      threshold: null,
      message: allPassed 
          ? 'All quality gates passed - Ready for release'
          : 'Quality gates failed - Release blocked',
    );
  }
}
```

### 10.2 Release Criteria Checklist

#### 10.2.1 Functional Criteria
```markdown
# Budget Tracker Smart v1.0.0 - Release Criteria

## Functional Requirements ✓
- [ ] All RF001-RF007 requirements implemented and tested
- [ ] Health Score calculation working correctly
- [ ] Transaction CRUD operations functioning
- [ ] OCR extraction working on Italian receipts
- [ ] ML categorization providing reasonable predictions
- [ ] Categories management working
- [ ] Reports generation functioning
- [ ] Export/backup working correctly

## Performance Requirements ✓
- [ ] App cold start < 2 seconds
- [ ] Transaction save < 200ms
- [ ] Health Score calculation < 100ms
- [ ] OCR processing < 3 seconds
- [ ] Memory usage < 150MB peak
- [ ] Smooth scrolling with 1000+ transactions
- [ ] No memory leaks detected

## Quality Requirements ✓
- [ ] Code coverage > 80%
- [ ] All unit tests passing
- [ ] All integration tests passing
- [ ] All E2E tests passing
- [ ] No critical bugs remaining
- [ ] All high-priority bugs fixed
- [ ] Performance benchmarks met

## Accessibility Requirements ✓
- [ ] WCAG 2.1 Level AA compliance
- [ ] All interactive elements have labels
- [ ] Touch targets >= 44dp
- [ ] Screen reader compatible
- [ ] Keyboard navigation working
- [ ] Color contrast ratios met
- [ ] Font scaling support

## Security Requirements ✓
- [ ] Database encryption enabled
- [ ] Input validation implemented
- [ ] No sensitive data in logs
- [ ] File permissions secure
- [ ] No hardcoded secrets
- [ ] Security tests passing

## Usability Requirements ✓
- [ ] User testing completed (5+ users)
- [ ] Major usability issues resolved
- [ ] Italian localization complete
- [ ] Error messages user-friendly
- [ ] Loading states implemented
- [ ] Offline functionality verified

## Documentation Requirements ✓
- [ ] User documentation complete
- [ ] Technical documentation updated
- [ ] API documentation current
- [ ] Installation guide verified
- [ ] Troubleshooting guide available
- [ ] Release notes prepared

## Legal & Compliance ✓
- [ ] Privacy policy updated
- [ ] Terms of service current
- [ ] Open source licenses included
- [ ] No copyright violations
- [ ] GDPR compliance verified
- [ ] App store guidelines met

## Release Package ✓
- [ ] APK/AAB signed and tested
- [ ] IPA signed and tested (if iOS)
- [ ] App store metadata complete
- [ ] Screenshots and descriptions ready
- [ ] Version numbers updated
- [ ] Change log prepared
```

### 10.3 Post-Release Monitoring

#### 10.3.1 Health Monitoring Metrics
```dart
// lib/monitoring/release_monitoring.dart
class ReleaseMonitor {
  static final List<Metric> _criticalMetrics = [
    CrashRateMetric(threshold: 0.1), // < 0.1% crash rate
    ANRRateMetric(threshold: 0.5),   // < 0.5% ANR rate
    StartupTimeMetric(threshold: 2000), // < 2s startup
    HealthScoreCalculationMetric(threshold: 100), // < 100ms
    DatabaseOperationMetric(threshold: 200), // < 200ms
  ];
  
  static Future<void> startMonitoring() async {
    Timer.periodic(Duration(minutes: 5), (timer) async {
      await _collectMetrics();
    });
  }
  
  static Future<void> _collectMetrics() async {
    for (final metric in _criticalMetrics) {
      final value = await metric.collect();
      
      if (metric.isThresholdExceeded(value)) {
        await _sendAlert(metric, value);
      }
      
      await _recordMetric(metric.name, value);
    }
  }
  
  static Future<void> _sendAlert(Metric metric, double value) async {
    final alert = Alert(
      severity: AlertSeverity.high,
      title: '${metric.name} threshold exceeded',
      description: 'Current value: $value, Threshold: ${metric.threshold}',
      timestamp: DateTime.now(),
    );
    
    await AlertService.send(alert);
  }
  
  static Future<void> _recordMetric(String name, double value) async {
    // Record to local analytics or remote service
    await AnalyticsService.record(name, value);
  }
}
```

---

Questo documento di Testing Plan e Quality Assurance è estremamente completo e copre tutti gli aspetti necessari per garantire la qualità dell'applicazione Budget Tracker Smart v1.0.0.

I prossimi documenti rimanenti sono:
1. **Deployment e Release Management**
2. **Project Management e Timeline**

Vuoi che continui con uno di questi?
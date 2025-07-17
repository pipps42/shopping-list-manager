import 'package:shopping_list_manager/models/loyalty_card.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/department.dart';
import '../models/product.dart';
import '../models/shopping_list.dart';
import '../models/list_item.dart';
import '../models/department_with_products.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'shopping_list.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// Chiude la connessione al database e pulisce le risorse
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabella reparti
    await db.execute('''
      CREATE TABLE departments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        image_path TEXT
      )
    ''');

    // Tabella prodotti
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        department_id INTEGER NOT NULL,
        image_path TEXT,
        FOREIGN KEY (department_id) REFERENCES departments (id)
      )
    ''');

    // Tabella liste della spesa
    await db.execute('''
      CREATE TABLE shopping_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        completed_at INTEGER,
        total_cost REAL
      )
    ''');

    // Tabella items delle liste
    await db.execute('''
      CREATE TABLE list_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        is_checked INTEGER NOT NULL DEFAULT 0,
        added_at INTEGER NOT NULL,
        FOREIGN KEY (list_id) REFERENCES shopping_lists (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Tabella carte fedeltà
    await db.execute('''
      CREATE TABLE loyalty_cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        image_path TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Inserisci dati iniziali
    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    // Reparti Esselunga in ordine tipico
    final departments = [
      {'name': 'Frutta e Verdura', 'order_index': 1},
      {'name': 'Salumeria e Formaggi', 'order_index': 2},
      {'name': 'Latticini e Uova', 'order_index': 3},
      {'name': 'Carne', 'order_index': 4},
      {'name': 'Pesce', 'order_index': 5},
      {'name': 'Pane e Panetteria', 'order_index': 6},
      {'name': 'Pasta, Riso e Cereali', 'order_index': 7},
      {'name': 'Conserve e Scatolame', 'order_index': 8},
      {'name': 'Olio, Aceto e Condimenti', 'order_index': 9},
      {'name': 'Biscotti e Dolciumi', 'order_index': 10},
      {'name': 'Detersivi e Pulizia', 'order_index': 11},
      {'name': 'Igiene Personale', 'order_index': 12},
      {'name': 'Prodotti per la Casa', 'order_index': 13},
      {'name': 'Bevande', 'order_index': 14},
      {'name': 'Vini e Alcolici', 'order_index': 15},
      {'name': 'Surgelati', 'order_index': 16},
    ];

    for (final dept in departments) {
      await db.insert('departments', dept);
    }

    // Prodotti di esempio per alcuni reparti
    final products = [
      // Frutta e Verdura (id: 1)
      {'name': 'Mele', 'department_id': 1},
      {'name': 'Banane', 'department_id': 1},
      {'name': 'Pomodori', 'department_id': 1},
      {'name': 'Carote', 'department_id': 1},
      {'name': 'Insalata', 'department_id': 1},
      {'name': 'Limoni', 'department_id': 1},

      // Salumeria e Formaggi (id: 2)
      {'name': 'Prosciutto Crudo', 'department_id': 2},
      {'name': 'Parmigiano', 'department_id': 2},
      {'name': 'Mozzarella', 'department_id': 2},

      // Latticini e Uova (id: 3)
      {'name': 'Latte intero', 'department_id': 3},
      {'name': 'Yogurt greco', 'department_id': 3},
      {'name': 'Uova', 'department_id': 3},
      {'name': 'Burro', 'department_id': 3},

      // Pane e Panetteria (id: 6)
      {'name': 'Pane integrale', 'department_id': 6},
      {'name': 'Focaccia', 'department_id': 6},
      {'name': 'Cornetti', 'department_id': 6},

      // Pasta, Riso e Cereali (id: 7)
      {'name': 'Spaghetti', 'department_id': 7},
      {'name': 'Riso Carnaroli', 'department_id': 7},
      {'name': 'Cereali per colazione', 'department_id': 7},

      // Bevande (id: 14)
      {'name': 'Acqua naturale', 'department_id': 14},
      {'name': 'Succo d\'arancia', 'department_id': 14},
      {'name': 'Caffè', 'department_id': 14},

      // Detersivi e Pulizia (id: 11)
      {'name': 'Detersivo piatti', 'department_id': 11},
      {'name': 'Carta igienica', 'department_id': 11},
    ];

    for (final product in products) {
      await db.insert('products', product);
    }

    // Date per le liste di test
    final now = DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
      18,
      30,
    ); // Oggi alle 18:30
    final weekAgo = today
        .subtract(const Duration(days: 7))
        .add(const Duration(hours: 1)); // 19:30
    final monthAgo = DateTime(
      now.year,
      now.month - 1,
      15,
      20,
      15,
    ); // Mese scorso
    final twoMonthsAgo = DateTime(
      now.year,
      now.month - 2,
      8,
      16,
      45,
    ); // Due mesi fa

    // === LISTA COMPLETATA DI OGGI ===
    await db.insert('shopping_lists', {
      'name': 'Spesa di oggi',
      'created_at': today
          .subtract(const Duration(hours: 2))
          .millisecondsSinceEpoch,
      'completed_at': today.millisecondsSinceEpoch,
      'total_cost': 45.50,
    });

    // Prodotti per la lista di oggi (list_id: 1)
    final todayItems = [
      {'list_id': 1, 'product_id': 1, 'is_checked': 1}, // Mele ✓
      {'list_id': 1, 'product_id': 2, 'is_checked': 1}, // Banane ✓
      {'list_id': 1, 'product_id': 10, 'is_checked': 1}, // Latte ✓
      {'list_id': 1, 'product_id': 11, 'is_checked': 1}, // Yogurt ✓
      {'list_id': 1, 'product_id': 15, 'is_checked': 1}, // Pane ✓
      {
        'list_id': 1,
        'product_id': 18,
        'is_checked': 0,
      }, // Spaghetti ✗ (non preso)
      {'list_id': 1, 'product_id': 21, 'is_checked': 1}, // Acqua ✓
    ];

    for (final item in todayItems) {
      await db.insert('list_items', {
        ...item,
        'added_at': today
            .subtract(const Duration(hours: 2))
            .millisecondsSinceEpoch,
      });
    }

    // === LISTA COMPLETATA SETTIMANA SCORSA ===
    await db.insert('shopping_lists', {
      'name': 'Spesa settimanale',
      'created_at': weekAgo
          .subtract(const Duration(hours: 1))
          .millisecondsSinceEpoch,
      'completed_at': weekAgo.millisecondsSinceEpoch,
      'total_cost': 67.80,
    });

    // Prodotti per la lista di una settimana fa (list_id: 2)
    final weekAgoItems = [
      {'list_id': 2, 'product_id': 3, 'is_checked': 1}, // Pomodori ✓
      {'list_id': 2, 'product_id': 4, 'is_checked': 1}, // Carote ✓
      {'list_id': 2, 'product_id': 7, 'is_checked': 1}, // Prosciutto ✓
      {'list_id': 2, 'product_id': 8, 'is_checked': 1}, // Parmigiano ✓
      {'list_id': 2, 'product_id': 12, 'is_checked': 1}, // Uova ✓
      {'list_id': 2, 'product_id': 17, 'is_checked': 1}, // Cornetti ✓
      {'list_id': 2, 'product_id': 19, 'is_checked': 1}, // Riso ✓
      {'list_id': 2, 'product_id': 22, 'is_checked': 1}, // Succo ✓
      {'list_id': 2, 'product_id': 23, 'is_checked': 0}, // Caffè ✗
      {'list_id': 2, 'product_id': 24, 'is_checked': 1}, // Detersivo ✓
    ];

    for (final item in weekAgoItems) {
      await db.insert('list_items', {
        ...item,
        'added_at': weekAgo
            .subtract(const Duration(hours: 1))
            .millisecondsSinceEpoch,
      });
    }

    // === LISTA COMPLETATA MESE SCORSO ===
    await db.insert('shopping_lists', {
      'name': 'Spesa mensile',
      'created_at': monthAgo
          .subtract(const Duration(hours: 1))
          .millisecondsSinceEpoch,
      'completed_at': monthAgo.millisecondsSinceEpoch,
      'total_cost': null, // Senza prezzo per testare
    });

    // Prodotti per la lista di un mese fa (list_id: 3)
    final monthAgoItems = [
      {'list_id': 3, 'product_id': 1, 'is_checked': 1}, // Mele ✓
      {'list_id': 3, 'product_id': 5, 'is_checked': 1}, // Insalata ✓
      {'list_id': 3, 'product_id': 9, 'is_checked': 1}, // Mozzarella ✓
      {'list_id': 3, 'product_id': 13, 'is_checked': 1}, // Burro ✓
      {'list_id': 3, 'product_id': 16, 'is_checked': 0}, // Focaccia ✗
      {'list_id': 3, 'product_id': 20, 'is_checked': 1}, // Cereali ✓
    ];

    for (final item in monthAgoItems) {
      await db.insert('list_items', {
        ...item,
        'added_at': monthAgo
            .subtract(const Duration(hours: 1))
            .millisecondsSinceEpoch,
      });
    }

    // === LISTA COMPLETATA DUE MESI FA ===
    await db.insert('shopping_lists', {
      'name': 'Spesa grande',
      'created_at': twoMonthsAgo
          .subtract(const Duration(minutes: 30))
          .millisecondsSinceEpoch,
      'completed_at': twoMonthsAgo.millisecondsSinceEpoch,
      'total_cost': 89.25,
    });

    // Prodotti per la lista di due mesi fa (list_id: 4)
    final twoMonthsAgoItems = [
      {'list_id': 4, 'product_id': 2, 'is_checked': 1}, // Banane ✓
      {'list_id': 4, 'product_id': 6, 'is_checked': 1}, // Limoni ✓
      {'list_id': 4, 'product_id': 10, 'is_checked': 1}, // Latte ✓
      {'list_id': 4, 'product_id': 11, 'is_checked': 1}, // Yogurt ✓
      {'list_id': 4, 'product_id': 15, 'is_checked': 1}, // Pane ✓
      {'list_id': 4, 'product_id': 18, 'is_checked': 1}, // Spaghetti ✓
      {'list_id': 4, 'product_id': 21, 'is_checked': 1}, // Acqua ✓
      {'list_id': 4, 'product_id': 25, 'is_checked': 0}, // Carta igienica ✗
    ];

    for (final item in twoMonthsAgoItems) {
      await db.insert('list_items', {
        ...item,
        'added_at': twoMonthsAgo
            .subtract(const Duration(minutes: 30))
            .millisecondsSinceEpoch,
      });
    }

    // === LISTA CORRENTE (VUOTA) ===
    await db.insert('shopping_lists', {
      'name': 'Lista Corrente',
      'created_at': now.millisecondsSinceEpoch,
    });
  }

  // =========== CRUD per Departments ===========
  Future<int> insertDepartment(Department department) async {
    final db = await database;
    return await db.insert('departments', department.toMap());
  }

  Future<List<Department>> getAllDepartments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'departments',
      orderBy: 'order_index ASC',
    );
    return List.generate(maps.length, (i) => Department.fromMap(maps[i]));
  }

  Future<int> updateDepartment(Department department) async {
    final db = await database;
    return await db.update(
      'departments',
      department.toMap(),
      where: 'id = ?',
      whereArgs: [department.id],
    );
  }

  Future<int> deleteDepartment(int id) async {
    final db = await database;

    return await db.transaction((txn) async {
      // 1. Elimina tutti gli item nelle liste che riferiscono ai prodotti di questo reparto
      await txn.rawDelete(
        '''
      DELETE FROM list_items 
      WHERE product_id IN (
        SELECT id FROM products WHERE department_id = ?
      )
    ''',
        [id],
      );

      // 2. Elimina tutti i prodotti del reparto
      await txn.delete('products', where: 'department_id = ?', whereArgs: [id]);

      // 3. Elimina il reparto
      return await txn.delete('departments', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> reorderDepartments(List<Department> departments) async {
    final db = await database;

    await db.transaction((txn) async {
      for (int i = 0; i < departments.length; i++) {
        await txn.update(
          'departments',
          {'order_index': i + 1},
          where: 'id = ?',
          whereArgs: [departments[i].id],
        );
      }
    });
  }

  // =========== CRUD per Products ===========
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProductsByDepartment(int departmentId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'department_id = ?',
      whereArgs: [departmentId],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // =========== CRUD per Shopping Lists ===========
  Future<int> insertShoppingList(ShoppingList list) async {
    final db = await database;
    return await db.insert('shopping_lists', list.toMap());
  }

  Future<ShoppingList?> getCurrentShoppingList() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shopping_lists',
      where: 'completed_at IS NULL',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ShoppingList.fromMap(maps.first);
  }

  Future<int> updateShoppingList(ShoppingList list) async {
    final db = await database;
    return await db.update(
      'shopping_lists',
      list.toMap(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  // =========== CRUD per List Items ===========
  Future<int> insertListItem(ListItem item) async {
    final db = await database;
    return await db.insert('list_items', item.toMap());
  }

  Future<List<DepartmentWithProducts>>
  getCurrentListGroupedByDepartment() async {
    final db = await database;

    // Query con JOIN per ottenere tutti i dati necessari
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        li.id,
        li.list_id,
        li.product_id,
        li.is_checked,
        li.added_at,
        p.name as product_name,
        p.image_path as product_image_path,
        d.id as department_id,
        d.name as department_name,
        d.order_index as department_order,
        d.image_path as department_image_path
      FROM list_items li
      JOIN products p ON li.product_id = p.id
      JOIN departments d ON p.department_id = d.id
      JOIN shopping_lists sl ON li.list_id = sl.id
      WHERE sl.completed_at IS NULL
      ORDER BY d.order_index ASC, p.name ASC
    ''');

    final List<ListItem> items = List.generate(
      maps.length,
      (i) => ListItem.fromMap(maps[i]),
    );

    // Raggruppa per reparto
    final Map<int, DepartmentWithProducts> grouped = {};

    for (final item in items) {
      final deptId = item.departmentId!;

      if (!grouped.containsKey(deptId)) {
        grouped[deptId] = DepartmentWithProducts(
          department: Department(
            id: deptId,
            name: item.departmentName!,
            orderIndex: item.departmentOrder!,
            imagePath: maps.firstWhere(
              (m) => m['department_id'] == deptId,
            )['department_image_path'],
          ),
          items: [],
        );
      }

      grouped[deptId]!.items.add(item);
    }

    return grouped.values.toList()..sort(
      (a, b) => a.department.orderIndex.compareTo(b.department.orderIndex),
    );
  }

  Future<int> updateListItem(ListItem item) async {
    final db = await database;
    return await db.update(
      'list_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<bool> isProductInCurrentList(int productId) async {
    final db = await database;
    final currentList = await getCurrentShoppingList();
    if (currentList == null) return false;

    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM list_items WHERE list_id = ? AND product_id = ?',
        [currentList.id, productId],
      ),
    );
    return (count ?? 0) > 0;
  }

  Future<int> deleteListItem(int id) async {
    final db = await database;
    return await db.delete('list_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCurrentList() async {
    final db = await database;
    final currentList = await getCurrentShoppingList();

    if (currentList == null) {
      throw Exception('Nessuna lista corrente trovata');
    }

    // Elimina tutti gli item della lista corrente
    await db.delete(
      'list_items',
      where: 'list_id = ?',
      whereArgs: [currentList.id],
    );
  }

  Future<bool> addProductToCurrentList(int productId) async {
    final currentList = await getCurrentShoppingList();
    if (currentList == null) {
      throw Exception('Nessuna lista corrente trovata');
    }

    final exists = await isProductInCurrentList(productId);
    if (exists) {
      return false;
    }

    final item = ListItem(
      listId: currentList.id!,
      productId: productId,
      isChecked: false,
      addedAt: DateTime.now(),
    );

    await insertListItem(item);
    return true;
  }

  Future<void> toggleItemChecked(int itemId, bool isChecked) async {
    final db = await database;
    await db.update(
      'list_items',
      {'is_checked': isChecked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<void> completeCurrentList({
    required bool markAllAsChecked,
    double? totalCost,
  }) async {
    final db = await database;
    final currentList = await getCurrentShoppingList();

    if (currentList == null) {
      throw Exception('Nessuna lista corrente trovata');
    }

    await db.transaction((txn) async {
      // 1. Se richiesto, marca tutti gli item come checked
      if (markAllAsChecked) {
        await txn.update(
          'list_items',
          {'is_checked': 1},
          where: 'list_id = ?',
          whereArgs: [currentList.id],
        );
      } else {
        // 2. Se manteniamo lo stato corrente, elimina gli item NON checked
        await txn.delete(
          'list_items',
          where: 'list_id = ? AND is_checked = 0',
          whereArgs: [currentList.id],
        );
      }

      // 3. Completa la lista corrente
      await txn.update(
        'shopping_lists',
        {
          'completed_at': DateTime.now().millisecondsSinceEpoch,
          'total_cost': totalCost,
        },
        where: 'id = ?',
        whereArgs: [currentList.id],
      );

      // 4. Crea una nuova lista corrente vuota
      await txn.insert('shopping_lists', {
        'name': 'Lista Corrente',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  Future<List<ShoppingList>> getCompletedShoppingLists({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shopping_lists',
      where: 'completed_at IS NOT NULL',
      orderBy: 'completed_at DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => ShoppingList.fromMap(maps[i]));
  }

  Future<int> getCompletedShoppingListsCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM shopping_lists WHERE completed_at IS NOT NULL',
      ),
    );
    return count ?? 0;
  }

  Future<bool> hasItemsInCurrentList() async {
    final db = await database;
    final currentList = await getCurrentShoppingList();

    if (currentList == null) return false;

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM list_items WHERE list_id = ?', [
        currentList.id,
      ]),
    );
    return (count ?? 0) > 0;
  }

  Future<Map<String, int>> getCurrentListStats() async {
    final db = await database;
    final currentList = await getCurrentShoppingList();

    if (currentList == null) {
      return {'total': 0, 'checked': 0, 'unchecked': 0};
    }

    final result = await db.rawQuery(
      '''
    SELECT 
      COUNT(*) as total,
      SUM(CASE WHEN is_checked = 1 THEN 1 ELSE 0 END) as checked,
      SUM(CASE WHEN is_checked = 0 THEN 1 ELSE 0 END) as unchecked
    FROM list_items 
    WHERE list_id = ?
  ''',
      [currentList.id],
    );

    final stats = result.first;
    return {
      'total': (stats['total'] as int?) ?? 0,
      'checked': (stats['checked'] as int?) ?? 0,
      'unchecked': (stats['unchecked'] as int?) ?? 0,
    };
  }

  // =========== CRUD per Loyalty Cards ===============
  Future<int> insertLoyaltyCard(LoyaltyCard card) async {
    final db = await database;
    return await db.insert('loyalty_cards', card.toMap());
  }

  Future<List<LoyaltyCard>> getAllLoyaltyCards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'loyalty_cards',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => LoyaltyCard.fromMap(maps[i]));
  }

  Future<LoyaltyCard?> getLoyaltyCard(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'loyalty_cards',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return LoyaltyCard.fromMap(maps.first);
  }

  Future<int> updateLoyaltyCard(LoyaltyCard card) async {
    final db = await database;
    return await db.update(
      'loyalty_cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteLoyaltyCard(int id) async {
    final db = await database;
    return await db.delete('loyalty_cards', where: 'id = ?', whereArgs: [id]);
  }

  // =========== CRUD per Completed Lists ===========
  Future<List<DepartmentWithProducts>> getCompletedListGroupedByDepartment(
    int listId,
  ) async {
    final db = await database;

    // Query con JOIN per ottenere tutti i dati necessari di una lista specifica
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
    SELECT 
      li.id,
      li.list_id,
      li.product_id,
      li.is_checked,
      li.added_at,
      p.name as product_name,
      p.image_path as product_image_path,
      d.id as department_id,
      d.name as department_name,
      d.order_index as department_order,
      d.image_path as department_image_path
    FROM list_items li
    JOIN products p ON li.product_id = p.id
    JOIN departments d ON p.department_id = d.id
    JOIN shopping_lists sl ON li.list_id = sl.id
    WHERE sl.id = ? AND sl.completed_at IS NOT NULL
    ORDER BY d.order_index ASC, p.name ASC
  ''',
      [listId],
    );

    final List<ListItem> items = List.generate(
      maps.length,
      (i) => ListItem.fromMap(maps[i]),
    );

    // Raggruppa per reparto
    final Map<int, DepartmentWithProducts> grouped = {};

    for (final item in items) {
      final deptId = item.departmentId!;

      if (!grouped.containsKey(deptId)) {
        grouped[deptId] = DepartmentWithProducts(
          department: Department(
            id: deptId,
            name: item.departmentName!,
            orderIndex: item.departmentOrder!,
            imagePath: maps.firstWhere(
              (m) => m['department_id'] == deptId,
            )['department_image_path'],
          ),
          items: [],
        );
      }

      grouped[deptId]!.items.add(item);
    }

    return grouped.values.toList()..sort(
      (a, b) => a.department.orderIndex.compareTo(b.department.orderIndex),
    );
  }

  Future<Map<String, int>> getCompletedListStats(int listId) async {
    final db = await database;

    final result = await db.rawQuery(
      '''
    SELECT 
      COUNT(*) as total_products,
      COUNT(DISTINCT p.department_id) as total_departments,
      SUM(CASE WHEN li.is_checked = 1 THEN 1 ELSE 0 END) as checked_products
    FROM list_items li
    JOIN products p ON li.product_id = p.id
    JOIN shopping_lists sl ON li.list_id = sl.id
    WHERE sl.id = ? AND sl.completed_at IS NOT NULL
  ''',
      [listId],
    );

    final stats = result.first;
    return {
      'total_products': (stats['total_products'] as int?) ?? 0,
      'total_departments': (stats['total_departments'] as int?) ?? 0,
      'checked_products': (stats['checked_products'] as int?) ?? 0,
    };
  }

  Future<Map<int, int>> getProductCountsForCompletedLists(
    List<int> listIds,
  ) async {
    if (listIds.isEmpty) return {};

    final db = await database;
    final placeholders = listIds.map((_) => '?').join(',');

    final result = await db.rawQuery('''
    SELECT 
      sl.id as list_id,
      COUNT(li.id) as product_count
    FROM shopping_lists sl
    LEFT JOIN list_items li ON sl.id = li.list_id
    WHERE sl.id IN ($placeholders) AND sl.completed_at IS NOT NULL
    GROUP BY sl.id
  ''', listIds);

    final Map<int, int> counts = {};
    for (final row in result) {
      counts[row['list_id'] as int] = (row['product_count'] as int?) ?? 0;
    }

    return counts;
  }
}

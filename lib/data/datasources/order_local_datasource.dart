import 'package:sqflite/sqflite.dart';
import 'package:flutter_pos/data/models/request/order_request_model.dart';

class OrderLocalDatasource {
  OrderLocalDatasource._init();
  static final OrderLocalDatasource instance = OrderLocalDatasource._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('orders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE offline_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT,
        transaction_time TEXT,
        kasir_id INTEGER,
        total_price INTEGER,
        total_item INTEGER,
        payment_method TEXT,
        customer_name TEXT,
        discount_percentage INTEGER DEFAULT 0,
        is_sync INTEGER DEFAULT 0,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE offline_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        offline_order_id INTEGER,
        product_id INTEGER,
        quantity INTEGER,
        total_price INTEGER,
        FOREIGN KEY (offline_order_id) REFERENCES offline_orders (id)
      )
    ''');
  }

  // Simpan order offline
  Future<int> saveOfflineOrder(OrderRequestModel order, String customerName,
      int discountPercentage) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final orderId = await db.insert('offline_orders', {
      'order_id': 'OFFLINE_${DateTime.now().millisecondsSinceEpoch}',
      'transaction_time': order.transactionTime,
      'kasir_id': order.kasirId,
      'total_price': order.totalPrice,
      'total_item': order.totalItem,
      'payment_method': order.paymentMethod,
      'customer_name': customerName,
      'discount_percentage': discountPercentage,
      'is_sync': 0,
      'created_at': now,
    });

    // Simpan order items
    for (var item in order.orderItems) {
      await db.insert('offline_order_items', {
        'offline_order_id': orderId,
        'product_id': item.productId,
        'quantity': item.quantity,
        'total_price': item.totalPrice,
      });
    }

    return orderId;
  }

  // Ambil semua order offline yang belum sync
  Future<List<Map<String, dynamic>>> getUnsyncedOrders() async {
    final db = await database;
    final orders = await db.query(
      'offline_orders',
      where: 'is_sync = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );

    List<Map<String, dynamic>> result = [];
    for (var order in orders) {
      final items = await db.query(
        'offline_order_items',
        where: 'offline_order_id = ?',
        whereArgs: [order['id']],
      );

      result.add({
        'order': order,
        'items': items,
      });
    }

    return result;
  }

  // Update status sync
  Future<void> updateSyncStatus(int orderId, bool isSynced) async {
    final db = await database;
    await db.update(
      'offline_orders',
      {'is_sync': isSynced ? 1 : 0},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  // Hapus order yang sudah sync
  Future<void> deleteSyncedOrders() async {
    final db = await database;
    await db.delete(
      'offline_orders',
      where: 'is_sync = ?',
      whereArgs: [1],
    );
  }

  // Cek apakah ada order offline
  Future<bool> hasOfflineOrders() async {
    final db = await database;
    final result = await db.query(
      'offline_orders',
      where: 'is_sync = ?',
      whereArgs: [0],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}

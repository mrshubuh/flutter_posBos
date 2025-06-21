import 'package:flutter_pos/data/models/response/product_response_model.dart';
import 'package:flutter_pos/presentation/order/bloc/qris/models/order_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../presentation/home/models/draft_order_item.dart';
import '../../presentation/home/models/order_item.dart';
import '../../presentation/order/bloc/qris/models/draft_order_model.dart';
import '../models/request/order_request_model.dart';
import '../models/response/category_response_model.dart';

class ProductLocalDatasource {
  ProductLocalDatasource._init();

  static final ProductLocalDatasource instance = ProductLocalDatasource._init();

  final String tableProducts = 'products';

  static Database? _database;

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;

    return await openDatabase(
      path,
      version: 2, // Increment version to trigger onUpgrade
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Drop old tables if they exist
          await db.execute('DROP TABLE IF EXISTS $tableProducts');
          await db.execute('DROP TABLE IF EXISTS orders');
          await db.execute('DROP TABLE IF EXISTS categories');
          await db.execute('DROP TABLE IF EXISTS order_items');
          await db.execute('DROP TABLE IF EXISTS draft_orders');
          await db.execute('DROP TABLE IF EXISTS draft_order_items');
          
          // Recreate all tables with new schema
          await _createDB(db, newVersion);
        }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Drop existing tables to avoid conflicts
    await db.execute('DROP TABLE IF EXISTS $tableProducts');
    await db.execute('DROP TABLE IF EXISTS orders');
    await db.execute('DROP TABLE IF EXISTS categories');
    await db.execute('DROP TABLE IF EXISTS order_items');
    await db.execute('DROP TABLE IF EXISTS draft_orders');
    await db.execute('DROP TABLE IF EXISTS draft_order_items');
    await db.execute('''
      CREATE TABLE $tableProducts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        name TEXT,
        description TEXT,
        price INTEGER,
        stock INTEGER,
        category_id INTEGER,
        sku TEXT,
        unit_of_measure TEXT,
        expired_date TEXT,
        image TEXT,
        is_best_seller INTEGER,
        is_ready INTEGER,
        is_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nominal INTEGER,
        payment_method TEXT,
        total_item INTEGER,
        id_kasir INTEGER,
        nama_kasir TEXT,
        transaction_time TEXT,
        is_sync INTEGER DEFAULT 0
      )
    ''');

    //categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NULLABLE,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_order INTEGER,
        id_product INTEGER,
        quantity INTEGER,
        price INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE draft_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_item INTEGER,
        nominal INTEGER,
        transaction_time TEXT,
        table_number INTEGER,
        draft_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE draft_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_draft_order INTEGER,
        id_product INTEGER,
        quantity INTEGER,
        price INTEGER
      )
    ''');
  }

  //insert all categories
  Future<void> insertAllCategories(List<Category> categories) async {
    final db = await instance.database;
    for (var category in categories) {
      await db.insert('categories', category.toMap());
    }
  }

  //delete all categories
  Future<void> removeAllCategories() async {
    final db = await instance.database;
    await db.delete('categories');
  }

  //get all categories
  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');

    return result.map((e) => Category.fromLocal(e)).toList();
  }

  //save order
  Future<int> saveOrder(OrderModel order) async {
    final db = await instance.database;
    int id = await db.insert('orders', order.toMapForLocal());
    for (var orderItem in order.orders) {
      await db.insert('order_items', orderItem.toMapForLocal(id));
    }
    return id;
  }

  //save draft order
  Future<int> saveDraftOrder(DraftOrderModel order) async {
    final db = await instance.database;
    int id = await db.insert('draft_orders', order.toMapForLocal());
    for (var orderItem in order.orders) {
      await db.insert('draft_order_items', orderItem.toMapForLocal(id));
    }
    return id;
  }

  //get all draft order
  Future<List<DraftOrderModel>> getAllDraftOrder() async {
    final db = await instance.database;
    final result = await db.query('draft_orders', orderBy: 'id ASC');

    List<DraftOrderModel> results = await Future.wait(result.map((item) async {
      // Your asynchronous operation here
      final draftOrderItem =
          await getDraftOrderItemByOrderId(item['id'] as int);
      return DraftOrderModel.newFromLocalMap(item, draftOrderItem);
    }));
    return results;
  }

  //get draft order item by id order
  Future<List<DraftOrderItem>> getDraftOrderItemByOrderId(int idOrder) async {
    final db = await instance.database;
    final result =
        await db.query('draft_order_items', where: 'id_draft_order = $idOrder');

    List<DraftOrderItem> results = await Future.wait(result.map((item) async {
      // Your asynchronous operation here
      final product = await getProductById(item['id_product'] as int);
      return DraftOrderItem(
          product: product!, quantity: item['quantity'] as int);
    }));
    return results;
  }

  //remove draft order by id
  Future<void> removeDraftOrderById(int id) async {
    final db = await instance.database;
    await db.delete('draft_orders', where: 'id = ?', whereArgs: [id]);
    await db.delete('draft_order_items',
        where: 'id_draft_order = ?', whereArgs: [id]);
  }

  //get order by isSync = 0
  Future<List<OrderModel>> getOrderByIsSync() async {
    final db = await instance.database;
    final result = await db.query('orders', where: 'is_sync = 0');

    return result.map((e) => OrderModel.fromLocalMap(e)).toList();
  }

  //get order item by id order
  Future<List<OrderItemModel>> getOrderItemByOrderIdLocal(int idOrder) async {
    final db = await instance.database;
    final result = await db.query('order_items', where: 'id_order = $idOrder');

    return result.map((e) => OrderItem.fromMapLocal(e)).toList();
  }

  //update isSync order by id
  Future<int> updateIsSyncOrderById(int id) async {
    final db = await instance.database;
    return await db.update('orders', {'is_sync': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  //get all orders
  Future<List<OrderModel>> getAllOrder() async {
    final db = await instance.database;
    final result = await db.query('orders', orderBy: 'id DESC');

    List<OrderModel> results = await Future.wait(result.map((item) async {
      // Your asynchronous operation here
      final orderItem = await getOrderItemByOrderId(item['id'] as int);
      return OrderModel.newFromLocalMap(item, orderItem);
    }));
    return results;
    // return result.map((e) {
    //   return OrderModel.fromLocalMap(e);
    // }).toList();
  }

  //get order item by id order
  Future<List<OrderItem>> getOrderItemByOrderId(int idOrder) async {
    final db = await instance.database;
    final result = await db
        .query('order_items', where: 'id_order = ?', whereArgs: [idOrder]);

    List<OrderItem> results = await Future.wait(result.map((item) async {
      // Ensure id_product is not null before fetching the product
      final idProduct = item['id_product'] as int?;
      if (idProduct != null) {
        final product = await getProductById(idProduct);
        return OrderItem(product: product!, quantity: item['quantity'] as int);
      } else {
        // Handle the case where id_product is null
        throw Exception('Product ID is null for order item: $item');
      }
    }));

    return results;
  }


  Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      _database = await _initDB('pos14.db'); // Changed db name to force recreation
      return _database!;
    } catch (e) {
      // If there's an error, delete the database and try again
      await deleteDatabase('${await getDatabasesPath()}pos14.db');
      _database = await _initDB('pos14.db');
      return _database!;
    }
  }

  //remove all data product
  Future<void> removeAllProduct() async {
    final db = await instance.database;
    await db.delete(tableProducts);
  }

  //insert data product from list product
  Future<void> insertAllProduct(List<Product> products) async {
    try {
      final db = await instance.database;
      final batch = db.batch();
      
      for (var product in products) {
        final map = product.toLocalMap();
        // Ensure all required fields are present
        map['product_id'] = product.id ?? 0;
        map['is_best_seller'] = product.isBestSeller ? 1 : 0;
        map['is_ready'] = product.isReady ? 1 : 0;
        
        batch.insert(tableProducts, map);
      }
      
      await batch.commit(noResult: true);
    } catch (e) {
      // Handle database schema changes by recreating the table
      await _database?.close();
      _database = null;
      final db = await instance.database;
      final batch = db.batch();
      
      for (var product in products) {
        final map = product.toLocalMap();
        map['product_id'] = product.id ?? 0;
        map['is_best_seller'] = product.isBestSeller ? 1 : 0;
        map['is_ready'] = product.isReady ? 1 : 0;
        
        batch.insert(tableProducts, map);
      }
      
      await batch.commit(noResult: true);
    }
  }

  //insert data product
  Future<Product> insertProduct(Product product) async {
    try {
      final db = await instance.database;
      final map = product.toLocalMap();
      // Ensure all required fields are present
      map['product_id'] = product.id ?? 0;
      map['is_best_seller'] = product.isBestSeller ? 1 : 0;
      map['is_ready'] = product.isReady ? 1 : 0;
      
      final id = await db.insert(tableProducts, map);
      return product.copyWith(id: id);
    } catch (e) {
      // Handle database schema changes by recreating the table
      await _database?.close();
      _database = null;
      final db = await instance.database;
      final map = product.toLocalMap();
      map['product_id'] = product.id ?? 0;
      map['is_best_seller'] = product.isBestSeller ? 1 : 0;
      map['is_ready'] = product.isReady ? 1 : 0;
      
      final id = await db.insert(tableProducts, map);
      return product.copyWith(id: id);
    }
  }

  //get all data product
  Future<List<Product>> getAllProduct() async {
    try {
      final db = await instance.database;
      final result = await db.query(tableProducts);

      return result.map((e) => Product.fromMap(e)).toList();
    } catch (e) {
      // Handle database schema changes by recreating the table
      await _database?.close();
      _database = null;
      final db = await instance.database;
      final result = await db.query(tableProducts);
      return result.map((e) => Product.fromMap(e)).toList();
    }
  }

  //get product by id
  Future<Product?> getProductById(int id) async {
    try {
      final db = await instance.database;
      final result = await db.query(
        tableProducts, 
        where: 'product_id = ?', 
        whereArgs: [id],
      );

      if (result.isEmpty) {
        return null;
      }

      return Product.fromMap(result.first);
    } catch (e) {
      // Handle database schema changes by recreating the table
      await _database?.close();
      _database = null;
      final db = await instance.database;
      final result = await db.query(
        tableProducts, 
        where: 'product_id = ?', 
        whereArgs: [id],
      );
      return result.isEmpty ? null : Product.fromMap(result.first);
    }
  }
}

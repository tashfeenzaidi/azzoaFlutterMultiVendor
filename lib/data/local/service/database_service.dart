import 'package:azzoa_grocery/data/remote/model/product.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static String appDatabaseName = 'app_database.db';
  static Database _database;

  DatabaseService._internal();

  static final DatabaseService _instance = DatabaseService._internal();

  static DatabaseService on() {
    return _instance;
  }

  Future<Database> get getAppDatabase async {
    if (_database != null) {
      return _database;
    }

    _database = await init();

    return _database;
  }

  Future<Database> init() async {
    String rootDatabasePath = await getDatabasesPath();
    String appDatabasePath = join(rootDatabasePath, appDatabaseName);

    var database = await openDatabase(
      appDatabasePath,
      version: 1,
      onCreate: (Database database, int version) async {
        database.execute(
          '''CREATE TABLE product (
              local_id INTEGER PRIMARY KEY AUTOINCREMENT,
              id INTEGER NOT NULL,
              parent_id INTEGER,
              category_id INTEGER,
              shop_id INTEGER,
              title TEXT NOT NULL,
              slug TEXT NOT NULL,
              excerpt TEXT NOT NULL,
              content TEXT NOT NULL,
              image TEXT NOT NULL,
              views INTEGER,
              per INTEGER,
              unit TEXT NOT NULL,
              sale_price REAL,
              general_price REAL,
              tax REAL,
              sku TEXT NOT NULL,
              stock INTEGER,
              delivery_time TEXT,
              delivery_time_type INTEGER,
              is_free_shipping INTEGER,
              created_at TEXT NOT NULL,
              status INTEGER,
              price_off REAL,
              type TEXT,
              star REAL NOT NULL
          )''',
        );
      },
    );

    return database;
  }

  Future insertProduct(Product product) async {
    getAppDatabase.then(
      (database) => database.insert(
        Product.tableName,
        product.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      ),
    );
  }

  Future<List<Product>> getProducts({
    int limit = 100,
  }) async {
    List<Map<String, dynamic>> maps;

    Database database = await getAppDatabase;
    maps = await database.query(
      Product.tableName,
      orderBy: "local_id DESC",
      limit: limit,
      distinct: true,
    );

    return maps.map((value) => Product.fromDatabase(value)).toList();
  }

  Future clearDatabase() async {
    getAppDatabase.then(
      (database) => database.delete(Product.tableName),
    );
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FoodItem {
  String name;
  int calories;

  FoodItem(this.name, this.calories);
}

class MealPlan {
  DateTime date;
  int caloriesPerDay;
  List<FoodItem> foodItems;

  MealPlan(this.date, this.caloriesPerDay, this.foodItems);
}

class DatabaseHelper {
  static late Database _db;

  static Future<void> init() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'meal_plans.db'),
      onCreate: (db, version) {
        _createMealPlansTable(db);
        _createFoodItemsTable(db);
      },
      version: 3,
    );
  }

static Future<List<MealPlan>> getMealPlansForDate(DateTime date) async {
  final List<Map<String, dynamic>> maps = await _db.query(
    'meal_plans',
    where: 'date = ?',
    whereArgs: [date.toIso8601String()],
  );

  List<MealPlan> mealPlans = [];

  for (var map in maps) {
    mealPlans.add(
      MealPlan(
        DateTime.parse(map['date']),
        map['caloriesPerDay'],
        await _getFoodItemsForMealPlan(map['id']),
      ),
    );
  }

  return mealPlans;
}

  static Future<List<FoodItem>> _getFoodItemsForMealPlan(int mealPlanId) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      'food_items',
      where: 'mealPlanId = ?',
      whereArgs: [mealPlanId],
    );

    return List.generate(maps.length, (i) {
      return FoodItem(
        maps[i]['name'],
        maps[i]['calories'],
      );
    });
  }

  static Database get database {
    return _db;
  }

  static void _createMealPlansTable(Database db) {
    db.execute(
      'CREATE TABLE meal_plans(id INTEGER PRIMARY KEY, date TEXT, caloriesPerDay INTEGER)',
    );
  }

  static void _createFoodItemsTable(Database db) {
    db.execute(
      'CREATE TABLE food_items(id INTEGER PRIMARY KEY, mealPlanId INTEGER, name TEXT, calories INTEGER)',
    );
  }

  static Future<void> saveMealPlan(MealPlan mealPlan) async {
    await _db.insert(
      'meal_plans',
      {
        'date': mealPlan.date.toIso8601String(),
        'caloriesPerDay': mealPlan.caloriesPerDay,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    int mealPlanId = await _getLastInsertedId('meal_plans');

    for (FoodItem foodItem in mealPlan.foodItems) {
      await _db.insert(
        'food_items',
        {
          'mealPlanId': mealPlanId,
          'name': foodItem.name,
          'calories': foodItem.calories,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<MealPlan>> getMealPlans() async {
    final List<Map<String, dynamic>> maps = await _db.query('meal_plans');

    return List.generate(maps.length, (i) {
      return MealPlan(
        DateTime.parse(maps[i]['date']),
        maps[i]['caloriesPerDay'],
        [],
      );
    });
  }

  static Future<List<FoodItem>> getFoodItems() async {
    final List<Map<String, dynamic>> maps = await _db.query('food_items');

    return List.generate(maps.length, (i) {
      return FoodItem(
        maps[i]['name'],
        maps[i]['calories'],
      );
    });
  }

  static Future<int> _getLastInsertedId(String tableName) async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery('SELECT last_insert_rowid() as id FROM $tableName');
    return maps.isNotEmpty ? maps.first['id'] : 0;
  }
}
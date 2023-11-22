// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'meal_planner.dart';
import 'saved_meal_plans_screen.dart';
import 'food_database_screen.dart';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase();
  runApp(MyApp());
}

Future<void> initializeDatabase() async {
  await DatabaseHelper.init();

  // Initialize the food items in the database
  List<FoodItem> foods = [
    FoodItem('Apple', 95),
    FoodItem('Banana', 105),
    FoodItem('Orange', 62),
    FoodItem('Chicken Breast', 165),
    FoodItem('Salmon', 206),
    FoodItem('Broccoli', 31),
    FoodItem('Quinoa', 120),
    FoodItem('Brown Rice', 215),
    FoodItem('Avocado', 234),
    FoodItem('Eggs', 68),
    FoodItem('Greek Yogurt', 100),
    FoodItem('Almonds', 7),
    FoodItem('Spinach', 7),
    FoodItem('Sweet Potato', 180),
    FoodItem('Oatmeal', 150),
    FoodItem('Cottage Cheese', 206),
    FoodItem('Whole Wheat Bread', 69),
    FoodItem('Tomato', 22),
    FoodItem('Carrot', 41),
    FoodItem('Blueberries', 85),
  ];

  for (FoodItem foodItem in foods) {
    await DatabaseHelper.database.insert(
      'food_items',
      {
        'name': foodItem.name,
        'calories': foodItem.calories,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Menu'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MealPlanner()),
                );
              },
              child: Text('Create a Meal Plan'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedMealPlansScreen()),
                );
              },
              child: Text('Saved Meal Plans'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodDatabaseScreen()),
                );
              },
              child: Text('Food Database'),
            ),
          ],
        ),
      ),
    );
  }
}

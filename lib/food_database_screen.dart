// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'edit_food_item_screen.dart';

class FoodDatabaseScreen extends StatefulWidget {
  @override
  _FoodDatabaseScreenState createState() => _FoodDatabaseScreenState();
}

class _FoodDatabaseScreenState extends State<FoodDatabaseScreen> {
  List<FoodItem> foodItems = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch food items whenever the screen is accessed
    fetchFoodItems();
  }

  Future<void> fetchFoodItems() async {
    List<FoodItem> foods = await DatabaseHelper.getFoodItems();
    setState(() {
      foodItems = foods;
    });
  }

  Future<void> deleteAllFoodItems() async {
    await DatabaseHelper.init();
    await DatabaseHelper.database.delete('food_items');
    setState(() {
      foodItems.clear();
    });
    // You may add a snackbar or other UI feedback to confirm the deletion
  }

  Future<void> deleteFoodItem(FoodItem foodItem) async {
    await DatabaseHelper.database
        .delete('food_items', where: 'name = ?', whereArgs: [foodItem.name]);
    fetchFoodItems();
  }

  Future<void> addFoodItem() async {
    String name = _nameController.text;
    String calories = _caloriesController.text;

    if (name.isNotEmpty && calories.isNotEmpty) {
      int calorieCount = int.tryParse(calories) ?? 0;

      await DatabaseHelper.database.insert(
        'food_items',
        {'name': name, 'calories': calorieCount},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      _nameController.clear();
      _caloriesController.clear();
      fetchFoodItems();
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Database'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              deleteAllFoodItems();
            },
            child: Text('Delete All Food Items'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Food Name',
                    // Clearing the labelText when the user starts editing
                    floatingLabelBehavior: _nameController.text.isEmpty
                        ? FloatingLabelBehavior.auto
                        : FloatingLabelBehavior.never,
                  ),
                ),
                TextField(
                  controller: _caloriesController,
                  decoration: InputDecoration(
                    labelText: 'Calories',
                    // Clearing the labelText when the user starts editing
                    floatingLabelBehavior: _caloriesController.text.isEmpty
                        ? FloatingLabelBehavior.auto
                        : FloatingLabelBehavior.never,
                  ),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: () {
                    addFoodItem();
                  },
                  child: Text('Add Food Item'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                FoodItem foodItem = foodItems[index];
                return Dismissible(
                  key: UniqueKey(),
                  // Swap background and secondaryBackground
                  background: Container(
                    color: Colors.orange,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 16.0),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Confirm delete
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm Delete'),
                            content:
                                Text('Are you sure you want to delete ${foodItem.name}?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Editing food item
                      _nameController.text = foodItem.name;
                      _caloriesController.text = foodItem.calories.toString();
                      // Navigate to EditFoodItemScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditFoodItemScreen(
                            foodItem: foodItem,
                            onEditComplete: () {
                              // Fetch food items after editing
                              fetchFoodItems();
                              // Clear the 'Food Name' and 'Calories' labels after editing
                              _nameController.clear();
                              _caloriesController.clear();
                            },
                          ),
                        ),
                      );
                      // Return false to cancel dismiss
                      return false;
                    }
                  },
                  onDismissed: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Delete
                      await deleteFoodItem(foodItem);
                    }
                  },
                  child: ListTile(
                    title: Text('${foodItem.name} - ${foodItem.calories} calories'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
// edit_food_item_screen.dart
// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors_in_immutables, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'database_helper.dart';

class EditFoodItemScreen extends StatefulWidget {
  final FoodItem foodItem;
  final VoidCallback onEditComplete; // Define the callback

  EditFoodItemScreen({required this.foodItem, required this.onEditComplete});

  @override
  _EditFoodItemScreenState createState() => _EditFoodItemScreenState();
}

class _EditFoodItemScreenState extends State<EditFoodItemScreen> {
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.foodItem.name);
    _caloriesController = TextEditingController(text: widget.foodItem.calories.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Food Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Food Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _caloriesController,
              decoration: InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Save changes
                await saveChanges();
                // callback when editing is complete
                widget.onEditComplete();
                // Pop the screen
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveChanges() async {
    String newName = _nameController.text;
    String newCalories = _caloriesController.text;

    if (newName.isNotEmpty && newCalories.isNotEmpty) {
      int newCalorieCount = int.tryParse(newCalories) ?? 0;

      await DatabaseHelper.database.update(
        'food_items',
        {'name': newName, 'calories': newCalorieCount},
        where: 'name = ?',
        whereArgs: [widget.foodItem.name],
      );

      // Update the food item with the new values
      widget.foodItem.name = newName;
      widget.foodItem.calories = newCalorieCount;
    }
  }
}

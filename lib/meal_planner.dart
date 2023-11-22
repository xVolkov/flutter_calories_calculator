// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, curly_braces_in_flow_control_structures, deprecated_member_use, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'database_helper.dart';

class MealPlanner extends StatefulWidget {
  @override
  _MealPlannerState createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  TextEditingController caloriesController = TextEditingController();
  DateTime? selectedDate;
  List<FoodItem> selectedFoodItems = [];
  List<FoodItem> allFoodItems = [];
  int caloriesPerDay = 0;

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  Future<void> fetchFoodItems() async {
    List<FoodItem> foods = await DatabaseHelper.getFoodItems();
    setState(() {
      allFoodItems = foods;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Meal Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Date:'),
            ListTile(
              title: ElevatedButton(
                onPressed: () async {
                  await saveMealPlan();
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate)
                    setState(() {
                      selectedDate = DateTime(picked.year, picked.month, picked.day);
                    });
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
                child: Text(
                  'Select Date: ${selectedDate?.toLocal().toString().split(' ')[0] ?? "Not Selected"}',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text('Enter Calories Per Day:'),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  caloriesPerDay = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 16),
            Text('Select Food Items:'),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allFoodItems.length,
                itemBuilder: (context, index) {
                  FoodItem foodItem = allFoodItems[index];
                  bool isFoodEnabled = selectedDate != null &&
                      caloriesPerDay > 0 &&
                      (calculateTotalCalories() + foodItem.calories <= caloriesPerDay ||
                          selectedFoodItems.contains(foodItem));

                  return CheckboxListTile(
                    title: Text('${foodItem.name} (${foodItem.calories} calories)'),
                    value: selectedFoodItems.contains(foodItem),
                    onChanged: isFoodEnabled
                        ? (bool? value) {
                      if (value != null) {
                        setState(() {
                          if (value) {
                            selectedFoodItems.add(foodItem);
                          } else {
                            selectedFoodItems.remove(foodItem);
                          }
                        });
                      }
                    }
                        : null,
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text('Total Calories: ${calculateTotalCalories()}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await saveMealPlan();
              },
              child: Text('Save Meal Plan'),
            ),
          ],
        ),
      ),
    );
  }

  int calculateTotalCalories() {
    return selectedFoodItems.fold(0, (sum, foodItem) => sum + foodItem.calories);
  }

  Future<void> saveMealPlan() async {
    if (selectedDate == null) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a date'),
        ),
      );

      return; // Return early if date is not selected
    }

    if (caloriesPerDay <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please specify calories per day'),
        ),
      );

      return; // Return early if caloriesPerDay is not valid
    }

    if (calculateTotalCalories() > caloriesPerDay) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total calories exceed the set limit'),
        ),
      );
      return;
    }

    if (selectedFoodItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one food item'),
        ),
      );
      return;
    }

    MealPlan mealPlan = MealPlan(selectedDate!, caloriesPerDay, selectedFoodItems);

    await DatabaseHelper.init();
    await DatabaseHelper.saveMealPlan(mealPlan);

    caloriesController.clear();
    selectedDate = null;
    selectedFoodItems.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meal Plan Saved'),
      ),
    );
    
    Navigator.pop(context); // Navigate back to the main menu
  }
}
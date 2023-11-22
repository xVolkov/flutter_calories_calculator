// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'database_helper.dart';

class SavedMealPlansScreen extends StatefulWidget {
  @override
  _SavedMealPlansScreenState createState() => _SavedMealPlansScreenState();
}

class _SavedMealPlansScreenState extends State<SavedMealPlansScreen> {
  DateTime? selectedDate; // Default to no date selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Meal Plans'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteAllMealPlans(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDatePicker(),
          Expanded(
            child: FutureBuilder<List<MealPlan>>(
              future: DatabaseHelper.getMealPlansForDate(selectedDate ?? DateTime.now()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No saved meal plans for the selected date.');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      MealPlan mealPlan = snapshot.data![index];
                      return ListTile(
                        title: Text('Date: ${mealPlan.date.toLocal().toString().split(' ')[0]}'),
                        subtitle:
                            Text('Calories Per Day: ${mealPlan.caloriesPerDay}'),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      title: ElevatedButton(
        onPressed: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null && pickedDate != selectedDate) {
            setState(() {
              selectedDate = pickedDate;
            });
          }
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
        ),
        child: Text(
          selectedDate != null
              ? 'Selected Date: ${selectedDate!.toLocal().toString().split(' ')[0]}'
              : 'Selected Date: Not Selected',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _deleteAllMealPlans(BuildContext context) async {
    await DatabaseHelper.init();
    await DatabaseHelper.database.delete('meal_plans');

    setState(() {}); // Refresh the list by triggering a rebuild

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All Meal Plans Deleted'),
      ),
    );
  }
}

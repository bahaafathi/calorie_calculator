import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CalorieHistoryPage extends StatefulWidget {
  const CalorieHistoryPage({super.key});

  @override
  _CalorieHistoryPageState createState() => _CalorieHistoryPageState();
}

class _CalorieHistoryPageState extends State<CalorieHistoryPage> {
  List<double> caloriesList = [];

  @override
  void initState() {
    super.initState();
    loadCaloriesFromDatabase();
  }

  Future<void> loadCaloriesFromDatabase() async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'calorie_database.db'),
    );

    final List<Map<String, dynamic>> maps = await database.query('calories');

    setState(() {
      caloriesList = List.generate(maps.length, (i) {
        return maps[i]['value'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie History'),
      ),
      body: ListView.builder(
        itemCount: caloriesList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Day ${index + 1}: ${caloriesList[index]} calories'),
          );
        },
      ),
    );
  }
}

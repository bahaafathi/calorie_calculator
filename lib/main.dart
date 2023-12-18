import 'package:calorie_calculator/CalorieHistoryPage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double weight = 0.0;
  double height = 0.0;
  double age = 0.0;
  double result = 0.0;
  String selectedGender = 'Male';
  String selectedActivityLevel = 'Sedentary';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalorieHistoryPage(),
                ));
          },
          icon: Icon(Icons.history),
        ),
        title: Text('Calorie Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String?>(
              value: selectedGender,
              onChanged: (String? value) {
                setState(() {
                  selectedGender = value!;
                });
              },
              items: ['Male', 'Female']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: const Text('Select Gender'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              keyboardType: TextInputType.number,
              onChanged: (value) => weight = double.parse(value),
              decoration: InputDecoration(labelText: 'Weight (kg)'),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              onChanged: (value) => height = double.parse(value),
              decoration: InputDecoration(labelText: 'Height (cm)'),
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              onChanged: (value) => age = double.parse(value),
              decoration: InputDecoration(labelText: 'Age (years)'),
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: selectedActivityLevel,
              onChanged: (String? value) {
                setState(() {
                  selectedActivityLevel = value!;
                });
              },
              items: [
                'Sedentary',
                'Lightly active',
                'Moderately active',
                'Very active',
                'Extremely active'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: Text('Select Activity Level'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                calculateCalories();
              },
              child: Text('Calculate'),
            ),
            SizedBox(height: 16.0),
            Text('Estimated Daily Calories: $result'),
          ],
        ),
      ),
    );
  }

  void calculateCalories() {
    double bmr;
    if (selectedGender == 'Male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    double? pal;
    switch (selectedActivityLevel) {
      case 'Sedentary':
        pal = 1.2;
        break;
      case 'Lightly active':
        pal = 1.375;
        break;
      case 'Moderately active':
        pal = 1.55;
        break;
      case 'Very active':
        pal = 1.725;
        break;
      case 'Extremely active':
        pal = 1.9;
        break;
    }

    setState(() {
      result = bmr * pal!;
      saveCaloriesToDatabase(result);
    });
  }

  Future<void> saveCaloriesToDatabase(double calories) async {
    final database = await openDatabase(
      join(await getDatabasesPath(), 'calorie_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE calories(id INTEGER PRIMARY KEY AUTOINCREMENT, value REAL)',
        );
      },
      version: 1,
    );

    await database.insert(
      'calories',
      {'value': calories},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

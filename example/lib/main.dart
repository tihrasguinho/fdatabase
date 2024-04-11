import 'package:fdatabase/fdatabase.dart';
import 'package:flutter/material.dart';

late FDatabase db;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  db = await FDatabase.getInstance()
    ..register<Person>(Person.new);
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Person: ${db.get<Person>('person')?.toMap()}'),
              Text('Name: ${db.get<String>('name')}'),
              Text('Age: ${db.get<int>('age')}'),
              Text('Weight: ${db.get<double>('weight')}'),
              Text('Married: ${db.get<bool>('married')}'),
              Text('Birthday: ${db.get<DateTime>('birthday')}'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final person = Person(
              id: 1,
              name: 'John',
              age: 30,
              weight: 75.5,
              married: true,
              birthday: DateTime(2000, 1, 1),
            );

            db.put<Person>('person', person);
            db.put<String>('name', 'John');
            db.put<int>('age', 30);
            db.put<double>('weight', 75.5);
            db.put<bool>('married', true);
            db.put<DateTime>('birthday', DateTime(2000, 1, 1));

            // Or using batch for save all at once

            db.batch(
              (put) {
                put<Person>('person', person);
                put<String>('name', 'John');
                put<int>('age', 30);
                put<double>('weight', 75.5);
                put<bool>('married', true);
                put<DateTime>('birthday', DateTime(2000, 1, 1));
              },
            );

            setState(() {});
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class Person extends Entity {
  final int id;
  final String name;
  final int age;
  final double weight;
  final bool married;
  final DateTime birthday;

  const Person({
    required this.id,
    required this.name,
    required this.age,
    required this.weight,
    required this.married,
    required this.birthday,
  });

  @override
  Map<Symbol, dynamic> get properties => {
        #id: id,
        #name: name,
        #age: age,
        #weight: weight,
        #married: married,
        #birthday: birthday,
      };
}

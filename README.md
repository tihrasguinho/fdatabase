##### fdatabase / Flutter Database

A new flutter package to save and load (Synchronously) data from local database

## Getting Started

```bash
flutter pub add fdatabase
```

or add it to your `pubspec.yaml`: 

```yaml
dependencies:
    fdatabase: <any>
```

## Usage

```dart
import 'package:fdatabase/fdatabase.dart';

void main() async {
    final db = await FDatabase.getInstance();

    db.register<Person>(Person.new);

    final person = Person(
        id: 1,
        name: 'John',
        age: 30,
        weight: 75.5,
        married: true,
    );

    // to save values use `put` method

    db.put<Person>('person', person);

    db.put<String>('string', 'string');
    db.put<int>('int', 1);
    db.put<double>('double', 1.0);
    db.put<bool>('bool', true);
    db.put<DateTime>('dateTime', DateTime(2024, 4, 9));

    // or with `batch` method to save multiple values at once

    db.batch((put) {
        put<Person>('person', person);
        put<String>('string', 'string');
        put<int>('int', 1);
        put<double>('double', 1.0);
        put<bool>('bool', true);
        put<DateTime>('dateTime', DateTime(2024, 4, 9));
    });

    // to get values from database use `get` method

    db.get<Person>('person'); // Person Instance

    db.get<String>('string'); // 'string'
    db.get<int>('int'); // 1
    db.get<double>('double'); // 1.0
    db.get<bool>('bool'); // true
    db.get<DateTime>('dateTime'); // DateTime(2024, 4, 9)
}
```

## Supported Data Types

* String
* int
* double
* bool
* DateTime
* Entity (Classes that extends Entity)

All supported types also support saving as list.

## Under Development

Feel free to contribute to the project if you have any idea.
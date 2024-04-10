import 'package:checks/checks.dart';
import 'package:fdatabase/fdatabase.dart';
import 'package:flutter_test/flutter_test.dart';

class StorageMock implements Storage {
  final Map<String, dynamic> _values = {};

  @override
  void clear() => _values.clear();

  @override
  bool exists(String key) => _values.containsKey(key);

  @override
  Map<String, dynamic>? get(String key) => _values[key];

  @override
  String? get path => '';

  @override
  void put(String key, Map<String, dynamic> value) => _values[key] = value;

  @override
  void putMany(Map<String, Map<String, dynamic>> values) {
    _values.addAll(values);
  }

  @override
  void remove(String key) => _values.remove(key);
}

void main() {
  late FDatabase fDb;
  setUp(() {
    fDb = FDatabase.fromStorage(StorageMock());
  });

  test('Saving default types (String, int, double, bool, DateTime)', () {
    fDb.put<String>('string', 'string');
    fDb.put<int>('int', 1);
    fDb.put<double>('double', 1.0);
    fDb.put<bool>('bool', true);
    fDb.put<DateTime>('dateTime', DateTime(2024, 4, 9));

    check(fDb.get<String>('string')).isA<String>().equals('string');
    check(fDb.get<int>('int')).isA<int>().equals(1);
    check(fDb.get<double>('double')).isA<double>().equals(1.0);
    check(fDb.get<bool>('bool')).isA<bool>().equals(true);
    check(fDb.get<DateTime>('dateTime')).isA<DateTime>().equals(DateTime(2024, 4, 9));
  });

  test('Saving default list types (String, int, double, bool, DateTime)', () {
    fDb.put<List<String>>('stringList', ['string']);
    fDb.put<List<int>>('intList', [1]);
    fDb.put<List<double>>('doubleList', [1.0]);
    fDb.put<List<bool>>('boolList', [true]);
    fDb.put<List<DateTime>>('dateTimeList', [DateTime(2024, 4, 9)]);

    check(fDb.get<List<String>>('stringList')).isA<List<String>>();
    check(fDb.get<List<int>>('intList')).isA<List<int>>();
    check(fDb.get<List<double>>('doubleList')).isA<List<double>>();
    check(fDb.get<List<bool>>('boolList')).isA<List<bool>>();
    check(fDb.get<List<DateTime>>('dateTimeList')).isA<List<DateTime>>();
  });

  test('Saving custom types `Entity`', () {
    final user = UserEntity(
      id: 'id',
      name: 'name',
      age: 1,
      weight: 1.0,
      married: true,
      birthday: DateTime(2024, 4, 9),
    );

    fDb.register<UserEntity>(UserEntity.new);

    fDb.put<UserEntity>('user', user);

    check(fDb.get<UserEntity>('user')).isA<UserEntity>().equals(user);
  });

  test('Saving list of custom types `Entity`', () {
    fDb.register<UserEntity>(UserEntity.new);

    final user1 = UserEntity(
      id: 'id',
      name: 'name',
      age: 1,
      weight: 1.0,
      married: true,
      birthday: DateTime(2024, 4, 9),
    );

    final user2 = UserEntity(
      id: 'id2',
      name: 'name2',
      age: 2,
      weight: 2.0,
      married: false,
      birthday: DateTime(2024, 4, 9),
    );

    fDb.put<List<UserEntity>>('users', [user1, user2]);

    check(fDb.get<List<UserEntity>>('users')).isA<List<UserEntity>>();
  });

  test('Throwing `NotSupportedException` when type is not `Entity` or a default type', () {
    check(() => fDb.put<Something>('something', const Something())).throws<NotSupportedException>();
  });
}

class UserEntity extends Entity {
  final String id;
  final String name;
  final int age;
  final double weight;
  final bool married;
  final DateTime birthday;

  UserEntity({
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

class Something {
  const Something();
}

import 'entity.dart';

abstract interface class FDatabaseBase {
  /// Register a new [Entity] class to be used in storage.
  ///
  /// E.g:
  /// ```dart
  /// class User extends Entity {
  ///   String name;
  ///   DateTime date;
  ///
  ///   User({required this.name, required this.date});
  ///
  ///   @override
  ///   Set get props => {name, date};
  /// }
  ///
  /// storage.register<User>(User.new);
  /// ```
  void register<T extends Entity>(Function constructor);

  /// Set a [Entity] or a default [T] in the storage.
  ///
  /// E.g:
  /// ```dart
  /// final user = User(name: 'John', date: DateTime.parse('2024-01-01'));
  ///
  /// storage.put<User>('user', user);
  /// ```
  /// or
  /// ```dart
  /// storage.put<String>('string', 'Hello World');
  ///
  /// storage.put<int>('int', 1);
  ///
  /// storage.put<double>('double', 1.0);
  ///
  /// storage.put<bool>('bool', true);
  /// ```
  void put<T>(String key, T value);

  /// Batch set a [Entity] or a default [T] in the storage.
  ///
  /// E.g:
  /// ```dart
  /// final user = User(name: 'John', date: DateTime.parse('2024-01-01'));
  ///
  /// storage.batch((put) {
  ///   put<User>('user', user);
  ///
  ///   put<String>('string', 'Hello World');
  ///
  ///   put<int>('int', 1);
  ///
  ///   put<double>('double', 1.0);
  ///
  ///   put<bool>('bool', true);
  /// });
  /// ```
  void batch(void Function(void Function<T>(String key, T value) put) func);

  /// Get a [Entity] or a default [T] from the storage.
  ///
  /// E.g:
  /// ```dart
  /// storage.get<User>('user'); // User(name: 'John', date: ...(2024-01-01))
  /// ```
  /// or
  /// ```dart
  /// storage.get<String>('string'); // 'Hello World'
  ///
  /// storage.get<int>('int'); // 1
  ///
  /// storage.get<double>('double'); // 1.0
  ///
  /// storage.get<bool>('bool'); // true
  /// ```
  T? get<T>(String key);

  /// Check if a key exists in the storage.
  bool containsKey(String key);

  /// Delete a key from the storage.
  void delete(String key);

  /// Delete all keys from the storage.
  void clear();
}

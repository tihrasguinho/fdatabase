abstract interface class Storage {
  /// The path of the storage file [Null] if it is running on [Web].
  final String? path;

  const Storage([this.path]);

  /// Saves a [value] at [key] in the storage.
  void put(String key, Map<String, dynamic> value);

  /// Saves various [values] in the storage at once.
  void putMany(Map<String, Map<String, dynamic>> values);

  /// Retrieves the value at [key] from the storage if it exists, otherwise [Null].
  Map<String, dynamic>? get(String key);

  /// Removes the value at [key] from the storage.
  void remove(String key);

  /// Removes all values from the storage.
  void clear();

  /// Checks if a value at [key] exists in the storage.
  bool exists(String key);
}

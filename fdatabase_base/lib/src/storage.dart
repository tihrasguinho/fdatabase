abstract interface class Storage {
  final String? path;

  const Storage([this.path]);

  void put(String key, Map<String, dynamic> value);

  Map<String, dynamic>? get(String key);

  void remove(String key);

  void clear();

  bool exists(String key);
}

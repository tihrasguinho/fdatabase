abstract interface class Storage {
  final String? path;

  const Storage([this.path]);

  void put(String key, dynamic value);

  dynamic get(String key);

  void remove(String key);

  void clear();

  bool exists(String key);

  // void save(Map<String, dynamic> value);
  // void remove();
  // Map<String, dynamic> load();
}

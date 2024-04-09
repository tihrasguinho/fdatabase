abstract interface class Storage {
  final String? path;

  const Storage([this.path]);

  void save(Map<String, dynamic> value);
  void remove();
  Map<String, dynamic> load();
}

import 'dart:convert';

abstract class Entity {
  Map<Symbol, dynamic> get properties;

  const Entity();

  @override
  int get hashCode => Object.hashAll(properties.values);

  @override
  bool operator ==(Object other) {
    if (other is Entity) {
      return properties.keys.every((key) => properties[key] == other.properties[key]);
    } else {
      return false;
    }
  }

  @override
  String toString() {
    return '$runtimeType(${properties.keys.map((key) => '${RegExp(r'^Symbol\(\"(.+)\"\)$').firstMatch(key.toString())?.group(1)}: ${properties[key]}').join(', ')})';
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    for (final key in properties.keys) {
      map[RegExp(r'^Symbol\(\"(.+)\"\)$').firstMatch(key.toString())!.group(1)!] = _propertyNormalizer(properties[key]);
    }
    return map;
  }

  String toJson() => const JsonEncoder.withIndent('  ').convert(toMap());
}

dynamic _propertyNormalizer(dynamic property) {
  if (property is Entity) {
    return property.toMap();
  }

  return switch (property.runtimeType) {
    const (int) => property,
    const (double) => property,
    const (String) => property,
    const (bool) => property,
    const (DateTime) => property.millisecondsSinceEpoch,
    _ => property.toString(),
  };
}

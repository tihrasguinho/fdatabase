library fdatabase;

export 'package:fdatabase_base/fdatabase_base.dart' show Entity, Storage, FDatabaseBase, FDatabaseException, NotRegisteredException, NotSupportedException, InvalidException, NestedListException;

import 'package:fdatabase_base/fdatabase_base.dart';

import 'src/storage.dart';

bool _isTypeOf<T, S>() => <T>[] is List<S>;
bool get _isWeb => const bool.fromEnvironment('dart.library.js_util');

class FDatabase implements FDatabaseBase {
  final Storage _storage;
  final Map<Type, Class> _classes;

  FDatabase._(this._storage, this._classes);

  FDatabase.fromStorage(Storage storage) : this._(storage, <Type, Class>{});

  static Future<FDatabase> getInstance() async {
    return FDatabase.fromStorage(await getStorage());
  }

  @override
  T? get<T>(String key) {
    if (_isTypeOf<T, Entity>()) {
      if (!_classes.containsKey(T)) {
        throw NotRegisteredException('Class ${T.toString()} not registered!');
      }

      final cls = _classes[T]!;

      final parameters = cls.parameters;

      final source = _storage.get(key);

      if (source == null) return null;

      final sourceParameters = Map<String, dynamic>.from(source['parameters']);

      if (sourceParameters.length != parameters.length) return null;

      _extractValues(parameters, sourceParameters);

      return cls.invoke(parameters) as T;
    } else if (_isTypeOf<T, List<Entity>>()) {
      final (type: type, rounds: _) = _typeListFromString(T.toString());

      if (!_classes.keys.any((key) => key.toString() == type)) {
        throw NotRegisteredException('Class $type not registered!');
      }

      final cls = _classes.entries.firstWhere((entry) => entry.key.toString() == type).value;

      final parameters = cls.parameters;

      final source = _storage.get(key);

      if (source == null) return null;

      final sourceList = source['list'];

      if (sourceList == null) throw const InvalidException('This is not a list!');

      final sourceValues = source['value'];

      if (sourceValues == null) throw const InvalidException('This is not a list!');

      final valueList = (sourceValues as List).cast<Map<String, dynamic>>();

      final listOfParameters = valueList.map((value) {
        final classParameters = List<Parameter>.from(parameters);
        final valueParameters = Map<String, dynamic>.from(value['parameters']);

        _extractValues(classParameters, valueParameters);
        return classParameters;
      }).toList();

      return cls.invokeList(listOfParameters) as T;
    } else {
      final source = _storage.get(key);

      if (source == null) return null;

      if (source['list'] != null) {
        final listMap = Map<String, dynamic>.from(source['list']);

        final list = switch (listMap['type']) {
          'String' when listMap['nullable'] == false => (source['value'] as List).cast<String>(),
          'String' when listMap['nullable'] == true => (source['value'] as List).cast<String?>(),
          'int' when listMap['nullable'] == false => (source['value'] as List).cast<int>(),
          'int' when listMap['nullable'] == true => (source['value'] as List).cast<int?>(),
          'double' when listMap['nullable'] == false => (source['value'] as List).cast<double>(),
          'double' when listMap['nullable'] == true => (source['value'] as List).cast<double?>(),
          'bool' when listMap['nullable'] == false => (source['value'] as List).cast<bool>(),
          'bool' when listMap['nullable'] == true => (source['value'] as List).cast<bool?>(),
          'DateTime' when listMap['nullable'] == false => (source['value'] as List).map((e) => DateTime.fromMillisecondsSinceEpoch(e)).toList(),
          'DateTime' when listMap['nullable'] == true => (source['value'] as List).map((e) => e != null ? DateTime.fromMillisecondsSinceEpoch(e) : null).toList(),
          _ => throw NotSupportedException('Unsuported type of list ${source['type']}!'),
        };

        return list as T;
      } else {
        switch (source['type']) {
          case 'String':
            {
              if (source['nullable'] == false) {
                return source['value'] as T;
              } else {
                return source['value'] as T;
              }
            }
        }

        final value = switch (source['type']) {
          'String' when source['nullable'] == false => source['value'] as String,
          'String' when source['nullable'] == true => source['value'] as String?,
          'int' when source['nullable'] == false => source['value'] as int,
          'int' when source['nullable'] == true => source['value'] as int?,
          'double' when source['nullable'] == false => source['value'] as double,
          'double' when source['nullable'] == true => source['value'] as double?,
          'bool' when source['nullable'] == false => source['value'] as bool,
          'bool' when source['nullable'] == true => source['value'] as bool?,
          'DateTime' when source['nullable'] == false => DateTime.fromMillisecondsSinceEpoch(source['value'] as int),
          'DateTime' when source['nullable'] == true => source['value'] != null ? DateTime.fromMillisecondsSinceEpoch(source['value'] as int) : null,
          _ => throw NotSupportedException('Unsupported type ${source['type']}!'),
        };

        return value as T;
      }
    }
  }

  @override
  void put<T>(String key, T value) => _storage.put(key, _put<T>(key, value));

  @override
  void batch(void Function(void Function<T>(String key, T value) put) func) {
    final temp = <String, dynamic>{};
    func(<T>(String key, T value) => temp[key] = _put<T>(key, value));
    for (var key in temp.keys) {
      _storage.put(key, temp[key]);
    }
  }

  @override
  void register<T extends Entity>(Function constructor) {
    if (['dynamic', 'Object', 'Object?'].contains(T.toString())) throw InvalidException('Invalid type $T!');

    final constructorString = constructor.runtimeType.toString();

    final splited = constructorString.split(' => ');

    final typeString = splited.last.trim();

    if (typeString != T.toString()) throw const InvalidException('Invalid constructor type');

    final stringParams = splited.first.replaceAll(RegExp(r'(\(|\[|\]|\))'), '').trim();

    final positionalParameters = List<PositionalParameter>.from(
      stringParams.replaceAll(RegExp(r'{(.+)}'), '').split(', ').where((item) => item.isNotEmpty).map(
        (item) {
          return PositionalParameter(
            type: item.trim().replaceAll('?', ''),
            nullable: item.trim().endsWith('?'),
          );
        },
      ),
    );

    final namedParameters = List<NamedParameter>.from(
      RegExp(r'{(.+)}').firstMatch(stringParams)?.group(1)?.split(', ').map(
            (item) {
              final regex = RegExp(r'(required )?([\<\w\?\>]+)\s([\w]+)');

              return NamedParameter(
                type: regex.firstMatch(item)?.group(2)?.replaceAll('?', '') ?? '',
                nullable: regex.firstMatch(item)?.group(2)?.endsWith('?') ?? false,
                named: Symbol(regex.firstMatch(item)?.group(3) ?? ''),
              );
            },
          ) ??
          [],
    );

    final params = List<Parameter>.from(
      [
        ...positionalParameters,
        ...namedParameters,
      ],
    );

    _classes[T] = Class<T>(type: T, constructor: constructor, parameters: params);
  }

  @override
  void clear() => _storage.clear();

  @override
  bool containsKey(String key) => _storage.exists(key);

  @override
  void delete(String key) => _storage.remove(key);

  Map<String, dynamic> _put<T>(String key, T value) {
    if (_isTypeOf<T, Entity>()) {
      final entity = value as Entity;

      if (!_classes.containsKey(T)) {
        throw NotRegisteredException('Class ${T.toString()} not registered!');
      }

      final cls = _classes[T]!;

      final (properties, parameters) = _normalizeParametersAndProps(entity.properties, cls.parameters);

      _extractProps(properties, parameters);

      final map = <String, dynamic>{};

      for (var i = 0; i < parameters.length; i++) {
        final param = parameters[i];

        map[i.toString()] = {
          'type': param.type.replaceAll('?', ''),
          'nullable': param.nullable,
          'value': param.value,
        };
      }

      return <String, dynamic>{
        'type': T.toString().replaceAll('?', ''),
        'nullable': T.toString().endsWith('?'),
        'parameters': map,
      };
    } else {
      final isList = T.toString().startsWith('List');

      if (isList) {
        final (:type, rounds: _) = _typeListFromString(T.toString());

        if (type case 'dynamic' || 'Object' || 'Object?') {
          throw InvalidException('Invalid type of list $T!');
        }

        if (_isTypeOf<T, List<Entity>>()) {
          if (_classes.keys.any((key) => key.toString() == type)) {
            final cls = _classes.entries.firstWhere((entry) => entry.key.toString() == type).value;
            final listValues = <Map<String, dynamic>>[];
            final listEntities = (value as List).cast<Entity>();

            for (final entity in listEntities) {
              final (properties, parameters) = _normalizeParametersAndProps(entity.properties, cls.parameters);

              _extractProps(properties, parameters);

              final map = <String, dynamic>{};

              for (var i = 0; i < parameters.length; i++) {
                final param = parameters[i];

                map[i.toString()] = {
                  'type': param.type.replaceAll('?', ''),
                  'nullable': param.nullable,
                  'value': param.value,
                };
              }

              listValues.add({
                'type': type.replaceAll('?', ''),
                'nullable': type.endsWith('?'),
                'parameters': map,
              });
            }

            return {
              'type': T.toString().replaceAll('?', ''),
              'nullable': T.toString().endsWith('?'),
              'list': {
                'type': type.replaceAll('?', ''),
                'nullable': type.endsWith('?'),
              },
              'value': listValues,
            };
          } else {
            throw NotRegisteredException('Class $type not registered!');
          }
        }

        switch (type) {
          case 'String' || 'String?':
          case 'int' || 'int?':
          case 'double' || 'double?':
          case 'bool' || 'bool?':
            return {
              'type': T.toString().replaceAll('?', ''),
              'nullable': T.toString().endsWith('?'),
              'list': {
                'type': type.replaceAll('?', ''),
                'nullable': type.endsWith('?'),
              },
              'value': value,
            };
          case 'DateTime' || 'DateTime?':
            return {
              'type': T.toString().replaceAll('?', ''),
              'nullable': T.toString().endsWith('?'),
              'list': {
                'type': type.replaceAll('?', ''),
                'nullable': type.endsWith('?'),
              },
              'value': (value as List).map((e) => e?.millisecondsSinceEpoch).toList(),
            };
          default:
            throw NotSupportedException('Unsupported type $T!');
        }
      } else {
        switch (T.toString()) {
          case 'String' || 'String?':
          case 'int' || 'int?':
          case 'double' || 'double?':
          case 'bool' || 'bool?':
            return {
              'type': T.toString().replaceAll('?', ''),
              'nullable': T.toString().endsWith('?'),
              'value': value,
            };
          case 'DateTime' || 'DateTime?':
            return {
              'type': T.toString().replaceAll('?', ''),
              'nullable': T.toString().endsWith('?'),
              'value': (value as DateTime).millisecondsSinceEpoch,
            };
          default:
            throw NotSupportedException('Unsupported type $T!');
        }
      }
    }
  }

  void _extractProps(List props, List<Parameter> parameters) {
    if (props.length != parameters.length) {
      throw const InvalidException('Wrong number of parameters!');
    }

    for (var i = 0; i < props.length; i++) {
      final prop = props.elementAt(i);
      final param = parameters[i];

      parameters[i] = param.setValue(_propToDynamic(prop));
    }
  }

  void _extractValues(List<Parameter> parameters, Map<String, dynamic> sourceParameters) {
    for (var i = 0; i < parameters.length; i++) {
      final parameter = parameters[i];

      if (_classes.keys.any((key) => key.toString() == parameter.type)) {
        final sourceParameter = Map<String, dynamic>.from(sourceParameters[i.toString()]['value']);
        final innerCls = _classes.entries.firstWhere((entry) => entry.key.toString() == parameter.type).value;
        final innerParameters = innerCls.parameters;
        final innerSourceParameters = Map<String, dynamic>.from(sourceParameter['parameters']);

        _extractValues(innerParameters, innerSourceParameters);

        parameters[i] = parameter.setValue(innerCls.invoke(innerParameters));
      } else {
        final sourceParameter = Map<String, dynamic>.from(sourceParameters[i.toString()]);

        parameters[i] = switch (parameter.type) {
          'String' when sourceParameter['type'] == 'String' => parameter.setValue(sourceParameter['value']),
          'List<String>' when sourceParameter['type'] == 'List<String>' => parameter.setValue(
              sourceParameter['value'] == null ? null : (sourceParameter['value'] as List).map((e) => e.toString()).toList(),
            ),
          'int' when sourceParameter['type'] == 'int' => parameter.setValue(sourceParameter['value']),
          'List<int>' when sourceParameter['type'] == 'List<int>' => parameter.setValue(
              sourceParameter['value'] == null ? null : (sourceParameter['value'] as List).map((e) => int.parse(e.toString())).toList(),
            ),
          'double' when sourceParameter['type'] == 'double' => parameter.setValue(sourceParameter['value']),
          'List<double>' when sourceParameter['type'] == 'List<double>' => parameter.setValue(
              sourceParameter['value'] == null ? null : (sourceParameter['value'] as List).map((e) => double.parse(e.toString())).toList(),
            ),
          'bool' when sourceParameter['type'] == 'bool' => parameter.setValue(sourceParameter['value']),
          'List<bool>' when sourceParameter['type'] == 'List<bool>' => parameter.setValue(
              sourceParameter['value'] == null ? null : (sourceParameter['value'] as List).map((e) => bool.parse(e.toString())).toList(),
            ),
          'DateTime' when sourceParameter['type'] == 'DateTime' => parameter.setValue(
              sourceParameter['value'] == null ? null : DateTime.fromMillisecondsSinceEpoch(sourceParameter['value']),
            ),
          'List<DateTime>' when sourceParameter['type'] == 'List<DateTime>' => parameter.setValue(
              sourceParameter['value'] == null ? null : (sourceParameter['value'] as List).map((e) => DateTime.fromMillisecondsSinceEpoch(e)).toList(),
            ),
          _ => throw NotSupportedException('Unsupported type: ${parameter.type}'),
        };
      }
    }
  }

  dynamic _propToDynamic(dynamic prop) {
    if (prop is List) {
      String? listType = _getListType(prop);
      if (listType?.endsWith('?') ?? false) {
        listType = listType?.substring(0, listType.length - 1);
      }
      switch (listType) {
        case 'String':
        case 'int':
        case 'double':
        case 'bool':
          return prop;
        case 'DateTime':
          return prop.map((e) => (e as DateTime).millisecondsSinceEpoch).toList();
        default:
          throw NotSupportedException('Unknown type: ${prop.runtimeType}');
      }
    } else if (prop is Entity) {
      if (!_classes.containsKey(prop.runtimeType)) {
        throw NotRegisteredException('Class ${prop.runtimeType} not registered!');
      }

      final innerCls = _classes[prop.runtimeType]!;

      final (properties, parameters) = _normalizeParametersAndProps(prop.properties, innerCls.parameters);

      _extractProps(properties, parameters);

      return {
        'type': innerCls.type.toString().replaceAll('?', ''),
        'nullable': innerCls.type.toString().endsWith('?'),
        'parameters': parameters.asMap().entries.fold(
          <String, dynamic>{},
          (prev, next) => {
            ...prev,
            next.key.toString(): {
              'type': next.value.type.toString().replaceAll('?', ''),
              'nullable': next.value.nullable,
              'value': next.value.value,
            }
          },
        ),
      };
    } else {
      switch (prop.runtimeType.toString().replaceAll('?', '')) {
        case 'String':
        case 'int':
        case 'double':
        case 'bool':
        case 'Null':
          return prop;
        case 'DateTime':
          return (prop as DateTime).millisecondsSinceEpoch;
        default:
          throw NotSupportedException('Unknown type: ${prop.runtimeType}');
      }
    }
  }

  // Map<String, dynamic> _load() {
  //   if (_values.isEmpty) {
  //     _values.clear();
  //     _values.addAll(_storage.load());
  //   }
  //   return _values;
  // }

  // void _save(Map<String, dynamic> map) {
  //   _values.addAll(map);
  //   _storage.save(_values);
  // }

  // void _clear() {
  //   _values.clear();
  //   _storage.save(_values);
  // }

  String? _getListType(List list) {
    try {
      var temp = list;
      temp.add(_placeholder);
      return null;
    } catch (e) {
      return RegExp(r"type '(.+)' is not a subtype of type '(.+)' of '(.+)'").firstMatch(e.toString())?.group(2);
    }
  }

  (List properties, List<Parameter> parameters) _normalizeParametersAndProps(Map<Symbol, dynamic> properties, List<Parameter> parameters) {
    if (!_isWeb) return (properties.values.toList(), parameters);

    final positionalParameters = parameters.whereType<PositionalParameter>().toList();

    final namedParameters = [];

    for (var i = 0; i < properties.length; i++) {
      final named = parameters.whereType<NamedParameter>().toList();
      final property = properties.entries.elementAt(i);

      if (named.any((parameter) => parameter.named == property.key)) {
        final index = named.indexWhere((parameter) => parameter.named == property.key);
        namedParameters.add(named[index]);
      }
    }

    namedParameters.sort((a, b) => a.named.toString().compareTo(b.named.toString()));

    final params = <Parameter>[...positionalParameters, ...namedParameters];

    final props = properties.entries.toList();

    final namedProps = props.where((element) => namedParameters.any((e) => e.named == element.key)).toList();

    namedProps.sort((a, b) => a.key.toString().compareTo(b.key.toString()));

    final finalProps = [
      ...props.where((e) => !namedProps.contains(e)),
      ...namedProps,
    ].map((e) => e.value).toList();

    return (finalProps, params);
  }

  ({String type, int rounds}) _typeListFromString(String listType, [int rounds = 1]) {
    final regex = RegExp(r'List<(.+)>');
    final match = regex.firstMatch(listType);
    if (match == null) {
      throw Exception('Invalid list type $listType!');
    } else {
      final type = match.group(1);
      if (type?.startsWith('List') == true) {
        throw const NestedListException();
      } else {
        return (type: type!, rounds: rounds);
      }
    }
  }
}

final class _FDatabasePlaceholder {
  final int timestamp;
  const _FDatabasePlaceholder(this.timestamp);
}

const _placeholder = _FDatabasePlaceholder(1234567890);

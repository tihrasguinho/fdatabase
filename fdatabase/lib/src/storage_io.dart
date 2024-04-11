library fdatabase_io;

import 'dart:convert';
import 'dart:io';

import 'package:fdatabase_base/fdatabase_base.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

const _emptyDatabase = '{}';

class _StorageIoImp implements Storage {
  final File _file;

  const _StorageIoImp(this._file);

  @override
  void clear() => _file.writeAsStringSync(_emptyDatabase);

  @override
  bool exists(String key) {
    final source = jsonDecode(_file.readAsStringSync()) as Map<String, dynamic>;

    return source.containsKey(key);
  }

  @override
  Map<String, dynamic>? get(String key) {
    final source = jsonDecode(_file.readAsStringSync()) as Map<String, dynamic>;

    final value = source[key];

    if (value == null) return null;

    return jsonDecode(_fromBase64(value)) as Map<String, dynamic>;
  }

  @override
  String? get path => _file.path;

  @override
  void put(String key, Map<String, dynamic> value) {
    final source = jsonDecode(_file.readAsStringSync()) as Map<String, dynamic>;
    source[key] = _toBase64(jsonEncode(value));
    _file.writeAsStringSync(jsonEncode(source));
  }

  @override
  void putMany(Map<String, Map<String, dynamic>> values) {
    final source = jsonDecode(_file.readAsStringSync()) as Map<String, dynamic>;
    source.addAll(
      values.entries.fold(
        <String, String>{},
        (prev, next) => {
          ...prev,
          next.key: _toBase64(jsonEncode(next.value)),
        },
      ),
    );
    return _file.writeAsStringSync(jsonEncode(source));
  }

  @override
  void remove(String key) {
    final source = jsonDecode(_file.readAsStringSync()) as Map<String, dynamic>;
    source.remove(key);
    _file.writeAsStringSync(jsonEncode(source));
  }
}

String _toBase64(String source) => base64.encode(utf8.encode(source));
String _fromBase64(String source) => utf8.decode(base64.decode(source));

Future<Storage> getStorage() async {
  final dir = await getApplicationDocumentsDirectory();

  return _StorageIoImp(File(p.join(dir.path, 'fDatabase', 'database.json')));
}

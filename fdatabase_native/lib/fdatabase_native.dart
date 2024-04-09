library fdatabase_native;

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
  Map<String, dynamic> load() {
    if (!_file.existsSync()) {
      _file.createSync(recursive: true);
      _file.writeAsStringSync(_toBase64(_emptyDatabase));
      return {};
    } else {
      return json.decode(_fromBase64(_file.readAsStringSync()));
    }
  }

  @override
  String? get path => _file.path;

  @override
  void remove() {
    _file.writeAsStringSync(_toBase64(_emptyDatabase));
  }

  @override
  void save(Map<String, dynamic> value) {
    final map = load();
    map.addAll(value);
    return _file.writeAsStringSync(_toBase64(json.encode(map)));
  }
}

String _toBase64(String source) => base64.encode(utf8.encode(source));
String _fromBase64(String source) => utf8.decode(base64.decode(source));

Future<Storage> getNativeStorage() async {
  final dir = await getApplicationDocumentsDirectory();

  return _StorageIoImp(File(p.join(dir.path, 'fDatabase', 'database')));
}

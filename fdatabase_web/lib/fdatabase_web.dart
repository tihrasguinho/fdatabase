// ignore_for_file: avoid_web_libraries_in_flutter

library fdatabase_web;

import 'dart:convert';

import 'package:fdatabase_base/fdatabase_base.dart';
import 'dart:html' as html;

const String _fdatabaseKey = 'dev.tihrasguinho.fdatabase';
const String _emptyDatabase = 'e30=';

class _StorageWebImp implements Storage {
  @override
  Map<String, dynamic> load() {
    final storage = html.window.localStorage[_fdatabaseKey] ??= _emptyDatabase;

    return jsonDecode(_fromBase64(storage)) as Map<String, dynamic>;
  }

  @override
  String? get path => null;

  @override
  void remove() {
    html.window.localStorage[_fdatabaseKey] = _emptyDatabase;
  }

  @override
  void save(Map<String, dynamic> value) {
    html.window.localStorage[_fdatabaseKey] = _toBase64(jsonEncode(value));
  }
}

String _toBase64(String value) => base64.encode(utf8.encode(value));
String _fromBase64(String value) => utf8.decode(base64.decode(value));

Storage getWebStorage() => _StorageWebImp();

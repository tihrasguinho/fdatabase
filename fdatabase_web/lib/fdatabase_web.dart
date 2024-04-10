// ignore_for_file: avoid_web_libraries_in_flutter

library fdatabase_web;

import 'dart:convert';

import 'package:fdatabase_base/fdatabase_base.dart';
import 'dart:html' as html;

class _StorageWebImp implements Storage {
  @override
  void clear() => html.window.localStorage.clear();

  @override
  bool exists(String key) => html.window.localStorage.containsKey(key);

  @override
  Map<String, dynamic>? get(String key) {
    final value = html.window.localStorage[key];

    if (value == null) return null;

    return jsonDecode(_fromBase64(value)) as Map<String, dynamic>;
  }

  @override
  String? get path => null;

  @override
  void put(String key, Map<String, dynamic> value) {
    html.window.localStorage[key] = _toBase64(jsonEncode(value));
  }

  @override
  void remove(String key) {
    html.window.localStorage.remove(key);
  }
}

String _toBase64(String value) => base64.encode(utf8.encode(value));
String _fromBase64(String value) => utf8.decode(base64.decode(value));

Storage getWebStorage() => _StorageWebImp();

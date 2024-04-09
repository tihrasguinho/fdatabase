import 'package:fdatabase_base/fdatabase_base.dart';
import 'package:fdatabase_native/fdatabase_native.dart';

Future<Storage> getStorage() async => getNativeStorage();

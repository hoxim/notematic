import 'package:drift/native.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

Future<QueryExecutor> createDbExecutor() async {
  final dir = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(dir.path, 'notematic.sqlite'));
  return NativeDatabase(dbFile);
}

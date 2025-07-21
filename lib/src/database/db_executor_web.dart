import 'package:drift/wasm.dart';
import 'package:drift/drift.dart';

Future<QueryExecutor> createDbExecutor() async {
  final wasmResult = await WasmDatabase.open(
    databaseName: 'notematic_web',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  return wasmResult.resolvedExecutor;
}

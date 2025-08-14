import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notematic_app/src/services/unified_storage_service.dart';
import 'package:notematic_app/src/services/unified_sync_service.dart';
import 'package:notematic_app/src/services/api_service.dart';
import 'package:notematic_app/src/services/logger_service.dart';

class ApiServiceMock extends Mock implements ApiService {}

void main() {
  setUpAll(() {
    LoggerService().init();
  });
  late UnifiedStorageService storage;
  late ApiServiceMock api;
  late UnifiedSyncService sync;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({'isSyncEnabled': true});
    storage = UnifiedStorageService();
    await storage.initializeWithExecutor(NativeDatabase.memory());
    await storage.ensureDefaultNotebook();
    api = ApiServiceMock();
    sync = UnifiedSyncService(api, LoggerService());
  });

  tearDown(() async {
    await storage.close();
  });

  test('offline create then sync to server (create)', () async {
    when(() => api.isOnline()).thenAnswer((_) async => true);
    when(() => api.getNotes()).thenAnswer((_) async => []);
    when(() => api.getNotebooks()).thenAnswer((_) async => []);
    when(() => api.createNote(any()))
        .thenAnswer((_) async => {'version': DateTime.now().toIso8601String()});
    when(() => api.createNotebook(any()))
        .thenAnswer((_) async => {'version': DateTime.now().toIso8601String()});
    when(() => api.updateNotebook(any(), any()))
        .thenAnswer((_) async => {'version': DateTime.now().toIso8601String()});

    final nb = await storage.ensureDefaultNotebook();
    final note = await storage.createNote(
        title: 'S', content: 'C', notebookUuid: nb.uuid);

    await sync.initialize();
    await sync.fullSync();

    final updated = await storage.getNoteByUuid(note.uuid);
    expect(updated?.isSynced, true);
    verify(() => api.createNote(any())).called(greaterThan(0));
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Notematic/src/services/unified_storage_service.dart';
import 'package:Notematic/src/services/logger_service.dart';

void main() {
  setUpAll(() {
    LoggerService().init();
  });
  late UnifiedStorageService storage;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    storage = UnifiedStorageService();
    await storage.initializeWithExecutor(NativeDatabase.memory());
    await storage.ensureDefaultNotebook();
  });

  tearDown(() async {
    await storage.close();
  });

  test('create/update/delete note locally', () async {
    final nb = await storage.ensureDefaultNotebook();
    final note = await storage.createNote(
      title: 'T',
      content: 'C',
      notebookUuid: nb.uuid,
    );
    expect((await storage.getAllNotes()).length, 1);

    note.update(title: 'T2', content: 'C2');
    await storage.updateNote(note);
    final fetched = await storage.getNoteByUuid(note.uuid);
    expect(fetched?.title, 'T2');

    await storage.deleteNote(note.uuid);
    final deleted = await storage.getNoteByUuid(note.uuid);
    expect(deleted?.deleted, true);
  });
}

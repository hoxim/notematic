import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/simple_local_storage.dart';

final simpleLocalStorageProvider = Provider<SimpleLocalStorage>((ref) {
  return SimpleLocalStorage();
});

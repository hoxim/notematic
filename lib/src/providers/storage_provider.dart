import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/unified_storage_service.dart';

final unifiedStorageServiceProvider = Provider<UnifiedStorageService>((ref) {
  return UnifiedStorageService();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/unified_sync_service.dart';
import '../services/api_service.dart';

final unifiedSyncServiceProvider = Provider<UnifiedSyncService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return UnifiedSyncService(apiService);
});

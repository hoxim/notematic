import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/unified_sync_service.dart';
import '../services/api_service.dart';
import 'logger_provider.dart';

final unifiedSyncServiceProvider = Provider<UnifiedSyncService>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final logger = ref.read(loggerServiceProvider);
  return UnifiedSyncService(apiService, logger);
});

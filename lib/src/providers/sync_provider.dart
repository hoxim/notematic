import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'simple_local_storage_provider.dart';

final syncEnabledProvider =
    StateNotifierProvider<SyncEnabledNotifier, AsyncValue<bool>>((ref) {
  return SyncEnabledNotifier(ref);
});

class SyncEnabledNotifier extends StateNotifier<AsyncValue<bool>> {
  final Ref _ref;

  SyncEnabledNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadSyncEnabled();
  }

  Future<void> _loadSyncEnabled() async {
    try {
      state = const AsyncValue.loading();
      final storage = _ref.read(simpleLocalStorageProvider);
      final isEnabled = await storage.getBool('isSyncEnabled') ?? false;
      state = AsyncValue.data(isEnabled);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleSync() async {
    try {
      final storage = _ref.read(simpleLocalStorageProvider);
      final currentValue = await storage.getBool('isSyncEnabled') ?? false;
      await storage.setBool('isSyncEnabled', !currentValue);
      state = AsyncValue.data(!currentValue);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> setSyncEnabled(bool enabled) async {
    try {
      final storage = _ref.read(simpleLocalStorageProvider);
      await storage.setBool('isSyncEnabled', enabled);
      state = AsyncValue.data(enabled);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/logger_service.dart';

final loggerServiceProvider = Provider<LoggerService>((ref) {
  return LoggerService();
});

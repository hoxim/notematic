import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get googleClientId {
    return dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  }

  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
  }

  static bool get isGoogleClientIdConfigured {
    final clientId = googleClientId;
    return clientId.isNotEmpty && clientId != 'YOUR_SERVER_CLIENT_ID_HERE';
  }
}

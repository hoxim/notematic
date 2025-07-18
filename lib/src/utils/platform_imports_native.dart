// Native platform imports
import 'package:cbl_flutter/cbl_flutter.dart';

// Initialize Couchbase Lite
Future<void> initializePlatformServices() async {
  await CouchbaseLiteFlutter.init();
}

// This file handles platform-specific imports

// Import Couchbase Lite only for non-web platforms
export 'platform_imports_native.dart'
    if (dart.library.html) 'platform_imports_web.dart';

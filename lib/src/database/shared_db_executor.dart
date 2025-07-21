export 'db_executor_unsupported.dart'
    if (dart.library.ffi) 'db_executor_native.dart'
    if (dart.library.js_interop) 'db_executor_web.dart';

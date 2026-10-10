export 'media_persistence_stub.dart'
    if (dart.library.io) 'media_persistence_io.dart'
    if (dart.library.js_interop) 'media_persistence_web.dart';

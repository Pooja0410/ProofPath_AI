export 'audio_path_stub.dart'
    if (dart.library.io) 'audio_path_io.dart'
    if (dart.library.js_interop) 'audio_path_web.dart';

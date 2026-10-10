import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String?> persistVideo(String sourcePath, DateTime startedAt) async {
  try {
    final directory = await getApplicationSupportDirectory();
    final evidenceDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}proofpath_evidence',
    );
    await evidenceDirectory.create(recursive: true);

    final id = 'PP-${startedAt.year}-${startedAt.millisecondsSinceEpoch.toString().substring(4)}';
    final destination =
        '${evidenceDirectory.path}${Platform.pathSeparator}$id.mp4';

    await File(sourcePath).copy(destination);
    return destination;
  } catch (_) {
    return sourcePath;
  }
}

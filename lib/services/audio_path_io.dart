import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> prepareAudioPath(DateTime startedAt) async {
  final directory = await getApplicationSupportDirectory();
  final evidenceDirectory = Directory(
    '${directory.path}${Platform.pathSeparator}proofpath_evidence',
  );
  await evidenceDirectory.create(recursive: true);
  return '${evidenceDirectory.path}${Platform.pathSeparator}PP-${startedAt.year}-${startedAt.millisecondsSinceEpoch.toString().substring(4)}.m4a';
}

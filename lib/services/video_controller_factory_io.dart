import 'dart:io';
import 'package:video_player/video_player.dart';

VideoPlayerController createVideoController(String source) {
  if (source.startsWith('http://') || source.startsWith('https://') || source.startsWith('blob:')) {
    return VideoPlayerController.networkUrl(Uri.parse(source));
  }
  return VideoPlayerController.file(File(source));
}

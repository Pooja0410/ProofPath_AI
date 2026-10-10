import 'package:video_player/video_player.dart';

VideoPlayerController createVideoController(String source) =>
    VideoPlayerController.networkUrl(Uri.parse(source));

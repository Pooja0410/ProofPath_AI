Future<String?> persistVideo(String sourcePath, DateTime startedAt) async {
  // camera_web returns a browser Blob URL. Keep it for playback during the
  // current app session; the browser owns the underlying recording bytes.
  return sourcePath;
}

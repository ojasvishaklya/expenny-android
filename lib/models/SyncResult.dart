/// Result of a sync operation, returned to the UI layer.
class SyncResult {
  final int imported;
  final int skippedDuplicate;
  final int unparsed;
  final SyncError? error;

  const SyncResult({
    this.imported = 0,
    this.skippedDuplicate = 0,
    this.unparsed = 0,
    this.error,
  });

  bool get isSuccess => error == null;
}

enum SyncError {
  permissionDenied,
  pluginUnavailable,
}

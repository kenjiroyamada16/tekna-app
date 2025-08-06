class AppException implements Exception {
  final dynamic error;
  final String userFriendlyMessage;

  AppException({required this.userFriendlyMessage, this.error});
}

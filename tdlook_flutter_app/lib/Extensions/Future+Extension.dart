extension FutureExtension on Future {
  static Future<bool> enableContinueTimer({int delay}) async {
    await Future.delayed(Duration(seconds: delay));
  }
}
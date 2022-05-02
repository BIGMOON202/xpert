extension FutureExtension on Future {
  static Future<bool> enableContinueTimer({required int delay}) async {
    final value = await Future.delayed(Duration(seconds: delay));
    return value as bool;
  }
}

extension FutureExtension on Future {
  static Future<dynamic> enableContinueTimer({required int delay}) async {
    final value = await Future.delayed(Duration(seconds: delay));
    return value;
  }
}

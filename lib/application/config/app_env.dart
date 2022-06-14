import 'package:flutter_dotenv/flutter_dotenv.dart';

enum EnvironmentType { xpertfit, backstage }

class AppEnv {
  static String get name => dotenv.env['NAME'] ?? '';
  static String get host => dotenv.env['HOST'] ?? '';
  static String get icon => dotenv.env['ICON'] ?? '';

  static load() async {
    final env = const String.fromEnvironment('ENV');
    final filename = '${env.toLowerCase()}.env';
    if (filename.isEmpty) {
      throw 'Invironment not installed. Please set ENV param';
    }
    await dotenv.load(fileName: '.env/$filename');
  }
}

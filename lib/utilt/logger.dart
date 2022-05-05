import 'package:logger/logger.dart';

final logger = Logger(
  filter: DevelopmentFilter(),
  level: Logger.level,
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: false,
    printTime: false,
  ),
);

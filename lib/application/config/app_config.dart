import 'package:tdlook_flutter_app/Extensions/Application.dart';

abstract class AppConfig {
  late String iconPath;
  late API apiType;
}

class ReleaseAppConfig implements AppConfig {
  API apiType = API.release;
  String iconPath = "assets/icon.png";
}

class BackstageAppConfig implements AppConfig {
  API apiType = API.stage;
  String iconPath = "assets/icon_backstage.png";
}

import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';

import 'Colors+Extension.dart';

class SessionParameters {
  static final String keyProMode = 'pro_mode';
  static final SessionParameters _instance = SessionParameters._internal();
  static SessionParameters get instance => _instance;

  factory SessionParameters() {
    return _instance;
  }
  SessionParameters._internal();

  MeasurementModel? currentMeasurement;
  CompanyType? selectedCompany;
  UserType? selectedUser;
  CaptureMode? captureMode;

  int get delayForPageAction => Application.isInDebugMode ? 1 : 3;

  final Color mainBackgroundColor = HexColor.fromHex('16181B');
  final Color mainFontColor = Colors.white;
  final Color selectionColor = HexColor.fromHex('1E7AE4');
  final Color disableColor = HexColor.fromHex('353739');
  final Color disableTextColor = HexColor.fromHex('676767');
  final Color optionColor = HexColor.fromHex('D8D8D8');
}


import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'Colors+Extension.dart';

class SessionParameters {

  static final String keyProMode = 'pro_mode';
  static final SessionParameters _instance = SessionParameters._internal();

  // using a factory is important
  // because it promises to return _an_ object of this type
  // but it doesn't promise to make a new one.
  factory SessionParameters() {
    return _instance;
  }

  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  SessionParameters._internal() {
    // initialization logic
  }



  MeasurementModel currentMeasurement;
  CompanyType selectedCompany;
  UserType selectedUser;
  CaptureMode captureMode;

  int get delayForPageAction => Application.isInDebugMode ? 0 : 3;

  Color mainBackgroundColor = HexColor.fromHex('16181B');
  Color mainFontColor = Colors.white;
  Color selectionColor = HexColor.fromHex('1E7AE4');
  Color disableColor = HexColor.fromHex('353739');
  Color disableTextColor = HexColor.fromHex('676767');
  Color optionColor = HexColor.fromHex('D8D8D8');
}


import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'Colors+Extension.dart';

class SharedParameters {

  static final SharedParameters _instance = SharedParameters._internal();

  // using a factory is important
  // because it promises to return _an_ object of this type
  // but it doesn't promise to make a new one.
  factory SharedParameters() {
    return _instance;
  }

  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  SharedParameters._internal() {
    // initialization logic
  }



  MeasurementModel currentMeasurement;
  CompanyType selectedCompany;
  UserType selectedUser;

  Color mainBackgroundColor = HexColor.fromHex('16181B');
  Color selectionColor = HexColor.fromHex('1E7AE4');
}


import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'Colors+Extension.dart';

class SharedParameters {
  factory SharedParameters() =>
      SharedParameters._internal_();

  SharedParameters._internal_();



  MeasurementModel currentMeasurement;
  Color mainBackgroundColor = HexColor.fromHex('16181B');
  Color selectionColor = HexColor.fromHex('1E7AE4');
}

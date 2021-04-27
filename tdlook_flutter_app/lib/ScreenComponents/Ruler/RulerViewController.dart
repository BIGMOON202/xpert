import 'package:flutter/material.dart';

import '../../Models/MeasurementModel.dart';

class RulerViewController extends ChangeNotifier {
  RulerViewController({
    double value = 0.0,
    String defaultImperialHeightValue = "6’0\”",
    String defaultMetricHeightValue = "180",
    MeasurementSystem measurementSystem = MeasurementSystem.imperial,
  })  : assert(value != null),
        assert(measurementSystem != null),
        _defaultImperialHeightValue = defaultImperialHeightValue,
        _defaultMetricHeightValue = defaultMetricHeightValue,
        _measurementSystem = measurementSystem,
        _value = value;

  MeasurementSystem _measurementSystem;
  MeasurementSystem get measurementSystem => _measurementSystem;
  set measurementSystem(MeasurementSystem newValue) {
    _measurementSystem = newValue;
    notifyListeners();
  }

  double _value;
  double get value => _value;
  set value(double newValue) {
    _value = newValue;
    notifyListeners();
  }

  String _defaultImperialHeightValue;
  String get defaultImperialHeightValue => _defaultImperialHeightValue;

  String _defaultMetricHeightValue;
  String get defaultMetricHeightValue => _defaultMetricHeightValue;
}

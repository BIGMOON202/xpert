import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/ScreenComponents/Ruler/RulerValues.dart';

import '../../Models/MeasurementModel.dart';

enum RulerViewType { heights, weights }
typedef void ValueChangedCallback(String? value, double? rawValue);

extension StringToInt on String {
  int getIntValue() {
    return int.parse(this.replaceAll(RegExp('[^0-9]'), ''));
  }
}

final kDefaultImperialHeightValue = '6’0\”';
final kDefaultMetricHeightValue = '180'; // cm
final kDefaultImperialWeightValue = '176'; //lbs (kg * 2.2)
final kDefaultMetricWeightValue = '80'; // kg

class RulerViewController extends ChangeNotifier {
  RulerViewController({
    RulerViewType type = RulerViewType.heights,
    ValueChangedCallback? onChangedValue,
    MeasurementSystem measurementSystem = MeasurementSystem.imperial,
  })  : assert(measurementSystem != null),
        assert(onChangedValue != null),
        assert(type != null),
        _type = type,
        _defaultImperialValue = type == RulerViewType.heights
            ? kDefaultImperialHeightValue
            : kDefaultImperialWeightValue,
        _defaultMetricValue =
            type == RulerViewType.heights ? kDefaultMetricHeightValue : kDefaultMetricWeightValue,
        _measurementSystem = measurementSystem,
        _onChangedValue = onChangedValue,
        _values = type == RulerViewType.heights
            ? RulerValues.heights(measurementSystem)
            : RulerValues.weights(measurementSystem);

  MeasurementSystem _measurementSystem;
  MeasurementSystem get measurementSystem => _measurementSystem;
  set measurementSystem(MeasurementSystem newValue) {
    _measurementSystem = newValue;
    _values = type == RulerViewType.heights
        ? RulerValues.heights(newValue)
        : RulerValues.weights(newValue);
    notifyListeners();
  }

  RulerViewType _type;
  RulerViewType get type => _type;

  RulerValues _values;
  RulerValues get values => _values;

  ValueChangedCallback? _onChangedValue;
  ValueChangedCallback get onChangedValue => _onChangedValue!;

  String _defaultImperialValue;
  String get defaultImperialValue => _defaultImperialValue;

  String _defaultMetricValue;
  String get defaultMetricValue => _defaultMetricValue;
}

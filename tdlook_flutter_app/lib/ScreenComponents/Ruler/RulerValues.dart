import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';

class RulerValues {
  Map<String, String> values = Map<String, String>();
  RulerValues.heights(MeasurementSystem system) {
    switch (system) {
      case MeasurementSystem.imperial:
        values = {
          "4’11\”": "150",
          "5’0\”": "153",
          "5’1\”": "155",
          "5’2”\”": "158",
          "5’3\”": "160",
          "5’4\”": "163",
          "5’5\”": "165",
          "5’6\”": "168",
          "5’7\”": "170",
          "5’8\”": "173",
          "5’9\”": "176",
          "5’10\”": "178",
          "5’11\”": "180",
          "6’0\”": "183",
          "6’1\”": "185",
          "6’2\”": "188",
          "6’3\”": "191",
          "6’4\”": "193",
          "6’5\”": "196",
          "6’6\”": "198",
          "6’7\”": "201",
          "6’8\”": "203",
          "6’9\”": "206",
          "6’10\”": "208",
          "6’11\”": "211",
          "7’0\”": "213",
          "7’1\”": "216",
          "7’2\”": "218",
          "7’3\”": "220",
        };
        break;
      case MeasurementSystem.metric:
        values = {
          "150": "4’11\”",
          "151": "4’11\”",
          "152": "5’0\”",
          "153": "5’0\”",
          "154": "5’1\”",
          "155": "5’1\”",
          "156": "5’1\”",
          "157": "5’2\”",
          "158": "5’2\”",
          "159": "5’3\”",
          "160": "5’3\”",
          "161": "5’3\”",
          "162": "5’4\”",
          "163": "5’4\”",
          "164": "5’4\”",
          "165": "5’5\”",
          "166": "5’5\”",
          "167": "5’6\”",
          "168": "5’6\”",
          "169": "5’7\”",
          "170": "5’7\”",
          "171": "5’7\”",
          "172": "5’8\”",
          "173": "5’8\”",
          "174": "5’8\”",
          "175": "5’9\”",
          "176": "5’9\”",
          "177": "5’10\”",
          "178": "5’10\”",
          "179": "5’10\”",
          "180": "5’11\”",
          "181": "5’11\”",
          "182": "6’0\”",
          "183": "6’0\”",
          "184": "6’0\”",
          "185": "6’1\”",
          "186": "6’1\”",
          "187": "6’2\”",
          "188": "6’2\”",
          "189": "6’2\”",
          "190": "6’3\”",
          "191": "6’3\”",
          "192": "6’4\”",
          "193": "6’4\”",
          "194": "6’4\”",
          "195": "6’5\”",
          "196": "6’5\”",
          "197": "6’5\”",
          "198": "6’6\”",
          "199": "6’6\”",
          "200": "6’7\”",
          "201": "6’7\”",
          "202": "6’7\”",
          "203": "6’8\”",
          "204": "6’8\”",
          "205": "6’9\”",
          "206": "6’9\”",
          "207": "6’9\”",
          "208": "6’10\”",
          "209": "6’10\”",
          "210": "6’11\”",
          "211": "6’11\”",
          "212": "6’11\”",
          "213": "7’0\”",
          "214": "7’0\”",
          "215": "7’1\”",
          "216": "7’1\”",
          "217": "7’1\”",
          "218": "7’2\”",
          "219": "7’2\”",
          "220": "7’3\”",
        };
        break;
    }
  }

  List<String> get valuesList => values.keys.toList();
  int get length => values.keys.length;
  String getValueAtIndex(int index) => values.keys.toList()[index] ?? "0";
  String getConverted(String key) => values[key] ?? key;
  String getRawValue(String key) => values[key] ?? key;
}

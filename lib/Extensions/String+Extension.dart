import 'package:tdlook_flutter_app/constants/global.dart';

extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) =>
      this.toLowerCase().contains(secondString.toLowerCase());

  String capitalizeFirst() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }

  String get onlyDigits => replaceAll(kDigitsOnlyRegExp, '');

  // Fix: EF-2420
  String get fixAllPhotoTexts => replaceAll('Photos', 'Scans')
      .replaceAll('photos', 'scans')
      .replaceAll('Photo', 'Scan')
      .replaceAll('photo', 'scan');
}

extension EmailValidator on String {
  bool isValidEmail() {
    return kEmailValidatorRegExp.hasMatch(this);
  }
}

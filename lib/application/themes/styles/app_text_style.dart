import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tdlook_flutter_app/application/themes/app_themes.dart';

class AppTextStyle {
  final TextStyle title;
  final TextStyle caption;
  final TextStyle boldBody;
  final TextStyle textBoxTitle;
  final TextStyle regular;
  final TextStyle button;
  final TextStyle textFieldText;

  const AppTextStyle({
    required this.title,
    required this.caption,
    required this.boldBody,
    required this.textBoxTitle,
    required this.regular,
    required this.button,
    required this.textFieldText,
  });

  factory AppTextStyle.of(BuildContext context) {
    final style = Theme.of(context).appTheme.textStyle;
    return style ?? AppTextStyle.regular();
  }

  factory AppTextStyle.regular() {
    //final font = GoogleFonts.kellySlab();
    //final font = GoogleFonts.kellySlab();
    final font = GoogleFonts.jura();
    return AppTextStyle(
      title: font.copyWith(
        fontFamily: 'Roboto',
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      caption: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF7F8489),
      ),
      boldBody: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.normal,
        color: Colors.white,
      ),
      textBoxTitle: GoogleFonts.roboto(
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      regular: font.copyWith(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      button: GoogleFonts.roboto(
        textStyle: TextStyle(
          color: Colors.white,
          letterSpacing: .5,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textFieldText: GoogleFonts.roboto(
        textStyle: TextStyle(
          color: Colors.white,
          letterSpacing: .64,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tdlook_flutter_app/application/themes/app_colors.dart';
import 'package:tdlook_flutter_app/application/themes/app_themes.dart';

class AppTextStyle {
  final TextStyle title;
  final TextStyle caption;
  final TextStyle boldBody;
  final TextStyle textBoxTitle;
  final TextStyle regular;
  final TextStyle button;
  final TextStyle bodyButtonTitle;
  final TextStyle textFieldText;
  final TextStyle error;
  final TextStyle s12w500;
  final TextStyle s12w700;
  final TextStyle s18w700;
  final TextStyle s30w700;

  const AppTextStyle({
    required this.title,
    required this.caption,
    required this.boldBody,
    required this.textBoxTitle,
    required this.regular,
    required this.button,
    required this.bodyButtonTitle,
    required this.textFieldText,
    required this.error,
    required this.s12w500,
    required this.s12w700,
    required this.s18w700,
    required this.s30w700,
  });

  factory AppTextStyle.of(BuildContext context) {
    final style = Theme.of(context).appTheme.textStyle;
    return style ?? AppTextStyle.regular();
  }

  factory AppTextStyle.regular() {
    //final font = GoogleFonts.kellySlab();
    //final font = GoogleFonts.kellySlab();
    final font = GoogleFonts.roboto();
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
      error: GoogleFonts.roboto(
        textStyle: TextStyle(
          color: AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      bodyButtonTitle: GoogleFonts.roboto(
        textStyle: TextStyle(
          color: Colors.white,
          letterSpacing: .64,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      s12w500: font.copyWith(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      s12w700: font.copyWith(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      s18w700: font.copyWith(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      s30w700: font.copyWith(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

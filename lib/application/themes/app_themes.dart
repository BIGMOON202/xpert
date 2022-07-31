import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlook_flutter_app/application/themes/app_colors.dart';
import 'package:tdlook_flutter_app/application/themes/styles/app_button_style.dart';
import 'package:tdlook_flutter_app/application/themes/styles/app_text_style.dart';

class AppThemeStyles {
  final AppTextStyle? textStyle;
  final AppButtonStyle? buttonStyle;

  const AppThemeStyles({
    AppTextStyle? textStyle,
    AppButtonStyle? buttonStyle,
  })  : this.textStyle = textStyle,
        this.buttonStyle = buttonStyle;

  factory AppThemeStyles.regular() {
    return AppThemeStyles(
      textStyle: AppTextStyle.regular(),
      buttonStyle: AppButtonStyle.regular(),
    );
  }
}

extension ThemeDataExtensions on ThemeData {
  static final Map<InputDecorationTheme, AppThemeStyles> _appTheme = {};

  void addAppTheme(AppThemeStyles style) {
    _appTheme[inputDecorationTheme] = style;
  }

  static AppThemeStyles? empty;

  AppThemeStyles get appTheme {
    var o = _appTheme[inputDecorationTheme];
    if (o == null) {
      empty ??= AppThemeStyles.regular();
      o = empty;
    }
    return o!;
  }
}

abstract class AppTheme {
  static final current = ThemeData(
    appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    ),
    scaffoldBackgroundColor: AppColors.background,

    // Text Theme
    // textTheme: const TextTheme(
    //   button: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textColor),
    //   caption: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textColor),
    //   headline1: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textColor),
    //   headline2: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textColor),
    //   bodyText1: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textColor),
    // ),

    // colorScheme: ColorScheme(
    //   brightness: null,
    //   error: Colors.red,
    //   onError: null,
    //   background: null,
    //   onBackground: null,
    //   onPrimary: null,
    //   secondary: null,
    //   onSecondary: null,
    //   secondaryVariant: _DEFAULT_TEXT_COLOR,
    //   onSurface: null,
    //   primary: null,
    //   primaryVariant: null,
    //   surface: null,
    // ),
  )..addAppTheme(AppThemeStyles.regular());
}

import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/application/themes/app_colors.dart';

class AppButtonStyle {
  final ButtonStyle? error;
  final ButtonStyle? action;

  const AppButtonStyle({
    required ButtonStyle? error,
    required ButtonStyle? action,
  })  : this.error = error,
        this.action = action;

  factory AppButtonStyle.regular() {
    return AppButtonStyle(
      error: OutlinedButton.styleFrom(
        backgroundColor: AppColors.accent,
        side: const BorderSide(
          width: 1,
          color: Colors.white,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
      ),
      action: OutlinedButton.styleFrom(
        backgroundColor: AppColors.accent,
        side: const BorderSide(
          width: 1,
          color: Colors.white,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(4),
          ),
        ),
      ),
    );
  }
}

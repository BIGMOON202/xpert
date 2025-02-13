import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/application/themes/app_colors.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isEnabled;
  final bool isSelected;
  final bool isBordered;
  final double height;
  const ActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.isEnabled: true,
    this.isSelected: true,
    this.isBordered: false,
    this.height: 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: MaterialButton(
        splashColor: Colors.transparent,
        elevation: 0,
        onPressed: isEnabled ? onPressed : null,
        textColor: Colors.white,
        child: child,
        disabledColor: SessionParameters().disableColor,
        color: isSelected ? AppColors.accent : SessionParameters().disableColor,
        highlightColor: AppColors.highlight,
        // padding: EdgeInsets.only(left: 12, right: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: isBordered
              ? BorderSide(
                  color: AppColors.background,
                  width: 1.0,
                )
              : BorderSide.none,
        ),

        // padding: EdgeInsets.all(4),
      ),
    );
  }
}

class LightActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isEnabled;
  final bool isSelected;
  final bool isBordered;
  final double height;
  const LightActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.isEnabled: true,
    this.isSelected: true,
    this.isBordered: false,
    this.height: 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: MaterialButton(
        splashColor: Colors.transparent,
        elevation: 0,
        onPressed: isEnabled ? onPressed : null,
        textColor: AppColors.lightButtonText,
        child: child,
        disabledColor: SessionParameters().disableColor,
        color: isSelected ? Colors.white : SessionParameters().disableColor,
        highlightColor: AppColors.lightButtonText.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: isBordered
              ? BorderSide(
                  color: AppColors.background,
                  width: 1.0,
                )
              : BorderSide.none,
        ),
      ),
    );
  }
}

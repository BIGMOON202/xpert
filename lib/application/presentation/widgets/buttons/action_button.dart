import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/application/themes/app_colors.dart';

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isEnabled;
  final bool isSelected;
  final double height;
  const ActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.isEnabled: true,
    this.isSelected: true,
    this.height: 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: MaterialButton(
        onPressed: isEnabled ? onPressed : null,
        textColor: Colors.white,
        child: child,
        disabledColor: SessionParameters().disableColor,
        color: isSelected ? AppColors.accent : SessionParameters().disableColor,
        highlightColor: AppColors.highlight,
        // padding: EdgeInsets.only(left: 12, right: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        // padding: EdgeInsets.all(4),
      ),
    );
  }
}

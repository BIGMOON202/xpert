import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/application/themes/app_colors.dart';

class ActionTextButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isEnabled;
  const ActionTextButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.isEnabled: true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      child: CustomText.withColor(
        title.toUpperCase(),
        isEnabled ? Colors.white : SessionParameters().disableTextColor,
      ),
      isEnabled: isEnabled,
      onPressed: onPressed,
    );
  }
}

class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isEnabled;
  const ActionButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.isEnabled: true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: MaterialButton(
        onPressed: isEnabled ? onPressed : null,
        textColor: Colors.white,
        child: child,
        disabledColor: SessionParameters().disableColor,
        color: AppColors.accent,
        // padding: EdgeInsets.only(left: 12, right: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        // padding: EdgeInsets.all(4),
      ),
    );
  }
}

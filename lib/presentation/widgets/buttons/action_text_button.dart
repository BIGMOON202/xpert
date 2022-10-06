import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/presentation/widgets/buttons/action_button.dart';

class ActionTextButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isSelected;
  final bool isBordered;
  const ActionTextButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.isEnabled: true,
    this.isSelected: true,
    this.isBordered: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      child: CustomText.withColor(
        title.toUpperCase(),
        isEnabled ? Colors.white : SessionParameters().disableTextColor,
      ),
      isEnabled: isEnabled,
      isSelected: isSelected,
      isBordered: isBordered,
      onPressed: onPressed,
    );
  }
}

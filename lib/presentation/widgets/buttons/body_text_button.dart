import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/presentation/widgets/buttons/action_button.dart';
import 'package:tdlook_flutter_app/application/themes/app_themes.dart';

class BodyTextButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isSelected;
  const BodyTextButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.isEnabled: true,
    this.isSelected: true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      child: Text(
        title,
        style: Theme.of(context)
            .appTheme
            .textStyle
            ?.textBoxTitle
            .copyWith(color: isEnabled ? Colors.white : SessionParameters().disableTextColor),
      ),
      isEnabled: isEnabled,
      isSelected: isSelected,
      height: 44,
      onPressed: onPressed,
    );
  }
}

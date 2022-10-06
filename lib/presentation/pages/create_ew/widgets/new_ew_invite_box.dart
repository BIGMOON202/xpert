part of '../new_ew_page.dart';

class InviteBox extends StatelessWidget {
  final Function(InviteType?) onSelectedType;
  final InviteType? selectedType;
  final List<InviteType> enabledTypes;
  const InviteBox({
    Key? key,
    required this.onSelectedType,
    this.enabledTypes: const [InviteType.sms, InviteType.email],
    this.selectedType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.current.text_ew_send_invite_via,
          style: Theme.of(context).appTheme.textStyle?.textBoxTitle,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: BodyTextButton(
                title: S.current.common_sms,
                isEnabled: enabledTypes.contains(InviteType.sms),
                isSelected: selectedType == InviteType.sms,
                isBordered: true,
                onPressed: () => _selectItemType(InviteType.sms),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BodyTextButton(
                title: S.current.common_email,
                isEnabled: enabledTypes.contains(InviteType.email),
                isSelected: selectedType == InviteType.email,
                isBordered: true,
                onPressed: () => _selectItemType(InviteType.email),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _selectItemType(InviteType type) {
    if (selectedType == type) {
      onSelectedType(null);
      return;
    }
    onSelectedType(type);
  }
}

part of '../new_ew_page.dart';

class InviteBox extends StatelessWidget {
  final Function(List<InviteType>) onSelectedTypes;
  final InviteType? selectedType;
  final List<InviteType> enabledTypes;
  final List<InviteType> selectedTypes;
  const InviteBox({
    Key? key,
    required this.onSelectedTypes,
    this.selectedType,
    this.enabledTypes: const [InviteType.sms, InviteType.email],
    this.selectedTypes: const [],
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
                isSelected: selectedTypes.contains(InviteType.sms),
                onPressed: () => _selectItemType(InviteType.sms),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: BodyTextButton(
                title: S.current.common_email,
                isEnabled: enabledTypes.contains(InviteType.email),
                isSelected: selectedTypes.contains(InviteType.email),
                onPressed: () => _selectItemType(InviteType.email),
              ),
            ),
          ],
        )
        // Row(
        //   //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   //mainAxisSize: MainAxisSize.min,
        //   children: [
        // ActionTextButton(
        //   title: S.current.common_sms,
        //   isSelected: selectedType == InviteType.sms,
        //   onPressed: () => _selectItemType(InviteType.sms),
        // ),
        //     ActionTextButton(
        //       title: S.current.common_email,
        //       isSelected: selectedType == InviteType.email,
        //       onPressed: () => _selectItemType(InviteType.email),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  void _selectItemType(InviteType type) {
    var current = List.of(selectedTypes);
    if (current.contains(type)) {
      onSelectedTypes([]);
      return;
    }
    onSelectedTypes([type]);
  }
}

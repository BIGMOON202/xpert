part of '../new_ew_page.dart';

class _TextFieldBox extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  const _TextFieldBox({
    Key? key,
    required this.title,
    required this.controller,
    this.onChanged,
    this.inputFormatters,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).appTheme.textStyle?.textBoxTitle,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: CupertinoTextField(
            padding: EdgeInsets.symmetric(horizontal: 14),
            controller: controller,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            textAlignVertical: TextAlignVertical.center,
            style: Theme.of(context).appTheme.textStyle?.textFieldText,
            onChanged: onChanged,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6)), color: Colors.white10),
          ),
        ),
      ],
    );
  }
}

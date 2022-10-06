part of '../new_ew_page.dart';

class _TextFieldBox extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool isEnabled;
  final String? errorMessage;

  const _TextFieldBox({
    Key? key,
    required this.title,
    required this.controller,
    this.onChanged,
    this.inputFormatters,
    this.keyboardType,
    required this.isEnabled,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        color: Colors.white10,
        border: Border.all(
          color: errorMessage?.isNotEmpty == true ? AppColors.error : Colors.transparent,
        ));

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
        Container(
          height: 44,
          decoration: decoration,
          child: CupertinoTextField(
            maxLines: 1,
            padding: EdgeInsets.symmetric(horizontal: 14),
            controller: controller,
            enableInteractiveSelection: isEnabled,
            readOnly: !isEnabled,
            autocorrect: false,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            textAlignVertical: TextAlignVertical.center,
            style: Theme.of(context).appTheme.textStyle?.textFieldText,
            onChanged: onChanged,
            decoration: decoration.copyWith(
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.transparent,
                )),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            errorMessage ?? '',
            maxLines: 3,
            style: Theme.of(context).appTheme.textStyle?.error,
          ),
        ),
      ],
    );
  }
}

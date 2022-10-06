part of '../new_ew_page.dart';

class ErrorBox extends StatelessWidget {
  final String? error;
  const ErrorBox({
    Key? key,
    this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: error?.isNotEmpty == true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          ResourceImage.imageWithName('ic_error.png'),
          SizedBox(
            height: 10,
          ),
          Text(
            error ?? '',
            style: Theme.of(context).appTheme.textStyle?.error.copyWith(
                  fontSize: 14,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

part of '../new_ew_page.dart';

class _SuccessBox extends StatelessWidget {
  final VoidCallback onFinishPressed;
  const _SuccessBox({
    Key? key,
    required this.onFinishPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            S.current.text_ew_invite_sent,
            style: Theme.of(context).appTheme.textStyle?.caption.copyWith(
                  color: AppColors.darkCaptionText,
                ),
          ),
          const SizedBox(height: 54),
          Image.asset(
            Assets.images.circleSuccess,
            fit: BoxFit.none,
          ),
          const SizedBox(height: 52),
          Text(
            S.current.text_ew_invite_sent_desc,
            style: Theme.of(context).appTheme.textStyle?.boldBody,
            textAlign: TextAlign.center,
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: ActionTextButton(
              title: S.current.button_back_to_event_detail,
              onPressed: onFinishPressed,
            ),
          )
        ],
      ),
    );
  }
}

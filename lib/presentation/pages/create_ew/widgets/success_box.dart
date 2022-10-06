part of '../new_ew_page.dart';

class _SuccessBox extends StatelessWidget {
  final InviteType? inviteType;
  final VoidCallback onFinishPressed;
  const _SuccessBox({
    Key? key,
    this.inviteType,
    required this.onFinishPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            S.current.common_success,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              S.current.text_ew_invite_sent_desc,
              style: Theme.of(context).appTheme.textStyle?.boldBody,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 44),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              _successInviteMessage(),
              style: Theme.of(context).appTheme.textStyle?.boldBody,
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: ActionTextButton(
              title: S.current.button_back_to_event_detail,
              onPressed: onFinishPressed,
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  String _successInviteMessage() {
    switch (inviteType) {
      case InviteType.sms:
        return S.current.text_ew_invite_sent_via_sms_desc;
      case InviteType.email:
        return S.current.text_ew_invite_sent_via_email_desc;
      default:
        return '';
    }
  }
}

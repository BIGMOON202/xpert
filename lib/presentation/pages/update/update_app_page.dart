import 'package:flutter/material.dart';
import 'package:open_store/open_store.dart';
import 'package:tdlook_flutter_app/application/assets/assets.dart';
import 'package:tdlook_flutter_app/application/config/app_env.dart';
import 'package:tdlook_flutter_app/application/themes/app_colors.dart';
import 'package:tdlook_flutter_app/application/themes/app_themes.dart';
import 'package:tdlook_flutter_app/generated/l10n.dart';
import 'package:tdlook_flutter_app/presentation/widgets/buttons/action_text_button.dart';
import 'package:tdlook_flutter_app/presentation/widgets/loader/loader_box.dart';

class UpdateAppPage extends StatelessWidget {
  final String storeVersion;
  const UpdateAppPage({
    Key? key,
    required this.storeVersion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoaderBox(
        isLoading: false,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final textStyle = Theme.of(context).appTheme.textStyle;
    final lightBodyTextStyle = textStyle?.s12w500;
    final darkBodyTextStyle = lightBodyTextStyle?.copyWith(
      color: AppColors.darkCaptionText,
    );
    return SafeArea(
      top: true,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 44),
            Image.asset(
              Assets.images.logoXpertfit,
              fit: BoxFit.none,
            ),
            Spacer(),
            Text(
              S.current.text_available_updates,
              style: textStyle?.s30w700,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: darkBodyTextStyle,
                  children: <TextSpan>[
                    TextSpan(
                      text: S.current.text_update_text_span1,
                      style: darkBodyTextStyle,
                    ),
                    TextSpan(
                      text: S.current.text_update_text_span2,
                      style: lightBodyTextStyle,
                    ),
                    TextSpan(
                      text: S.current.text_update_text_span3,
                      style: darkBodyTextStyle,
                    ),
                    TextSpan(
                      text: S.current.text_update_text_span4,
                      style: lightBodyTextStyle,
                    ),
                    TextSpan(
                      text: S.current.text_update_text_span5,
                      style: darkBodyTextStyle,
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Text(
              S.current.common_store_version_num(storeVersion),
              style: textStyle?.s12w500.copyWith(
                color: AppColors.darkCaptionText,
              ),
            ),
            SizedBox(height: 16),
            LightActionTextButton(
              title: S.current.common_update,
              isEnabled: true,
              isBordered: true,
              onPressed: () {
                _update();
              },
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _update() {
    OpenStore.instance.open(
      androidAppBundleId: AppEnv.googleStoreLink,
      appStoreId: AppEnv.appleStoreLink,
    );
  }
}

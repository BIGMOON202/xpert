import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/AuthCredentials.dart';
import 'package:tdlook_flutter_app/Screens/EventsPage.dart';
import 'package:tdlook_flutter_app/Screens/TutorialPage.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tdlook_flutter_app/constants/global.dart';
import 'package:tdlook_flutter_app/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatefulWidget {
  final UserType? userType;
  final AuthCredentials? credentials;
  final bool? showApply;

  const PrivacyPolicyPage({
    Key? key,
    this.credentials,
    this.userType,
    this.showApply = true,
  }) : super(key: key);

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String get colorStr {
    var color = Colors.black;
    return '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
  }

  bool _isApplied = false;
  String? privacyURL;

  Future<void> _launchInBrowser(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      logger.e('Could not launch $url');
      logger.e(e);
    }
  }

  void _moveToNextPage() {
    if (_isApplied == true) {
      logger.i('need to write');
      Future<void> writeToken() async {
        logger.i('start write');
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('refresh', widget.credentials?.refresh ?? ''); // for string value
        prefs.setString('access', widget.credentials?.access ?? ''); // for string value
        prefs.setString('userType', EnumToString.convertToString(widget.userType));
        prefs.setBool('agreement', true);

        logger.d('USER= ${EnumToString.convertToString(widget.userType)}');

        if (widget.userType == UserType.salesRep) {
          Navigator.pushNamedAndRemoveUntil(context, '/events_list', (route) => false);
        } else {
          if (kCompanyTypeArmorOnly) {
            _moveToEventsAsArmorCompany();
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/choose_company', (route) => false);
          }
        }

        if (prefs.getBool('intro_seen') != true) {
          Navigator.push(
            context,
            MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return TutorialPage();
              },
              fullscreenDialog: true,
            ),
          );
        }
      }

      writeToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: HexColor.fromHex('898A9D'),
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          //children align to center.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 56),
                child: Container(
                  child: Text(
                    S.current.page_title_terms_and_privacy,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                  ),
                ),
              ),
            )
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 24,
                    bottom: 12,
                  ),
                  child: Text.rich(
                    TextSpan(
                      style: bodyTextStyle,
                      children: <InlineSpan>[
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Text(
                              S.current.text_privacy_notice_span1,
                              style: bodyTextStyle,
                            ),
                          ),
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Text(
                              S.current.text_privacy_notice_span2,
                              style: bodyTextStyle,
                            ),
                          ),
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Text.rich(
                              TextSpan(
                                text: S.current.text_privacy_notice_span3,
                                style: bodyTextStyle,
                                children: [
                                  TextSpan(
                                    text: S.current.privacy_policy,
                                    style: bodyTextStyle.copyWith(
                                      decoration: TextDecoration.underline,
                                      color: Colors.white,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _launchInBrowser(kPrivacyPolicyLink),
                                  ),
                                  TextSpan(
                                    text: ' ${S.current.common_and.toLowerCase()} ',
                                    style: bodyTextStyle,
                                  ),
                                  TextSpan(
                                    text: S.current.terms_of_use + '.',
                                    style: bodyTextStyle.copyWith(
                                      decoration: TextDecoration.underline,
                                      color: Colors.white,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => _launchInBrowser(kTermsOfUseLink),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.showApply == true)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Theme(
                        data: ThemeData(unselectedWidgetColor: Colors.white),
                        child: Checkbox(
                          onChanged: (newValue) {
                            setState(() {
                              _isApplied = newValue ?? false;
                            });
                          },
                          activeColor: HexColor.fromHex('1E7AE4'),
                          checkColor: Colors.white,
                          hoverColor: Colors.orange,
                          value: _isApplied,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          S.current.text_accept_privacy_notice,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                        ),
                      )
                    ],
                  ),
                  _buildNextButton()
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          bottom: 12,
        ),
        child: Container(
          width: double.infinity,
          child: MaterialButton(
            splashColor: Colors.transparent,
            elevation: 0,
            onPressed: _isApplied == true ? _moveToNextPage : null,
            disabledColor: Colors.white.withOpacity(0.5),
            textColor: Colors.black,
            child: Text(
              S.current.common_continue.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            color: Colors.white,
            height: 50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }

  void _moveToEventsAsArmorCompany() {
    SessionParameters().selectedCompany = CompanyType.armor;
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (BuildContext context) => EventsPage(
          provider: CompanyType.armor.apiKey(),
        ),
      ),
    );
  }
}

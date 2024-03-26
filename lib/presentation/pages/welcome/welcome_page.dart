import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Screens/LoginPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/generated/l10n.dart';

class WelcomePage extends StatefulWidget {
  final String appVersion;
  final UserType userType;

  WelcomePage({
    required this.userType,
    required this.appVersion,
  });

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  // static Color _selectedColor = Colors.white.withOpacity(0.1);
  late bool _continueButtonEnable;

  UserType? get _selectedUserType => widget.userType;
  String get _appVersion => widget.appVersion;

  @override
  void initState() {
    _continueButtonEnable = false;
    super.initState();
    _runContinueButtonTimer();
  }

  Future<void> _enableContinueTimer() async {
    await Future.delayed(Duration(seconds: SessionParameters().delayForPageAction));
  }

  void _runContinueButtonTimer() {
    _enableContinueTimer().then((_) {
      setState(() {
        _continueButtonEnable = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [_buildFooter(), _buildHeader()],
    );
  }

  Widget _buildHeader() {
    return Container(
        child: SafeArea(
      child: FractionallySizedBox(
        alignment: Alignment.topCenter,
        heightFactor: 1.0,
        child: Column(
          children: [
            SizedBox(
              child: ResourceImage.imageWithName("expertfit_logo.png"),
              width: 171,
              height: 40,
            ),
            SizedBox(height: 30),
            Text(
              S.current.text_welcome_title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                S.current.text_welcome_header,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildFooter() {
    return FractionallySizedBox(
      alignment: Alignment.bottomCenter,
      heightFactor: 0.6,
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
              color: HexColor.fromHex("#16181B")),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  S.current.text_welcome_footer,
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Spacer(),
            ],
          ),
        ),
        _buildContinueButton(),
      ]),
    );
  }

  Widget _buildContinueButton() {
    return Visibility(
      visible: true,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildAppVersion(),
                  SizedBox(height: 16),
                  MaterialButton(
                    splashColor: Colors.transparent,
                    elevation: 0,
                    textTheme: ButtonTextTheme.accent,
                    onPressed: _continueButtonEnable ? _moveToNextPage : null,
                    textColor: Colors.black,
                    disabledColor: Colors.white.withOpacity(0.5),
                    child: Text(
                      S.current.common_continue.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    color: Colors.white,
                    height: 50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Text(
      _appVersion,
      style: TextStyle(color: HexColor.fromHex('898A9D'), fontSize: 12),
      textAlign: TextAlign.center,
    );
  }

  void _moveToNextPage() {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (BuildContext context) => LoginPage(userType: _selectedUserType),
      ),
    );
  }
}

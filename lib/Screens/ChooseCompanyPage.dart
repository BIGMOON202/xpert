import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Screens/EventsPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';

class ChooseCompanyPage extends StatefulWidget {
  @override
  _ChooseCompanyPageState createState() => _ChooseCompanyPageState();
}

class _ChooseCompanyPageState extends State<ChooseCompanyPage> {
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  static Color _selectedColor = Colors.white.withOpacity(0.1);

  CompanyType? _selectedCompanyType;

  void _selectUserType(int atIndex) {
    setState(() {
      _selectedCompanyType = atIndex == 0 ? CompanyType.uniforms : CompanyType.armor;
    });
  }

  @override
  Widget build(BuildContext context) {
    var titleText = Padding(
      padding: EdgeInsets.only(top: 30, left: 40, right: 40, bottom: 10),
      child: Text(
        'What is your XpertFit type?',
        style: TextStyle(
            color: SessionParameters().mainFontColor, fontWeight: FontWeight.bold, fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );

    var buttonsContainer = Align(
        alignment: Alignment.topCenter,
        child: Container(
          // height: 156,
          color: _backgroundColor,
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 50),
          child: SafeArea(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: MaterialButton(
                        splashColor: Colors.transparent,
                        elevation: 0,
                        onPressed: () {
                          _selectUserType(0);
                        },
                        color: _selectedCompanyType == CompanyType.uniforms
                            ? _selectedColor
                            : _backgroundColor,
                        highlightColor: Colors.grey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AspectRatio(aspectRatio: 10),
                            AspectRatio(
                                aspectRatio: 2.5,
                                child: ResourceImage.imageWithName(
                                    _selectedCompanyType == CompanyType.uniforms
                                        ? CompanyType.uniforms.selectedImageName()
                                        : CompanyType.uniforms.unselectedImageName())),
                            AspectRatio(aspectRatio: 10),
                            Text(
                              'Uniforms',
                              style: TextStyle(color: Colors.white),
                            ),
                            AspectRatio(aspectRatio: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: MaterialButton(
                      splashColor: Colors.transparent,
                      elevation: 0,
                      onPressed: () {
                        _selectUserType(1);
                      },
                      color: _selectedCompanyType == CompanyType.armor
                          ? _selectedColor
                          : _backgroundColor,
                      highlightColor: Colors.grey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AspectRatio(aspectRatio: 10),
                          AspectRatio(
                              aspectRatio: 2.5,
                              child: ResourceImage.imageWithName(
                                  _selectedCompanyType == CompanyType.armor
                                      ? CompanyType.armor.selectedImageName()
                                      : CompanyType.armor.unselectedImageName())),
                          AspectRatio(aspectRatio: 10),
                          Text(
                            'Armor',
                            style: TextStyle(color: Colors.white),
                          ),
                          AspectRatio(aspectRatio: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AspectRatio(aspectRatio: 30),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      child: AspectRatio(
                          aspectRatio: 3,
                          child: ResourceImage.imageWithName('ic_flyingCross.png'))),
                  Flexible(
                      child: AspectRatio(
                          aspectRatio: 13, child: ResourceImage.imageWithName('ic_sl.png')))
                ],
              )
            ]),
          ),
        ));

    void _moveToNextPage() {
      SessionParameters().selectedCompany = _selectedCompanyType;

      logger.d('selectedCompany:${SessionParameters().selectedCompany}');
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (BuildContext context) => EventsPage(
                    provider: _selectedCompanyType?.apiKey(),
                  )
              // EventsPage()
              ));
    }

    var nextButton = Visibility(
        visible: true,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: SafeArea(
                  child: Container(
                      width: double.infinity,
                      child: MaterialButton(
                        splashColor: Colors.transparent,
                        elevation: 0,
                        textTheme: ButtonTextTheme.accent,
                        onPressed: _selectedCompanyType != null
                            ? () {
                                _moveToNextPage();
                                logger.i('next button pressed');
                              }
                            : null,
                        textColor: Colors.black,
                        disabledColor: Colors.white.withOpacity(0.5),
                        child: Text(
                          'PROCEED',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        color: Colors.white,
                        height: 50,
                        // padding: EdgeInsets.only(left: 12, right: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        // padding: EdgeInsets.all(4),
                      )),
                ))));

    var bottomPart = new FractionallySizedBox(
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
              children: [titleText, buttonsContainer],
            ),
          ),
          nextButton
        ]));

    var topPart = new Container(
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
            Padding(
                padding: EdgeInsets.all(50),
                child: Text(
                  'Take the guesswork out of fitting and do it all in the convenience of your home. XpertFit virtual sizing '
                  'technology is accurate and fast.',
                  style: TextStyle(color: HexColor.fromHex('898A9D')),
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),
    ));

    var container = Container(
      color: Colors.black,
      child: bottomPart,
    );

    var stack = Stack(
      alignment: Alignment.bottomCenter,
      children: [container, topPart],
    );

    var scaffold = Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: stack,
    );

    return scaffold;
  }
}

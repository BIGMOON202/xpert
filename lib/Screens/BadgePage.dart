import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/ChooseGenderPage.dart';

class BadgePageArguments {
  MeasurementResults? measurement;
  UserType? userType;
  BadgePageArguments(this.measurement, this.userType);
}

class BadgePage extends StatefulWidget {
  static var route = '/badge';
  final BadgePageArguments? arguments;
  BadgePage({Key? key, this.arguments}) : super(key: key);

  @override
  _BadgePageState createState() => _BadgePageState();
}

class _BadgePageState extends State<BadgePage> {
  String _enteredbadge = '';
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;

  void _moveToNextScreen() {
    widget.arguments?.measurement?.badgeId = _enteredbadge;
    // widget.arguments.measurement
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) => ChooseGenderPage(
                argument: ChooseGenderPageArguments(widget.arguments?.measurement))));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    String? _validateBadge(String? value) {
      return null;
    }

    bool _continueIsEnabled() {
      return _enteredbadge != null && _enteredbadge.isNotEmpty;
    }

    var nextButton = Visibility(
        visible: true,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                  padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: Container(
                      width: double.infinity,
                      child: MaterialButton(
                        splashColor: Colors.transparent,
                        elevation: 0,
                        onPressed: _continueIsEnabled() ? _moveToNextScreen : null,
                        disabledColor: SessionParameters().disableColor,
                        child: CustomText.withColor(
                            'CONTINUE',
                            _continueIsEnabled()
                                ? Colors.white
                                : SessionParameters().disableTextColor),
                        color: SessionParameters().selectionColor,
                        height: 50,
                        // padding: EdgeInsets.only(left: 12, right: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        // padding: EdgeInsets.all(4),
                      ))),
            )));

    var container = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(top: 30, left: 12, right: 12),
                child: Stack(alignment: Alignment.topCenter, children: [
                  SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Badge ID',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                          child: TextFormField(
                        enabled: true,
                        onChanged: (String value) {
                          setState(() {
                            _enteredbadge = value;
                          });
                        },
                        maxLength: 30,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        validator: (value) => _validateBadge(value),
                        textCapitalization: TextCapitalization.none,
                        initialValue: _enteredbadge,
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                borderSide: BorderSide(width: 1, color: Colors.transparent)),
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                            hintText: 'Badge ID',
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 1, color: Colors.transparent),
                                borderRadius: BorderRadius.all(Radius.circular(6))),
                            filled: true,
                            hoverColor: Colors.brown,
                            fillColor: Colors.white.withOpacity(0.1)),
                      )),
                    ],
                  ))
                ]))),
        nextButton
      ],
    );

    var scaffold = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.arguments?.userType == UserType.endWearer
            ? 'Your Badge ID'
            : 'End-wearer\'s Badge ID'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          container,
        ],
      ),
    );

    return scaffold;
  }
}

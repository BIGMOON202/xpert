import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/CameraCapturePage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';

class SoundCheckPage extends StatefulWidget {
  static var route = '/sound_check';
  final PhotoType? photoType;
  final Gender? gender;
  final MeasurementResults? measurement;

  SoundCheckPage({
    Key? key,
    this.photoType,
    this.gender,
    this.measurement,
  }) : super(key: key);

  @override
  _SoundCheckPageState createState() => _SoundCheckPageState();
}

class _SoundCheckPageState extends State<SoundCheckPage> {
  bool _continueButtonEnable = false;

  Future<bool> _enableContinueTimer() async {
    final result = await Future.delayed(Duration(seconds: SessionParameters().delayForPageAction));
    return result;
  }

  void _runContinueButtonTimer() {
    _enableContinueTimer().then((value) {
      setState(() {
        _continueButtonEnable = true;
      });
    });
  }

  void _moveToNextPage() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) => CameraCapturePage(
                photoType: widget.photoType,
                measurement: widget.measurement,
                gender: widget.gender)));
  }

  @override
  void initState() {
    super.initState();

    _runContinueButtonTimer();
  }

  @override
  Widget build(BuildContext context) {
    var icon = SizedBox(
      width: 112,
      height: 192,
      child: ResourceImage.imageWithName('ic_sound_on.png'),
    );

    var centerWidget = Center(
        child: SafeArea(
            child: Padding(
      padding: EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(height: 50),
          Text(
              'Please check the sound on your phone.\nTo use voice instructions, it must be turned on.',
              maxLines: 4,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: SessionParameters().mainFontColor,
                  fontWeight: FontWeight.normal,
                  fontSize: 14))
        ],
      ),
    )));

    var nextButton = Visibility(
        visible: true,
        child: Padding(
            padding: EdgeInsets.only(left: 12, right: 12),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                      padding: EdgeInsets.only(left: 12, right: 12),
                      child: Container(
                          width: double.infinity,
                          child: MaterialButton(
                            disabledColor: SessionParameters().disableColor,
                            onPressed: _continueButtonEnable ? _moveToNextPage : null,
                            child: CustomText.withColor(
                                'DONE',
                                _continueButtonEnable
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
                ))));

    var container = Stack(
      children: [centerWidget, nextButton],
    );

    var scaffold = Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        title: Text('Soundcheck'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: SessionParameters().mainBackgroundColor,
      body: container,
    );

    return scaffold;
  }
}

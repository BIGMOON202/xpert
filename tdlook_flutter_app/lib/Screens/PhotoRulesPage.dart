import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/SoundCheckPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Screens/CameraCapturePage.dart';

class PhotoRulesPage extends StatefulWidget {
  final XFile frontPhoto;
  final PhotoType photoType;
  final Gender gender;
  final MeasurementResults measurement;
  final CameraCapturePageArguments arguments;
  const PhotoRulesPage(
      {Key key,
      this.photoType,
      this.gender,
      this.measurement,
      this.frontPhoto,
      this.arguments})
      : super(key: key);

  @override
  _PhotoRulesPageState createState() => _PhotoRulesPageState();
}

class _PhotoRulesPageState extends State<PhotoRulesPage> {
  bool _continueButtonEnable = false;

  void _moveToNextPage() {
    if (SessionParameters().captureMode == CaptureMode.handsFree) {
      if (widget.photoType == PhotoType.front) {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => PhotoRulesPage(
                    photoType: PhotoType.side,
                    gender: widget.gender,
                    measurement: widget.measurement)));
      } else {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => SoundCheckPage(
                    photoType: PhotoType.front,
                    measurement: widget.measurement,
                    gender: widget.gender)));
      }
    } else {
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (BuildContext context) => CameraCapturePage(
                  photoType: widget.photoType,
                  measurement: widget.measurement,
                  frontPhoto: widget.frontPhoto,
                  gender: widget.gender,
                  arguments: widget.arguments)));
    }
  }

  Future<bool> _enableContinueTimer() async {
    await Future.delayed(
        Duration(seconds: SessionParameters().delayForPageAction));
  }

  void _runContinueButtonTimer() {
    _enableContinueTimer().then((value) {
      setState(() {
        _continueButtonEnable = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _runContinueButtonTimer();

    print('selectedGender: ${widget.gender.apiFlag()}');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    String _nextButtonTitle = 'Let\'s start';
    if (SessionParameters().captureMode == CaptureMode.handsFree &&
        widget.photoType == PhotoType.front) {
      _nextButtonTitle = 'next';
    }

    var nextButton = Visibility(
        visible: true,
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
                padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: SafeArea(
                  child: Container(
                      width: double.infinity,
                      child: MaterialButton(
                        disabledColor:
                            SessionParameters().disableColor,
                        onPressed:
                            _continueButtonEnable ? _moveToNextPage : null,
                        child: CustomText.withColor(_nextButtonTitle.toUpperCase(), _continueButtonEnable ? Colors.white : SessionParameters().disableTextColor),
                        color: SessionParameters().selectionColor,
                        height: 50,
                        // padding: EdgeInsets.only(left: 12, right: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        // padding: EdgeInsets.all(4),
                      )),
                ))));

    print('selectedGender: ${widget.gender.toString()}');

    var container = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
    //     Expanded(child: Container(child: Padding(
    //   padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 40),
    // child: Center(child: Container(width: 20, height: 20, color: Colors.orange,),)),)),
        Expanded(child: Container(child: Padding(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
            child: ResourceImage.imageWithName(widget.photoType
                .rulesImageNameFor(
                gender: widget.gender,
                captureMode: SessionParameters().captureMode))))),
        nextButton,
      ],
    );

    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          centerTitle: true,
          title: Text('Take a ${widget.photoType.name()} photo'),
          backgroundColor: SessionParameters().mainBackgroundColor,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: SessionParameters().mainBackgroundColor,
        body: container);
  }
}

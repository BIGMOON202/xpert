import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Screens/CameraCapturePage.dart';

class PhotoRulesPage extends StatefulWidget {

  final PhotoType photoType;
  final Gender gender;
  final MeasurementResults measurement;
  const PhotoRulesPage ({ Key key, this.photoType, this.gender, this.measurement}): super(key: key);


  @override
  _PhotoRulesPageState createState() => _PhotoRulesPageState();
}

class _PhotoRulesPageState extends State<PhotoRulesPage> {

  bool _continueButtonEnable = false;

  void _moveToNextPage() {
    Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
    // RulerPageWeight(),
      CameraCapturePage(photoType: widget.photoType, measurement: widget.measurement)
    ));
  }

  Future<bool> _enableContinueTimer() async {
    await Future.delayed(Duration(seconds: 3));
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

    _runContinueButtonTimer();

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build


    var nextButton = Visibility(

        visible: true,
        child:Align(
            alignment: Alignment.bottomCenter,
            child:SafeArea(child: Container(
                width: double.infinity,
                child: MaterialButton(
                  disabledColor: SharedParameters().selectionColor.withOpacity(0.5),
                  onPressed: _continueButtonEnable ? _moveToNextPage : null,
                  textColor: Colors.white,
                  child: CustomText('let\'s start'.toUpperCase()),
                  color: SharedParameters().selectionColor,
                  height: 50,
                  // padding: EdgeInsets.only(left: 12, right: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  // padding: EdgeInsets.all(4),
                )),
            )));

    var container = Stack(
      children: [
        Padding(padding: EdgeInsets.only(top: 70, left: 20, right: 20),
        child: ResourceImage.imageWithName(widget.photoType.rulesImageNameFor(gender:widget.gender))
        ),
        SizedBox(height: 50),
        nextButton,
      ],
    );

    return Scaffold(
        appBar: AppBar(
          title: Text('How to take photos'),
          backgroundColor: SharedParameters().mainBackgroundColor,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: SharedParameters().mainBackgroundColor,
        body: container);

  }
}
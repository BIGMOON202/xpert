
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/ChooseCaptureModePage.dart';
import 'package:tdlook_flutter_app/Screens/HowTakePhotoPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';

enum WaistLevel {
  high, mid, low
}
extension WaistLevelExtension on WaistLevel {
  String get apiFlag {
    switch (this) {
      case WaistLevel.high: return 'high';
      case WaistLevel.mid:  return 'mid';
      case WaistLevel.low: return 'low';
    }
  }

  String get imageName {
    switch (this) {
      case WaistLevel.high: return 'high_waist.png';
      case WaistLevel.mid:  return 'mid_waist.png';
      case WaistLevel.low: return 'low_waist.png';
    }
  }
  String get title {
    switch (this) {
      case WaistLevel.high: return 'At the waist level';
      case WaistLevel.mid:  return 'Slightly below the waist level';
      case WaistLevel.low: return 'Well below waist level';
    }
  }

  int get indexTitle {
    switch (this) {
      case WaistLevel.high: return 1;
      case WaistLevel.mid:  return 2;
      case WaistLevel.low: return 3;
    }
  }
}

class WaistLevelPage extends StatefulWidget {
  final Gender gender;
  final MeasurementSystem selectedMeasurementSystem;
  final MeasurementResults measurements;

  const WaistLevelPage ({ Key key, this.gender , this.selectedMeasurementSystem, this.measurements}): super(key: key);

  @override
  _WaistLevelPageState createState() => _WaistLevelPageState();
}

class _WaistLevelPageState extends State<WaistLevelPage> {


  WaistLevel selectedLevel = WaistLevel.high;
  void _moveToNextPage() {

    widget.measurements.waistLevel = selectedLevel.apiFlag;

    if (SessionParameters().selectedUser == UserType.endWearer) {

      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
          ChooseCaptureModePage(argument: ChooseCaptureModePageArguments(gender: widget.gender, measurement: widget.measurements))
      ));

    } else {
      SessionParameters().captureMode = CaptureMode.withFriend;
      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
          HowTakePhotoPage(gender: widget.gender, measurements: widget.measurements)
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget waistOptionWidget({WaistLevel level}) {
      return GestureDetector(
        onTap:  () {
          setState(() {
            this.selectedLevel = level;
          });
        },
          child: Container(decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.white.withOpacity(0.1)),
      child: Padding(padding: EdgeInsets.only(top: 13, bottom: 13, left: 20, right: 20),
          child: Row(children: [
            AspectRatio(aspectRatio: 1, child: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.1),
              child: Text('${level.indexTitle}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SessionParameters().mainFontColor)))),
          SizedBox(width: 14),
          Expanded(child: Text(level.title, maxLines: 2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SessionParameters().mainFontColor),)),
            SizedBox(width: 14),
          Radio(value: level.index, groupValue: this.selectedLevel.index, onChanged: (int newVal) {
            setState(() {
              this.selectedLevel = WaistLevel.values[newVal];
            });
          })],))));
    }
    
    var image = Padding(padding: EdgeInsets.all(23), child: ResourceImage.imageWithName(this.selectedLevel.imageName));

    var middleText = Text('Please determine what best describes  how you wear your trousers?',
        style: TextStyle(color: SessionParameters().mainFontColor, fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center,);
      var optionsWidget = Padding(padding: EdgeInsets.only(
          top:40,
          bottom: 40,
          left: 30,
          right: 30),
      child: Column(children: [
      Expanded(child: waistOptionWidget(level: WaistLevel.high)),
      SizedBox(height: 10),
      Expanded(child: waistOptionWidget(level: WaistLevel.mid)),
      SizedBox(height: 10),
      Expanded(child: waistOptionWidget(level: WaistLevel.low)),
    ]));


    var container = Column(
      children: [
        Expanded(child: image),
        Expanded(child: Column(children: [middleText, Expanded(child: optionsWidget)])),
        Padding(
            padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: SafeArea(
              child: Container(
                  width: double.infinity,
                  child: MaterialButton(
                    disabledColor:
                    SessionParameters().selectionColor.withOpacity(0.5),
                    onPressed:
                    _moveToNextPage,
                    textColor: Colors.white,
                    child: CustomText('NEXT'),
                    color: SessionParameters().selectionColor,
                    height: 50,
                    // padding: EdgeInsets.only(left: 12, right: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    // padding: EdgeInsets.all(4),
                  )),
            ))
      ],
    );
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          centerTitle: true,
          title: Text(SessionParameters().selectedUser == UserType.endWearer ? 'Waist level preference' : 'End wearer’s waist level preference', textAlign: TextAlign.center),
          backgroundColor: SessionParameters().mainBackgroundColor,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: SessionParameters().mainBackgroundColor,
        body: container);
  }
}


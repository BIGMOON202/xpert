
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/ChooseCaptureModePage.dart';
import 'package:tdlook_flutter_app/Screens/HowTakePhotoPage.dart';
import 'package:tdlook_flutter_app/Screens/PrefferedFitPage.dart';
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

  String imageName({Gender gender}) {
    switch (this) {
      case WaistLevel.high: return gender == Gender.male ? 'high_waist.png' : 'high_waist_female.png';
      case WaistLevel.mid:  return gender == Gender.male ? 'mid_waist.png' : 'mid_waist_female.png';
      case WaistLevel.low: return gender == Gender.male ? 'low_waist.png' : 'low_waist_female.png';
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


  WaistLevel selectedLevel;
  void _moveToNextPage() {

    widget.measurements.waistLevel = selectedLevel.apiFlag;
    if (SessionParameters().selectedCompany == CompanyType.uniforms) {
      Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) => PrefferedFitPage(
              gender: widget.gender,
              selectedMeasurementSystem: widget.selectedMeasurementSystem,
              measurements: widget.measurements,
            ),
          ));
    } else {
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
      child: Padding(padding: EdgeInsets.only(top: 13, bottom: 13, left: 20, right: 0),
          child: Row(children: [
          //   AspectRatio(aspectRatio: 1, child: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.1),
          //     child: Text('${level.indexTitle}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SessionParameters().mainFontColor)))),
          // SizedBox(width: 14),
          Expanded(child: Text(level.title, maxLines: 2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SessionParameters().mainFontColor),)),
            SizedBox(width: 14),
          Radio(value: level.index, groupValue: this.selectedLevel?.index ?? -1, onChanged: (int newVal) {
            setState(() {
              this.selectedLevel = WaistLevel.values[newVal];
            });
          })],))));
    }

    Widget imageOptionWidget({WaistLevel level}) {
      return GestureDetector(
          onTap:  () {
            setState(() {
              this.selectedLevel = level;
            });
          },
          child: Container(decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: this.selectedLevel == level ? Colors.white.withOpacity(0.1) : Colors.transparent) ,
              child: Padding(padding: EdgeInsets.only(top: 13, bottom: 13, left: 12, right: 12),
                  child: ResourceImage.imageWithName(level.imageName(gender: this.widget.gender)))));
    }
    var questionText = SessionParameters().selectedUser == UserType.endWearer ? 'Where do you wear your uniform pants?' : 'Where does the end-wearer wear uniform pants?';
    var middleText = Text(questionText,
        style: TextStyle(color: SessionParameters().mainFontColor, fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center,);
      var optionsWidget = Padding(padding: EdgeInsets.only(
          top:40,
          bottom: 40,
          left: 30,
          right: 30),
      child: Column(children: [
        SizedBox(height: 50, child: waistOptionWidget(level: WaistLevel.high)),
      SizedBox(height: 10),
        SizedBox(height: 50, child: waistOptionWidget(level: WaistLevel.mid)),
      SizedBox(height: 10),
        SizedBox(height: 50, child: waistOptionWidget(level: WaistLevel.low)),
    ]));


    var container = Column(
      children: [
        Expanded(child: Padding(padding: EdgeInsets.only(left: 30, right: 30, bottom: 30, top: 30),
        child: Row(children: [
          Expanded(child: imageOptionWidget(level: WaistLevel.high)),
          Expanded(child: imageOptionWidget(level: WaistLevel.mid)),
          Expanded(child: imageOptionWidget(level: WaistLevel.low)),
        ],))),
        Column(children: [middleText, optionsWidget]),
        Padding(
            padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: SafeArea(
              child: Container(
                  width: double.infinity,
                  child: MaterialButton(
                    disabledColor:
                    SessionParameters().disableColor,
                    onPressed: selectedLevel != null ? _moveToNextPage : null,
                    child: CustomText.withColor('NEXT', selectedLevel != null ? Colors.white : SessionParameters().disableTextColor),
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
          title: Text('Waist Level Preference', textAlign: TextAlign.center),
          backgroundColor: SessionParameters().mainBackgroundColor,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: SessionParameters().mainBackgroundColor,
        body: container);
  }
}


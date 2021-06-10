
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

enum FitType {
  tight, loose
}
extension PrefferedFitExtension on FitType {
  String get apiFlag {
    switch (this) {
      case FitType.tight: return 'tight';
      case FitType.loose:  return 'loose';
    }
  }

  String get imageName {
    switch (this) {
      case FitType.tight: return 'tight_fit.png';
      case FitType.loose:  return 'loose_fit.png';
    }
  }
  String get title {
    switch (this) {
      case FitType.tight: return 'Closer-fitting';
      case FitType.loose:  return 'Looser-fitting';
  }}

  int get indexTitle {
    switch (this) {
      case FitType.tight: return 1;
      case FitType.loose:  return 2;
    }
  }
}

class PrefferedFitPage extends StatefulWidget {
  final Gender gender;
  final MeasurementSystem selectedMeasurementSystem;
  final MeasurementResults measurements;

  const PrefferedFitPage ({ Key key, this.gender , this.selectedMeasurementSystem, this.measurements}): super(key: key);

  @override
  _PrefferedFitPagePageState createState() => _PrefferedFitPagePageState();
}

class _PrefferedFitPagePageState extends State<PrefferedFitPage> {


  FitType selectedType;
  void _moveToNextPage() {

    widget.measurements.fitType = selectedType.apiFlag;

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

    Widget waistOptionWidget({FitType type}) {
      return GestureDetector(
          onTap:  () {
            setState(() {
              this.selectedType = type;
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
                    Expanded(child: Text(type.title, maxLines: 2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SessionParameters().mainFontColor),)),
                    SizedBox(width: 14),
                    Radio(value: type.index, groupValue: this.selectedType != null ? this.selectedType.index: -1, onChanged: (int newVal) {
                      setState(() {
                        this.selectedType = FitType.values[newVal];
                      });
                    })],))));
    }

    Widget imageOptionWidget({FitType type}) {
      return GestureDetector(
          onTap:  () {
            setState(() {
              this.selectedType = type;
            });
          },
          child: Container(decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color: this.selectedType == type ? Colors.white.withOpacity(0.1) : Colors.transparent) ,
              child: Padding(padding: EdgeInsets.only(top: 13, bottom: 13, left: 12, right: 12),
                  child: ResourceImage.imageWithName(type.imageName))));
    }

    var appealPhrase = SessionParameters().selectedUser == UserType.endWearer ? 'you' : 'the end-wearer';
    var questionText = '…would $appealPhrase prefer the  closer-fitting size or the looser-fitting size';
    var middleText = Padding(padding: EdgeInsets.only(left: 8, right: 8), child: Text(questionText,
      style: TextStyle(color: SessionParameters().mainFontColor, fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center));
    var optionsWidget = Padding(padding: EdgeInsets.only(
        top:40,
        bottom: 40,
        left: 30,
        right: 30),
        child: Column(children: [
          SizedBox(height: 50, child: waistOptionWidget(type: FitType.tight)),
          SizedBox(height: 10),
          SizedBox(height: 50, child: waistOptionWidget(type: FitType.loose))
        ]));


    var container = Column(
      children: [
        Expanded(child: Padding(padding: EdgeInsets.only(left: 30, right: 30, bottom: 30, top: 30),
            child: Row(children: [
              Expanded(child: imageOptionWidget(type: FitType.tight)),
              Expanded(child: imageOptionWidget(type: FitType.loose)),
            ],))),
        Expanded(child: Column(children: [middleText, optionsWidget])),
        Padding(
            padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: SafeArea(
              child: Container(
                  width: double.infinity,
                  child: MaterialButton(
                    disabledColor:
                    SessionParameters().selectionColor.withOpacity(0.5),
                    onPressed: selectedType != null ? _moveToNextPage : null,
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
          title: Text('If the app finds the end-wearer between sizes…', textAlign: TextAlign.left, maxLines: 2,),
          backgroundColor: SessionParameters().mainBackgroundColor,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: SessionParameters().mainBackgroundColor,
        body: container);
  }
}



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';

enum WaistLevel {
  high, mid, low
}
extension WaistLevel on WaistLevel {
  String get title {
    switch (this) {
      case WaistLevel.high: return 'At the waist level';
      case WaistLevel.mid:  return 'Slightly below the waist level';
      case WaistLevel.low: return 'Well below waist level';
    }
  }

  int get index {
    switch (this) {
      case WaistLevel.high: return 1;
      case WaistLevel.mid:  return 2;
      case WaistLevel.low: return 3;
    }
  }
}

class WaistLevelPage extends StatefulWidget {
  @override
  _WaistLevelPageState createState() => _WaistLevelPageState();
}

class _WaistLevelPageState extends State<WaistLevelPage> {

  void _moveToNextPage() {
    // if (SessionParameters().captureMode == CaptureMode.handsFree) {
    //   if (widget.photoType == PhotoType.front) {
    //     Navigator.push(
    //         context,
    //         CupertinoPageRoute(
    //             builder: (BuildContext context) => PhotoRulesPage(
    //                 photoType: PhotoType.side,
    //                 gender: widget.gender,
    //                 measurement: widget.measurement)));
    //   } else {
    //     Navigator.push(
    //         context,
    //         CupertinoPageRoute(
    //             builder: (BuildContext context) => SoundCheckPage(
    //                 photoType: PhotoType.front,
    //                 measurement: widget.measurement,
    //                 gender: widget.gender)));
    //   }
    // } else {
    //   Navigator.push(
    //       context,
    //       CupertinoPageRoute(
    //           builder: (BuildContext context) => CameraCapturePage(
    //               photoType: widget.photoType,
    //               measurement: widget.measurement,
    //               frontPhoto: widget.frontPhoto,
    //               gender: widget.gender,
    //               arguments: widget.arguments)));
    // }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget waistOptionWidget({WaistLevel level}) {
      return Container(decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.white.withOpacity(0.1)),
      child: Padding(padding: EdgeInsets.only(top: 13, bottom: 13, left: 20, right: 20), child: Container(color: Colors.pink)));
    }
    
    var image = Padding(padding: EdgeInsets.all(23), child: ResourceImage.imageWithName('high_waist.png'));

    var middleText = Text('Please determine what best describes  how you wear your trousers?',
        style: TextStyle(color: SessionParameters().mainFontColor, fontSize: 18), textAlign: TextAlign.center,);
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
            padding: EdgeInsets.only(left: 12, right: 12),
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
          centerTitle: true,
          title: Text('End wearer’s waist level  preference'),
          backgroundColor: SessionParameters().mainBackgroundColor,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: SessionParameters().mainBackgroundColor,
        body: container);
  }
}


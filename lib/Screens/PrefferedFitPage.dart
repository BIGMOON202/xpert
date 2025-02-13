import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/CameraCapturePage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseCaptureModePage.dart';
import 'package:tdlook_flutter_app/Screens/HowTakePhotoPage.dart';
import 'package:tdlook_flutter_app/Screens/QuestionaryPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';

enum FitType { tight, loose }

extension PrefferedFitExtension on FitType {
  String get apiFlag {
    switch (this) {
      case FitType.tight:
        return 'tight';
      case FitType.loose:
        return 'loose';
    }
  }

  String imageName({Gender? gender}) {
    switch (this) {
      case FitType.tight:
        return gender == Gender.male ? 'tight_fit.png' : 'tight_fit_female.png';
      case FitType.loose:
        return gender == Gender.male ? 'loose_fit.png' : 'loose_fit_female.png';
    }
  }

  String get title {
    switch (this) {
      case FitType.tight:
        return 'Closer-fitting';
      case FitType.loose:
        return 'Looser-fitting';
    }
  }

  int get indexTitle {
    switch (this) {
      case FitType.tight:
        return 1;
      case FitType.loose:
        return 2;
    }
  }
}

class PrefferedFitPage extends StatefulWidget {
  final Gender? gender;
  final MeasurementSystem? selectedMeasurementSystem;
  final MeasurementResults? measurements;

  const PrefferedFitPage({Key? key, this.gender, this.selectedMeasurementSystem, this.measurements})
      : super(key: key);

  @override
  _PrefferedFitPagePageState createState() => _PrefferedFitPagePageState();
}

class _PrefferedFitPagePageState extends State<PrefferedFitPage> {
  FitType? selectedType;
  void _moveToNextPage() {
    widget.measurements?.fitType = selectedType?.apiFlag;
    final selectedCompany = SessionParameters().selectedCompany;
    if (selectedCompany == null) return;

    switch (selectedCompany) {
      case CompanyType.uniforms:
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (BuildContext context) => QuestionaryPage(
                    gender: widget.gender,
                    measurement: widget.measurements,
                    selectedMeasurementSystem: widget.selectedMeasurementSystem)));
        break;

      case CompanyType.armor:
        if (SessionParameters().selectedUser == UserType.endWearer) {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (BuildContext context) => ChooseCaptureModePage(
                      argument: ChooseCaptureModePageArguments(
                          gender: widget.gender, measurement: widget.measurements))));
        } else {
          SessionParameters().captureMode = CaptureMode.withFriend;

          if (Application.isProMode) {
            Navigator.pushNamed(context, CameraCapturePage.route,
                arguments: CameraCapturePageArguments(
                    photoType: PhotoType.front,
                    measurement: widget.measurements,
                    frontPhoto: null,
                    sidePhoto: null));
          } else {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (BuildContext context) => HowTakePhotoPage(
                        gender: widget.gender, measurements: widget.measurements)));
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget waistOptionWidget({FitType? type}) {
      return GestureDetector(
          onTap: () {
            setState(() {
              this.selectedType = type;
            });
          },
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: Colors.white.withOpacity(0.1)),
              child: Padding(
                  padding: EdgeInsets.only(top: 13, bottom: 13, left: 20, right: 0),
                  child: Row(
                    children: [
                      //   AspectRatio(aspectRatio: 1, child: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.1),
                      //     child: Text('${level.indexTitle}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SessionParameters().mainFontColor)))),
                      // SizedBox(width: 14),
                      Expanded(
                          child: Text(
                        type?.title ?? '',
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: SessionParameters().mainFontColor),
                      )),
                      SizedBox(width: 14),
                      Radio(
                          value: type?.index ?? 0,
                          groupValue: this.selectedType != null ? this.selectedType?.index : -1,
                          onChanged: (newVal) {
                            setState(() {
                              this.selectedType = FitType.values[newVal as int];
                            });
                          })
                    ],
                  ))));
    }

    Widget imageOptionWidget({FitType? type}) {
      return GestureDetector(
        onTap: () {
          setState(() {
            this.selectedType = type;
          });
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              color:
                  this.selectedType == type ? Colors.white.withOpacity(0.1) : Colors.transparent),
          child: Padding(
            padding: EdgeInsets.only(top: 13, bottom: 13, left: 12, right: 12),
            child: ResourceImage.imageWithName(type?.imageName(gender: this.widget.gender)),
          ),
        ),
      );
    }

    var appealPhrase =
        SessionParameters().selectedUser == UserType.endWearer ? 'you' : 'the end-wearer';
    var questionText =
        '…would $appealPhrase prefer the  closer-fitting size or the looser-fitting size';
    var middleText = Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Text(questionText,
            style: TextStyle(
                color: SessionParameters().mainFontColor,
                fontSize: 18,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center));
    var optionsWidget = Padding(
        padding: EdgeInsets.only(top: 40, bottom: 40, left: 30, right: 30),
        child: Column(children: [
          SizedBox(height: 50, child: waistOptionWidget(type: FitType.tight)),
          SizedBox(height: 10),
          SizedBox(height: 50, child: waistOptionWidget(type: FitType.loose))
        ]));

    var container = Column(
      children: [
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 30, right: 30, bottom: 30, top: 30),
                child: Row(
                  children: [
                    Expanded(child: imageOptionWidget(type: FitType.tight)),
                    Expanded(child: imageOptionWidget(type: FitType.loose)),
                  ],
                ))),
        Column(children: [middleText, optionsWidget]),
        Padding(
            padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: SafeArea(
              child: Container(
                  width: double.infinity,
                  child: MaterialButton(
                    splashColor: Colors.transparent,
                    elevation: 0,
                    disabledColor: SessionParameters().disableColor,
                    onPressed: selectedType != null ? _moveToNextPage : null,
                    child: CustomText.withColor('NEXT',
                        selectedType != null ? Colors.white : SessionParameters().disableTextColor),
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

    String titleForm =
        SessionParameters().selectedUser == UserType.endWearer ? 'you' : 'the end-wearer';
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          centerTitle: true,
          title: Row(
            //children align to center.
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(right: 56),
                      child: Container(
                          child: Text('If the app finds $titleForm between sizes…',
                              textAlign: TextAlign.center, maxLines: 3))))
            ],
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: SessionParameters().mainBackgroundColor,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: SessionParameters().mainBackgroundColor,
        body: container);
  }
}

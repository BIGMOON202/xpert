import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/ArmorTypePage.dart';
import 'package:tdlook_flutter_app/Screens/CameraCapturePage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseCaptureModePage.dart';
import 'package:tdlook_flutter_app/Screens/HowTakePhotoPage.dart';
import 'package:tdlook_flutter_app/Screens/QuestionaryPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';

enum OverlapInchOption { one, two }

extension OverlapInchOptionExtension on OverlapInchOption {
  String get apiFlag {
    switch (this) {
      case OverlapInchOption.one:
        return '1';
      case OverlapInchOption.two:
        return '2';
    }
  }

  String get imageName {
    switch (this) {
      case OverlapInchOption.one:
        return 'overlap_1.png';
      case OverlapInchOption.two:
        return 'overlap_2.png';
    }
  }

  String get title {
    switch (this) {
      case OverlapInchOption.one:
        return '1" Overlap';
      case OverlapInchOption.two:
        return '2" Overlap';
    }
  }

  int get indexTitle {
    switch (this) {
      case OverlapInchOption.one:
        return 1;
      case OverlapInchOption.two:
        return 2;
    }
  }
}

class OverlapPage extends StatefulWidget {
  final Gender? gender;
  final MeasurementSystem? selectedMeasurementSystem;
  final MeasurementResults? measurements;

  const OverlapPage({Key? key, this.gender, this.selectedMeasurementSystem, this.measurements})
      : super(key: key);

  @override
  _OverlapPageState createState() => _OverlapPageState();
}

class _OverlapPageState extends State<OverlapPage> {
  OverlapInchOption? selectedLevel;

  void _moveToNextPage() {
    this.widget.measurements?.overlap = selectedLevel?.apiFlag;

    final bool? outerCarrier = this.widget.measurements?.event?.outerCarrier;
    if (outerCarrier == null) {
      _chooseArmor();
    } else {
      _skipChooseArmor();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageOptionWidget({OverlapInchOption? level}) {
      return GestureDetector(
          onTap: () {
            setState(() {
              this.selectedLevel = level;
            });
          },
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  color: this.selectedLevel == level
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent),
              child: Padding(
                  padding: EdgeInsets.only(top: 26, bottom: 26, left: 35, right: 35),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ResourceImage.imageWithName(level?.imageName),
                      SizedBox(height: 14),
                      Text(level?.title ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: this.selectedLevel == level
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              fontSize: 14))
                    ],
                  ))));
    }

    var container = Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 12, right: 12, bottom: 30, top: 30),
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Row(
                    children: [
                      Expanded(child: imageOptionWidget(level: OverlapInchOption.one)),
                      Expanded(child: imageOptionWidget(level: OverlapInchOption.two)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
          child: SafeArea(
            child: Container(
              width: double.infinity,
              child: MaterialButton(
                splashColor: Colors.transparent,
                elevation: 0,
                disabledColor: SessionParameters().disableColor,
                onPressed: selectedLevel != null ? _moveToNextPage : null,
                child: CustomText.withColor('NEXT',
                    selectedLevel != null ? Colors.white : SessionParameters().disableTextColor),
                color: SessionParameters().selectionColor,
                height: 50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Select overlap', textAlign: TextAlign.center),
        backgroundColor: SessionParameters().mainBackgroundColor,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: SessionParameters().mainBackgroundColor,
      body: container,
    );
  }

  void _chooseArmor() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (BuildContext context) => ArmorTypePage(
          gender: widget.gender,
          selectedMeasurementSystem: widget.selectedMeasurementSystem,
          measurements: widget.measurements,
        ),
      ),
    );
  }

  void _skipChooseArmor() {
    final selectedCompany = SessionParameters().selectedCompany;
    if (selectedCompany == null) return;
    final MeasurementResults? measurement = widget.measurements;
    switch (selectedCompany) {
      case CompanyType.uniforms:
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) => QuestionaryPage(
              gender: widget.gender,
              measurement: measurement,
              selectedMeasurementSystem: widget.selectedMeasurementSystem,
            ),
          ),
        );
        return;

      case CompanyType.armor:
        if (SessionParameters().selectedUser == UserType.endWearer) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => ChooseCaptureModePage(
                argument: ChooseCaptureModePageArguments(
                  gender: widget.gender,
                  measurement: measurement,
                ),
              ),
            ),
          );
        } else {
          SessionParameters().captureMode = CaptureMode.withFriend;

          if (Application.isProMode) {
            Navigator.pushNamed(
              context,
              CameraCapturePage.route,
              arguments: CameraCapturePageArguments(
                photoType: PhotoType.front,
                measurement: measurement,
                frontPhoto: null,
                sidePhoto: null,
              ),
            );
          } else {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) => HowTakePhotoPage(
                  gender: widget.gender,
                  measurements: measurement,
                ),
              ),
            );
          }
        }
    }
  }
}

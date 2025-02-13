import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/ScreenComponents/Ruler/RulerView.dart';
import 'package:tdlook_flutter_app/ScreenComponents/Ruler/RulerViewController.dart';
import 'package:tdlook_flutter_app/Screens/ArmorTypePage.dart';
import 'package:tdlook_flutter_app/Screens/CameraCapturePage.dart';
import 'package:tdlook_flutter_app/Screens/ChooseCaptureModePage.dart';
import 'package:tdlook_flutter_app/Screens/HowTakePhotoPage.dart';
import 'package:tdlook_flutter_app/Screens/OverlapPage.dart';
import 'package:tdlook_flutter_app/Screens/PrefferedFitPage.dart';
import 'package:tdlook_flutter_app/Screens/QuestionaryPage.dart';
import 'package:tdlook_flutter_app/Screens/WaistLevelPage.dart';
import 'package:tdlook_flutter_app/generated/l10n.dart';

class RulerPageWeight extends StatefulWidget {
  final Gender? gender;
  final MeasurementSystem? selectedMeasurementSystem;
  final MeasurementResults? measurement;
  const RulerPageWeight({
    Key? key,
    this.gender,
    this.selectedMeasurementSystem,
    this.measurement,
  }) : super(key: key);

  @override
  _RulerPageWeightState createState() => _RulerPageWeightState();
}

class _RulerPageWeightState extends State<RulerPageWeight> {
  String? _currentValue;
  double? _currentRawValue;
  RulerViewController? _controller;
  UserType? _userType;

  final Color _backgroundColor = HexColor.fromHex('16181B');
  MeasurementSystem get _system => widget.selectedMeasurementSystem ?? MeasurementSystem.imperial;

  @override
  void initState() {
    super.initState();
    _userType = SessionParameters().selectedUser;
    _controller = RulerViewController(
      measurementSystem: _system,
      type: RulerViewType.weights,
      onChangedValue: _onChangedValue,
    );
    _currentValue = _controller?.defaultImperialValue;
  }

  void _onChangedValue(String? value, double? rawValue) {
    setState(() {
      _currentValue = value;
      _currentRawValue = rawValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEW = _userType == UserType.endWearer;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(S.current.page_title_choose_weight_as_ew(isEW)),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      backgroundColor: _backgroundColor,
      body: Column(
        children: [
          _buildRuler(),
          // _buildSpaser(),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildRuler() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currentValue ?? '',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 60, color: Colors.white),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 10),
                  child: Text(
                    _controller?.measurementSystem == MeasurementSystem.metric ? "kg" : "lbs",
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                  ),
                )
              ],
            )),
          ),
          RulerView(controller: _controller),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 92, bottom: 12),
        child: SizedBox(
          width: double.infinity,
          child: MaterialButton(
            splashColor: Colors.transparent,
            elevation: 0,
            onPressed: () {
              _moveToNextPage();
            },
            textColor: Colors.white,
            child: CustomText('NEXT'),
            color: SessionParameters().selectionColor,
            height: 50,
            padding: EdgeInsets.only(left: 12, right: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }

  void _moveToNextPage() {
    widget.measurement?.weight = _currentRawValue;
    if (SessionParameters().selectedCompany == CompanyType.armor) {
      if (widget.measurement?.askForOverlap == true) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) => OverlapPage(
              gender: widget.gender,
              measurements: widget.measurement,
            ),
          ),
        );
      } else {
        final bool? outerCarrier = widget.measurement?.event?.outerCarrier;
        if (outerCarrier == null) {
          _chooseArmor();
        } else {
          _skipChooseArmor();
        }
      }
    } else {
      if (Application.shouldShowWaistLevel && widget.measurement!.askForWaistLevel!) {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => WaistLevelPage(
                gender: widget.gender,
                selectedMeasurementSystem: widget.selectedMeasurementSystem,
                measurements: widget.measurement,
              ),
            ));
      } else {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (BuildContext context) => PrefferedFitPage(
              gender: widget.gender,
              selectedMeasurementSystem: widget.selectedMeasurementSystem,
              measurements: widget.measurement,
            ),
          ),
        );
      }
    }
  }

  void _chooseArmor() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (BuildContext context) => ArmorTypePage(
          gender: widget.gender,
          measurements: widget.measurement,
        ),
      ),
    );
  }

  void _skipChooseArmor() {
    final selectedCompany = SessionParameters().selectedCompany;
    if (selectedCompany == null) return;
    final MeasurementResults? measurement = widget.measurement;
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

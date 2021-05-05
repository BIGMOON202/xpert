import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/ScreenComponents/Ruler/RulerView.dart';
import 'package:tdlook_flutter_app/ScreenComponents/Ruler/RulerViewController.dart';
import 'package:tdlook_flutter_app/Screens/RulerWeightPage.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/UIComponents/SegmentedControl.dart';
import 'package:tdlook_flutter_app/generated/l10n.dart';

import '../Models/MeasurementModel.dart';

class RulerPage extends StatefulWidget {
  final Gender gender;
  final MeasurementResults measuremet;
  const RulerPage({Key key, this.gender, this.measuremet}) : super(key: key);

  @override
  _RulerPageState createState() => _RulerPageState();
}

class _RulerPageState extends State<RulerPage> {
  String _currentValue;
  double _currentRawValue;
  RulerViewController _controller;
  UserType _userType;

  final Color _backgroundColor = HexColor.fromHex('16181B');

  @override
  void initState() {
    super.initState();
    _userType = SessionParameters().selectedUser;
    _controller = RulerViewController(
        measurementSystem: MeasurementSystem.imperial,
        type: RulerViewType.heights,
        onChangedValue: _onChangedValue);
    _currentValue = _controller.defaultImperialValue;
  }

  void _onChangedValue(String value, double rawValue) {
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
        title: Text(S.current.page_title_choose_height_as_ew(isEW)),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: _backgroundColor,
      body: Column(
        children: [
          _buildRuler(),
          _buildSegmentedControl(),
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
                  _currentValue,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 60,
                      color: Colors.white),
                ),
                if (_controller.measurementSystem == MeasurementSystem.metric)
                  Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 10),
                    child: Text(
                      "cm",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white),
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

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 40),
      child: Container(
        width: 236,
        height: 52,
        decoration: BoxDecoration(
          color: HexColor.fromHex('303339'),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SegmentedControl(onChanged: (i) {
            final system =
                i == 0 ? MeasurementSystem.imperial : MeasurementSystem.metric;
            if (_controller.measurementSystem != system) {
              _controller.measurementSystem = system;
            }
          }),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: SizedBox(
          width: double.infinity,
          child: MaterialButton(
            onPressed: () {
              _moveToNextPage();
            },
            textColor: Colors.white,
            child: CustomText('NEXT'),
            color: HexColor.fromHex('1E7AE4'),
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
    widget.measuremet.height = _currentRawValue;
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (BuildContext context) => RulerPageWeight(
                gender: widget.gender,
                selectedMeasurementSystem: _controller.measurementSystem,
                measurement: widget.measuremet)));
  }
}

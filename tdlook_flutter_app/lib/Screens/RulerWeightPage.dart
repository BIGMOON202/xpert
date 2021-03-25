

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Container+Additions.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/ChooseCaptureModePage.dart';
import 'package:tdlook_flutter_app/Screens/HowTakePhotoPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tdlook_flutter_app/Screens/RulerPageClavicle.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';


class RulerPageWeight extends StatefulWidget {

  final Gender gender;
  final MeasurementSystem selectedMeasurementSystem;
  final MeasurementResults measurement;
  const RulerPageWeight ({ Key key, this.gender , this.selectedMeasurementSystem, this.measurement}): super(key: key);

  @override
  _RulerPageWeightState createState() => _RulerPageWeightState();
}

class _RulerPageWeightState extends State<RulerPageWeight> {

  ItemPositionsListener _itemPositionsListener =  ItemPositionsListener.create();
  ItemScrollController _itemScrollController;

  int minValue = 40;
  int maxValue = 200;
  int numberOfRulerElements;
  String _value = '40';
  String _valueMeasure = 'kg';
  var rulerGap = 0;
  var _listHeight = 300.0;

  double _rawMetricValue = 40;
  static Color _backgroundColor = HexColor.fromHex('16181B');


  @override
  void initState() {
    if (widget.selectedMeasurementSystem == MeasurementSystem.imperial) {
      maxValue = 201;
    }
    numberOfRulerElements = maxValue - minValue;

    _itemPositionsListener.itemPositions.addListener(() {

      var positions = _itemPositionsListener.itemPositions.value;

      int min;
      int max;
      if (positions.isNotEmpty) {
        // Determine the first visible item by finding the item with the
        // smallest trailing edge that is greater than 0.  i.e. the first
        // item whose trailing edge in visible in the viewport.
        min = positions
            .where((ItemPosition position) => position.itemTrailingEdge > 0)
            .reduce((ItemPosition min, ItemPosition position) =>
        position.itemTrailingEdge < min.itemTrailingEdge
            ? position
            : min)
            .index;
        // Determine the last visible item by finding the item with the
        // greatest leading edge that is less than 1.  i.e. the last
        // item whose leading edge in visible in the viewport.
        max = positions
            .where((ItemPosition position) => position.itemLeadingEdge < 1)
            .reduce((ItemPosition max, ItemPosition position) =>
        position.itemLeadingEdge > max.itemLeadingEdge
            ? position
            : max)
            .index;
      }

      if (rulerGap == 0) {
        rulerGap = max - min;
      }


      // print('W min:$min max $max');

      _updateValuesFor(min, max);
      // _updateValuesFor(min);
    });
    super.initState();
  }

  void _updateValuesFor(int minIndex, int maxIndex) {

    int selectedIndex;
    if (minIndex == 0) {
      selectedIndex = maxIndex - rulerGap;
    } else if (maxIndex == numberOfRulerElements) {
      selectedIndex = minIndex + rulerGap;
    } else {
      selectedIndex = maxIndex - rulerGap;
    }

    setState(() {
      int cmValue = selectedIndex + minValue;

      if (widget.selectedMeasurementSystem == MeasurementSystem.metric) {
        _value = '$cmValue';
        _valueMeasure = 'kg';
        _rawMetricValue = cmValue.toDouble();
      } else {

        double oneSegmentValue = (200.5 - minValue) / (numberOfRulerElements);
        double kgValueDouble = selectedIndex.toDouble() * oneSegmentValue + minValue.toDouble();
        _rawMetricValue = kgValueDouble;

        double lbs = kgValueDouble.toDouble() * 2.2;//0462;
        _valueMeasure = 'lbs';
        _value = '${lbs.round()}';// lbs.toStringAsFixed(0);
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    // _addListener();
    if (widget.selectedMeasurementSystem == MeasurementSystem.metric) {
      numberOfRulerElements = maxValue - minValue;
    } else {
      numberOfRulerElements = 352;
    }



    Widget _textWidgetForRuler({int index}) {

      String _text = '';

      if (widget.selectedMeasurementSystem == MeasurementSystem.metric) {
        int kgValue = index + minValue;
        if (index % 5 == 0) {
          _text = '$kgValue';
        }
      } else {

        double oneSegmentValue = (200.5 - minValue) / (numberOfRulerElements);
        double kgValueDouble = index.toDouble() * oneSegmentValue + minValue.toDouble();

        double lbs = kgValueDouble.toDouble() * 2.2;//0462;
        int lbsInt = lbs.round();

        if (lbsInt % 10 == 0) {
          _text = '$lbsInt';
        }
      }

      Text widgetToRetun = Text(_text, style: TextStyle(
          color: Colors.white),);

      return widgetToRetun;
    }

    double _lineWidthForRulerAt({int index}) {


      if (widget.selectedMeasurementSystem == MeasurementSystem.metric) {
        return (index % 10 == 0) ? 30 : (index % 5 == 0) ? 22 : 12;
      } else {

        double oneSegmentValue = (200.5 - minValue) / (numberOfRulerElements);
        double kgValueDouble = index.toDouble() * oneSegmentValue + minValue.toDouble();

        double lbs = kgValueDouble.toDouble() * 2.2;//0462;

        int lbsInt = lbs.round();
        return (lbsInt % 10 == 0) ? 30 : 12;
      }
    }

    var itemCount = numberOfRulerElements + 1;
    var _lineOffset = 7.0;
    ScrollablePositionedList _listView =   ScrollablePositionedList.builder(itemBuilder: (_,index) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [Expanded(
          child:  Center(
            child:     Container(height: 1,
                width: _lineWidthForRulerAt(index: index),
                color: Colors.white,
                margin: EdgeInsets.only(
                  top: _lineOffset,
                  bottom: _lineOffset,
                )),
          )
      ),
        SizedBox(
          width: 30,
          child: _textWidgetForRuler(index: index),
        )
      ],
    ),
      padding: EdgeInsets.only(top:(_listHeight*0.5-_lineOffset) ,bottom: (_listHeight*0.5-_lineOffset)),
      itemCount: itemCount,
      itemPositionsListener: _itemPositionsListener,
      itemScrollController: _itemScrollController,);



    var listView = Stack(
      children: [ SizeProviderWidget(
          onChildSize: (size) {
            // _listView.padding = EdgeInsets.only(top:300);
          },
          child:  _listView
      ),

        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            child: Container(
              color: Colors.white,
            ),
            width: 50,
            height: 4,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 17,
            width: 17,
            child: ResourceImage.imageWithName('ic_leftTriangle.png'),
          ),
        )
      ],
    );

    var containerForList = Row(

      // color: _backgroundColor,
      children: [   Flexible(
        flex: 1,
        child: Center(
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [

              Text(_value, style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 50,
                  color: Colors.white
              ),
              ),

              Text(_valueMeasure, style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: Colors.white
              ),
              )
            ],
          ),
        ),
      ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: _listHeight,
            width: 90,
            child: listView,
            color: _backgroundColor,
          ),
        ),
        SizedBox(
          width: 60,
        )],
    );

    void _moveToNextPage() {
      widget.measurement.weight = _rawMetricValue;

      print('company: ${SessionParameters().selectedCompany.apiKey()}');
      if (SessionParameters().selectedCompany == CompanyType.armor) {
        Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
            RulerPageClavicle(gender: widget.gender, selectedMeasurementSystem: widget.selectedMeasurementSystem, measurements: widget.measurement
              ,),
        ));
      } else {

        if (SessionParameters().selectedUser == UserType.endWearer) {
          Navigator.pushNamed(context, ChooseCaptureModePage.route,
              arguments: ChooseCaptureModePageArguments(gender: widget.gender, measurement: widget.measurement));

        } else {
          Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
              HowTakePhotoPage(gender: widget.gender, measurements: widget.measurement)
          ));
        }

      }
    }

    var nextButton = SafeArea(child:SizedBox(
        width: double.infinity,
        child: MaterialButton(
          onPressed: () {
            print('next button pressed');
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
          // padding: EdgeInsets.all(4),
        )),
    );

    var containerForButton = Align(
      alignment: Alignment.bottomCenter,
      child: nextButton,
    );

    var segmentControl = Visibility(visible: false, child: CustomSlidingSegmentedControl(
      // thumbColor: HexColor.fromHex('E0E3E8'),
      //  backgroundColor: HexColor.fromHex('303339'),
      data: ['KG', 'LBS'],
      panelColor: HexColor.fromHex('E0E3E8'),
      textColor: Colors.black,
      background: HexColor.fromHex('303339'),
      radius: 37,
      fixedWidth: 100,
      padding: 8,
      innerPadding: 6,
      onTap: (i) {
        setState(() {
          // selectedMeasurementSystem = i;
          print('selected segment is $i');
        });
      },
    ));

    var screenContainer = Column(
      children:
      [Expanded(
        child: containerForList,
      ),
        // segmentControl,
        SizedBox(height: 85),
        nextButton],
    );


    var scaffold = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('End-wearer\'s weight?'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: _backgroundColor,
      body: screenContainer,
    );

    return scaffold;
  }
}
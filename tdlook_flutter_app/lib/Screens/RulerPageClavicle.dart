

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Container+Additions.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'CameraCapturePage.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Screens/HowTakePhotoPage.dart';


class RulerPageClavicle extends StatefulWidget {

  final Gender gender;
  final MeasurementSystem selectedMeasurementSystem;
  final MeasurementResults measurements;
  const RulerPageClavicle ({ Key key, this.gender , this.selectedMeasurementSystem, this.measurements}): super(key: key);

  @override
  _RulerPageStateClavicle createState() => _RulerPageStateClavicle();
}

class _RulerPageStateClavicle extends State<RulerPageClavicle> {

  ItemPositionsListener _itemPositionsListener =  ItemPositionsListener.create();
  ItemScrollController _itemScrollController;

  int minValue = 25;
  int maxValue = 51;
  int numberOfRulerElements;

  String _value = '25';
  String _valueMeasure = 'cm';
  double _rawMetricValue = 25;
  var rulerGap = 0;
  var _listHeight = 300.0;

  static Color _backgroundColor = HexColor.fromHex('16181B');


  @override
  void initState() {
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
      // print('min:$min max $max');
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
      double cmValue = minValue + selectedIndex * 0.5;

      if (widget.selectedMeasurementSystem == MeasurementSystem.metric) {
        if (cmValue % 1 == 0) {
          _value = '${cmValue.toStringAsFixed(0)}';
        } else {
          _value = '${cmValue.toStringAsFixed(1)}';
        }

        _valueMeasure = 'cm';
        _rawMetricValue = cmValue;
      } else {


        double oneSegmentValue = (maxValue - minValue) / (numberOfRulerElements);
        double cmValueDouble = selectedIndex.toDouble() * oneSegmentValue + minValue.toDouble();

        _rawMetricValue = cmValueDouble;

        // int ft = (cmValueDouble / 30.48).toInt();
        // double inch = cmValueDouble - ft.toDouble() * 30.48;
        double inch = (cmValueDouble / 2.54);
        int inchInt = inch.round();
        print('inch: $inch');
        print('inchInt: $inchInt');

        if (selectedIndex % 4 == 0) {
          _value = '${inchInt}\'\'';
        } else {
          int part = 1;
          if (selectedIndex % 3 == 0) {
            part = 3;
          } else if (selectedIndex % 2 == 0) {
            part = 2;
          }
          _value = '${inchInt}\'\'${part}/4';
        }
        _valueMeasure = '';
      }
    });

  }


  @override
  Widget build(BuildContext context) {

    if (widget.selectedMeasurementSystem == MeasurementSystem.metric) {
      numberOfRulerElements = (maxValue - minValue) * 2;
    } else {
      numberOfRulerElements = 40;
    }

    Widget _textWidgetForRuler({int index}) {

      String _text = '';

      if (widget.selectedMeasurementSystem == MeasurementSystem.metric) {
        if (index % 5 == 0) {
          var val = minValue + index * 0.5;
      
          _text = '${val.toStringAsFixed(1)}';
        }
      } else {
        if (index % 4 == 0) {
          double oneSegmentValue = (maxValue - minValue) / (numberOfRulerElements);
          double cmValueDouble = index.toDouble() * oneSegmentValue + minValue.toDouble();

          // int ft = (cmValueDouble / 30.48).toInt();
          // double inch = cmValueDouble - ft.toDouble() * 30.48;
          int ddf = (cmValueDouble / 2.54).round();
          _text = '$ddf\'\'';
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
        return (index % 4 == 0) ? 30 : 12;
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
                width:  _lineWidthForRulerAt(index: index),
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
      children: [   Expanded(
        flex: 2,
        child: Center(
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [

              Flexible(child:Container(
                  child:Text(_value, style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 40,
                  color: Colors.white,
              ), textAlign: TextAlign.start, maxLines: 1,
              ))),

              Visibility(
                visible: widget.selectedMeasurementSystem == MeasurementSystem.metric,
                  child:Container(
                  child: Text(_valueMeasure, style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.white
              ),
              )))
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

      widget.measurements.clavicle = _rawMetricValue;
      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
        HowTakePhotoPage(gender: widget.gender, measurements: widget.measurements)
      ));
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
      data: ['CM', 'IN'],
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
        title: Text('End-wearer\'s clavicle?'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: _backgroundColor,
      body: screenContainer,
    );

    return scaffold;
  }
}
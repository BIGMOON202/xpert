

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
import 'package:tdlook_flutter_app/Screens/RulerWeightPage.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';

class RulerPage extends StatefulWidget {

  final Gender gender;
  final MeasurementResults measuremet;
  const RulerPage ({ Key key, this.gender, this.measuremet }): super(key: key);

  @override
  _RulerPageState createState() => _RulerPageState();
}

class _RulerPageState extends State<RulerPage> {

  ItemPositionsListener _itemPositionsListener =  ItemPositionsListener.create();
  ItemScrollController _itemScrollController;

  int minValue = 150;
  int maxValue = 220;
  int numberOfRulerElements;
  MeasurementSystem selectedMeasurementSystem = MeasurementSystem.imperial;
  String _value = '150';
  String _valueMeasure = 'cm';
  var rulerGap = 14;

  double _rawMetricValue = 150;
  static Color _backgroundColor = HexColor.fromHex('16181B');


  void _addListener() {
    _itemPositionsListener.itemPositions.addListener(() {

      var positions = _itemPositionsListener.itemPositions.value;
      // print('$positions');
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

      // print('H min:$min max $max');
      _updateValuesFor(min, max);
      // _updateValuesFor(min);
    });
  }

  void _removeListener() {
    _itemPositionsListener.itemPositions.removeListener(() { });
  }

  @override
  void initState() {
    print('INIT RULER H');
    numberOfRulerElements = maxValue - minValue;

    _addListener();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _removeListener();
    super.dispose();
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
      // var dif = (maxIndex - minIndex) - rulerGap;
      int cmValue = selectedIndex + minValue;

      if (selectedMeasurementSystem == MeasurementSystem.metric) {
        _value = '$cmValue';
        _valueMeasure = 'cm';
        _rawMetricValue = cmValue.toDouble();
      } else {
        // int oneSegmentValue = ((maxValue - minValue) / (numberOfRulerElements)).toInt();
        double oneSegmentValue = (maxValue - minValue) / (numberOfRulerElements);
        double cmValueDouble = selectedIndex.toDouble() * oneSegmentValue + minValue.toDouble();
        _rawMetricValue = cmValueDouble;

        int ft = (cmValueDouble / 30.48).toInt();
        double inch = cmValueDouble - ft.toDouble() * 30.48;
        int ddf = (inch / 2.54).toInt();

        _valueMeasure = '';
        _value = '$ft\'$ddf\'\'';
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    // _addListener();
    if (selectedMeasurementSystem == MeasurementSystem.metric) {
      numberOfRulerElements = maxValue - minValue;
    } else {
      numberOfRulerElements = 27;
    }

    Widget _textWidgetForRuler({int index}) {

      String _text = '';
      if (selectedMeasurementSystem == MeasurementSystem.metric) {
        if (index % 5 == 0) {
          var val = minValue + index;
          _text = '$val';
        }
      } else {
        double oneSegmentValue = (maxValue - minValue) / (numberOfRulerElements);
        double cmValueDouble = index.toDouble() * oneSegmentValue + minValue.toDouble();

        int ft = (cmValueDouble / 30.48).toInt();
        double inch = cmValueDouble - ft.toDouble() * 30.48;
        int ddf = (inch / 2.54).toInt();

        if ((ddf == 0) || (ddf == 6)) {
          _text = '$ft\'$ddf\'\'';
        }
      }

      Text widgetToRetun = Text(_text, style: TextStyle(
        color: Colors.white),);

      return widgetToRetun;
    }

    double _lineWidthForRulerAt({int index}) {
      if (selectedMeasurementSystem == MeasurementSystem.metric) {
        return (index % 10 == 0) ? 30 : (index % 5 == 0) ? 22 : 12;
      } else {

        double oneSegmentValue = (maxValue - minValue) / (numberOfRulerElements);
        double cmValueDouble = index.toDouble() * oneSegmentValue + minValue.toDouble();

        int ft = (cmValueDouble / 30.48).toInt();
        double inch = cmValueDouble - ft.toDouble() * 30.48;
        int ddf = (inch / 2.54).toInt();

        if ((ddf == 0) || (ddf == 6)) {
          return 22;
        } else {
          return 12;
        }
      }
    }

    var itemCount = numberOfRulerElements + 1;
    ScrollablePositionedList _listView =   ScrollablePositionedList.builder(itemBuilder: (_,index) => Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  // crossAxisAlignment: CrossAxisAlignment.baseline,
                                                                  children: [Expanded(
                                                                    child:  Center(
                                                                              child:     Container(height: 1,
                                                                                                                    width: _lineWidthForRulerAt(index: index),
                                                                                                                    color: Colors.white,
                                                                                                                    margin: EdgeInsets.only(
                                                                                                                    top: 7,
                                                                                                                      bottom: 7,
                                                                                                                           )),
                                                                            )
                                                                          ),
                                                                            SizedBox(
                                                                              width: 30,
                                                                              child: _textWidgetForRuler(index: index),
                                                                            )
                                                                              ],
                                                                ),
                                                   padding: EdgeInsets.only(top:240,bottom: 240),
                                                   itemCount: itemCount,
    itemPositionsListener: _itemPositionsListener,
    itemScrollController: _itemScrollController,);



    var listView = Stack(
      children: [ SizeProviderWidget(
        onChildSize: (size) {
            // _listView.padding = EdgeInsets.only(top:300);
        },
        child: Padding(padding: EdgeInsets.only(top: 66, bottom: 66), child:_listView)
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
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [

                     Text(_value, style: TextStyle(
                                 fontWeight: FontWeight.w500,
                                 fontSize: 60,
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
      widget.measuremet.height = _rawMetricValue;
      // _itemPositionsListener.itemPositions.removeListener(() {});
      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
          RulerPageWeight(gender: widget.gender, selectedMeasurementSystem: selectedMeasurementSystem, measurement: widget.measuremet)
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

    var segmentControl = CustomSlidingSegmentedControl(
         // thumbColor: HexColor.fromHex('E0E3E8'),
         //  backgroundColor: HexColor.fromHex('303339'),
                        data: ['IN','CM'],
         panelColor: HexColor.fromHex('E0E3E8'),
         textColor: Colors.black,
         background: HexColor.fromHex('303339'),
         radius: 37,
          fixedWidth: 100,
          padding: 8,
          innerPadding: 6,
          onTap: (i) {
                          setState(() {
                            selectedMeasurementSystem =  (i == 0) ? MeasurementSystem.imperial : MeasurementSystem.metric;
                            print('selected segment is $i');
                          });
          },
    );

    var screenContainer = Column(
      children:
      [Expanded(
        child: containerForList,
      ),
        segmentControl,
        SizedBox(height: 40),
        nextButton],
    );


    var scaffold = Scaffold(
      appBar: AppBar(
         title: Text('End-wearer\'s height?'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: _backgroundColor,
      body: screenContainer,
    );

    return scaffold;
  }
}
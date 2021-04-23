import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Container+Additions.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/Screens/RulerWeightPage.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/UIComponents/SegmentedControl.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:tdlook_flutter_app/Extensions/Math+Extension.dart';
class RulerPage extends StatefulWidget {

  final Gender gender;
  final MeasurementResults measuremet;
  const RulerPage ({ Key key, this.gender, this.measuremet }): super(key: key);

  @override
  _RulerPageState createState() => _RulerPageState();
}

class _RulerPageState extends State<RulerPage> {

  ScrollController _scrollController;
  int minValue = 150;
  int maxValue = 220;
  int numberOfRulerElements;
  MeasurementSystem selectedMeasurementSystem = MeasurementSystem.imperial;
  String _value = '4\'11\'\'';
  String _valueMeasure = '';
  var rulerGap = 0;
  var _listHeight = 300.0;

  double _lineOffset = 7.0;
  double _lineHeight = 1.0;
  double _itemHeight;
  double _maxNumberOfVisibleElements;

  double _rawMetricValue = 150;
  static Color _backgroundColor = HexColor.fromHex('16181B');

  int _lastMin;
  int _lasMax;

  Map<int,bool> visibleItems = Map();

  void updateVisibility({int index, double visibility}) {

    List<int> listToRemove = List();
    if (visibility == 1.0) {
      visibleItems[index] = visibility == 1;
    } else {
      listToRemove.add(index);
    }


    var sortedKeys = visibleItems.keys.toList();
    sortedKeys.sort();

    for (var elem in listToRemove) {
      sortedKeys.remove(elem);
      visibleItems.remove(elem);
    }
    var minVisible = sortedKeys.first;
    var maxVisible = sortedKeys.last;
    _updateValuesFor(minVisible, maxVisible);
  }

  @override
  void initState() {
    super.initState();

    _itemHeight = _lineOffset * 2 + _lineHeight;
    _maxNumberOfVisibleElements = _listHeight / _itemHeight;

    //TO-DO replace by calculations below
    visibleItems[0] = true;
    visibleItems[9] = true;

    _scrollController = ScrollController();

    if (selectedMeasurementSystem == MeasurementSystem.metric) {
      numberOfRulerElements = maxValue - minValue;
    } else {
      numberOfRulerElements = 27;
    }
  }

  int _lastSelectedIndex = 0;
  int _indexToJump = 0;

  void _updateValuesFor(int minIndex, int maxIndex) {

    int selectedIndex;

    if (minIndex == 0) {
      selectedIndex = ((maxIndex * _itemHeight - _listHeight * 0.5) / _itemHeight).toInt();
    } else if (maxIndex == numberOfRulerElements) {
      selectedIndex = maxIndex - (((maxIndex - minIndex) * _itemHeight - _listHeight * 0.5)/_itemHeight).toInt();
    } else {
      selectedIndex = (maxIndex - (_maxNumberOfVisibleElements * 0.5).round()).round();
    }

    if (selectedIndex < 0) { selectedIndex = 0;}
    else if (selectedIndex > numberOfRulerElements) { selectedIndex = numberOfRulerElements;}

    _lastSelectedIndex = selectedIndex;


      int cmValue = selectedIndex + minValue;
      if (selectedMeasurementSystem == MeasurementSystem.metric) {
        setState(() {
          _value = '$cmValue';
          _valueMeasure = 'cm';
          _rawMetricValue = cmValue.toDouble();
        });
      } else {
          double oneSegmentValue = (maxValue - minValue) /
              (numberOfRulerElements);
          double cmValueDouble = selectedIndex.toDouble() * oneSegmentValue +
              minValue.toDouble();


          int ft = (cmValueDouble / 30.48).toInt();
          double inch = cmValueDouble - ft.toDouble() * 30.48;
          int ddf = (inch / 2.54).toInt();

          setState(() {
            _rawMetricValue = cmValueDouble;
            _valueMeasure = '';
            _value = '$ft\'$ddf\'\'';
        });
      }
  }

  int transferIndexTo({MeasurementSystem newSystem}) {

    var indexValue = ((maxValue - minValue) / 27);
    var newIndex = _lastSelectedIndex;

    if (newSystem == MeasurementSystem.imperial) {
      var indexValue = ((maxValue - minValue) / 27);
      var double = _lastSelectedIndex / indexValue;
      newIndex = double.round();
      if (newIndex <= 17) {
        newIndex += 1;
      }
    } else {
      var double = _lastSelectedIndex * indexValue;
      newIndex = double.round();
    }
    return newIndex;
  }


  @override
  Widget build(BuildContext context) {

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

      // _text = '$index';
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

    int initialIndex() {
      if (selectedMeasurementSystem == MeasurementSystem.metric) {
        return 35;
      } else {
        return 13;
      }
    }

    var itemCount = numberOfRulerElements + 1;


    var list = ListView.builder(itemBuilder: (_, index) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [Expanded(
          child:  Center(
              child:  VisibilityDetector(
                key: Key('$index'),
                onVisibilityChanged: (visibilityInfo) {
                  var visiblePercentage = visibilityInfo.visibleFraction * 100;

                  var elementIndex = visibilityInfo.key.toString().getIntValue();
                  // debugPrint('Widget ${elementIndex} is ${visiblePercentage}% visible');

                  updateVisibility(index: elementIndex, visibility: visibilityInfo.visibleFraction);



                },

                child: Container(height: _lineHeight,
                    width: _lineWidthForRulerAt(index: index),
                    color: Colors.white,
                    // margin: EdgeInsets.only(
                    //   top: _lineOffset,
                    //   bottom: _lineOffset,
                    // )
                ),
              )
          )
      ),
        SizedBox(
          width: 30,
          height: _itemHeight,
          child: _textWidgetForRuler(index: index),
        )
      ],
    ),
      padding: EdgeInsets.only(top:(_listHeight*0.5-_lineOffset) ,bottom: (_listHeight*0.5-_lineOffset)),
      itemCount: itemCount,
      controller: _scrollController);


    var listView = Stack(
      children: [ SizeProviderWidget(
        onChildSize: (size) {
            // _listView.padding = EdgeInsets.only(top:300);
        },
        child: Container(child: list)
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

                     Text(_value, style: TextStyle(
                                 fontWeight: FontWeight.w500,
                                 fontSize: 50,
                                 color: Colors.white
                                 ),
                               ),

              Padding(padding: EdgeInsets.only(bottom: 7), child:Text(_valueMeasure, style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: Colors.white
                                  ),
                                ))
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
      widget.measuremet.height = _rawMetricValue;
      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
          RulerPageWeight(gender: widget.gender, selectedMeasurementSystem: selectedMeasurementSystem, measurement: widget.measuremet)
      ));
    }

    var nextButton = SafeArea(child:SizedBox(
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
      )),
    );

    var containerForButton = Align(
      alignment: Alignment.bottomCenter,
      child: nextButton,
    );

    // void _handleSegmentChanged(int newValue) {
    //   setState(() {
    //   });
    // }
    //
    var segmentControl = SegmentedControl(
        onChanged: (i) {
      setState(() {
        var newSystem =  (i == 0) ? MeasurementSystem.imperial : MeasurementSystem.metric;
        if (selectedMeasurementSystem != newSystem) {
          setState(() {
            _indexToJump = transferIndexTo(newSystem: newSystem);
            _lastSelectedIndex = _indexToJump;
            selectedMeasurementSystem = newSystem;
          });
          _scrollController.jumpTo((_indexToJump) * _itemHeight);
        }
      });
      // debugPrint('_indexToJump: $_indexToJump');
      // _itemScrollController.scrollTo(index: _indexToJump, duration: Duration(milliseconds: 300));
    });


    // var segmentControl = CustomSlidingSegmentedControl(
    //                     data: ['in'.toUpperCase(),'cm'.toUpperCase()],
    //      panelColor: HexColor.fromHex('E0E3E8'),
    //      textColor: Colors.black,
    //      background: HexColor.fromHex('303339'),
    //      radius: 37,
    //       fixedWidth: 100,
    //       padding: 8,
    //       innerPadding: 6,
    //       onTap: (i) {
    //         var newSystem =  (i == 0) ? MeasurementSystem.imperial : MeasurementSystem.metric;
    //         if (selectedMeasurementSystem != newSystem) {
    //           setState(() {
    //             _indexToJump = transferIndexTo(newSystem: newSystem);
    //             _lastSelectedIndex = _indexToJump;
    //             selectedMeasurementSystem = newSystem;
    //           });
    //           _scrollController.jumpTo((_indexToJump) * _itemHeight);
    //         }
    //                       // _itemScrollController.scrollTo(index: _indexToJump, duration: Duration(milliseconds: 300));
    //                       // _itemScrollController.jumpTo(index: _indexToJump);
    //       },
    // );

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
        centerTitle: true,
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

extension StringToInt on String {
  int getIntValue() {
    return int.parse(this.replaceAll(RegExp('[^0-9]'), ''));
  }
}

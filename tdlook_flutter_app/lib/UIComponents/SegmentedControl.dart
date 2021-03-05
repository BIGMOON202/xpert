import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';

class SegmentedControl extends StatefulWidget {
  SegmentedControl({this.onChanged});

  final ValueSetter<int> onChanged;


  @override
  _SegmentedControlState createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<SegmentedControl> {


  int segmentedControlValue = 0;
  static Color _selectedTextColor = Colors.black;
  static Color _unselectedTextColor = Colors.white;
  static Color _optionalTextColor = HexColor.fromHex('#858585');

  static Widget imperialTab({int selected}) {
    return Padding(padding: EdgeInsets.all(8), child: Column(
      children: <Widget>[
        Text(
          'Imperial system'.toUpperCase(),
          style: TextStyle(color: selected == 0 ?_selectedTextColor : _unselectedTextColor,
              fontSize: 10,
              fontWeight: FontWeight.bold),
        ),
        Text('IN / LB',
          style: TextStyle(color: _optionalTextColor, fontSize: 10),),
      ],
    ));
  }

  static Widget metricTab({int selected}) {
    return  Padding(padding: EdgeInsets.all(8), child: Column(
      children: <Widget>[
        Text(
          'Metric system'.toUpperCase(),
          style: TextStyle(color: selected == 1 ?_selectedTextColor : _unselectedTextColor,
              fontSize: 10,
              fontWeight: FontWeight.bold),
        ),
        Text('CM / KG',
          style: TextStyle(color: _optionalTextColor, fontSize: 10),),
      ],
    ));
  }

   Map<int, Widget> getElements({int selected}) {
      Map<int, Widget> elements =  new Map<int, Widget>();
     elements[0] = imperialTab(selected: this.segmentedControlValue);
     elements[1] = metricTab(selected: this.segmentedControlValue);
     return elements;
   }


  Widget segmentedControl() {
    return Container(
      width: 300,
      child: CupertinoSlidingSegmentedControl(
          groupValue: segmentedControlValue,
          thumbColor: HexColor.fromHex('E0E3E8'),
          backgroundColor: HexColor.fromHex('303339'),
          children: getElements(selected: segmentedControlValue),

          onValueChanged: (value) {
            setState(() {
              segmentedControlValue = value;
              widget.onChanged(segmentedControlValue);
            });
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: segmentedControl());
  }
}

class ColumnBuilder extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final VerticalDirection verticalDirection;
  final int itemCount;

  const ColumnBuilder({
    Key key,
    @required this.itemBuilder,
    @required this.itemCount,
    this.mainAxisAlignment: MainAxisAlignment.start,
    this.mainAxisSize: MainAxisSize.max,
    this.crossAxisAlignment: CrossAxisAlignment.center,
    this.verticalDirection: VerticalDirection.down,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: this.crossAxisAlignment,
      mainAxisSize: this.mainAxisSize,
      mainAxisAlignment: this.mainAxisAlignment,
      verticalDirection: this.verticalDirection,
      children:
      new List.generate(this.itemCount, (index) => this.itemBuilder(context, index)).toList(),
    );
  }
}
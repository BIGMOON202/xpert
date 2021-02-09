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


  static final ss = ColumnBuilder(
    itemCount: 2,
      itemBuilder: (_,index) => Text('Imperial system', style: TextStyle(color: _selectedTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
  );


  static final Widget imperial = Column(
    children: <Widget>[
      Text('Imperial system', style: TextStyle(color: _selectedTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
      Text('IN / LB', style: TextStyle(color: _optionalTextColor, fontSize: 10),),
    ],
  );
   final Widget metric = Column(
    children: <Widget>[
      Text(
        'Imperial system',
        style: TextStyle(color: _selectedTextColor,
            fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
      Text('IN / LB',
        style: TextStyle(color: _optionalTextColor, fontSize: 10),),
    ],
  );

  final  Map<int, Widget> elements = const <int, Widget>{
    0: ColumnBuilder(
      itemCount: 2,
      // itemBuilder: (_,index) => Text('Imperial system', style: TextStyle(color: _selectedTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
    ),
  };


  Widget segmentedControl() {
    return Container(
      width: 300,
      child: CupertinoSlidingSegmentedControl(
          groupValue: segmentedControlValue,
          thumbColor: HexColor.fromHex('E0E3E8'),
          backgroundColor: HexColor.fromHex('303339'),
          children: elements,
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
    return segmentedControl();
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/application/themes/app_themes.dart';

class SegmentedControl extends StatefulWidget {
  SegmentedControl({this.onChanged});

  final ValueSetter<int>? onChanged;

  @override
  _SegmentedControlState createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<SegmentedControl> {
  int segmentedControlValue = 0;
  static Color _selectedTextColor = Colors.black;
  static Color _unselectedTextColor = Colors.white;
  static Color _optionalTextColor = HexColor.fromHex('#858585');

  //late AppTextStyle? _textStyle;
  // @override
  // void initState() {
  //   super.initState();
  //   //_textStyle = Theme.of(context).appTheme.textStyle;
  //   //_textStyle.s10w700
  // }

  Widget _imperialTab({int? selected}) {
    final textStyle = Theme.of(context).appTheme.textStyle;
    return Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            Text(
              'Imperial system'.toUpperCase(),
              style: textStyle?.s10w700.copyWith(
                color: selected == 0 ? _selectedTextColor : _unselectedTextColor,
              ),

              // TextStyle(
              //     color: selected == 0 ? _selectedTextColor : _unselectedTextColor,
              //     fontSize: 10,
              //     fontWeight: FontWeight.bold),
            ),
            Text(
              'IN / LB',
              style: textStyle?.s10w400.copyWith(
                color: _optionalTextColor,
              ),
              // TextStyle(color: _optionalTextColor, fontSize: 10),
            ),
          ],
        ));
  }

  Widget _metricTab({int? selected}) {
    final textStyle = Theme.of(context).appTheme.textStyle;
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Text(
            'Metric system'.toUpperCase(),
            style: textStyle?.s10w700.copyWith(
              color: selected == 1 ? _selectedTextColor : _unselectedTextColor,
            ),
            // style: TextStyle(
            //     color: selected == 1 ? _selectedTextColor : _unselectedTextColor,
            //     fontSize: 10,
            //     fontWeight: FontWeight.bold),
          ),
          Text(
            'CM / KG',
            style: textStyle?.s10w400.copyWith(
              color: _optionalTextColor,
            ),
            // style: TextStyle(color: _optionalTextColor, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Map<int, Widget> getElements({int? selected}) {
    Map<int, Widget> elements = new Map<int, Widget>();
    elements[0] = _imperialTab(selected: this.segmentedControlValue);
    elements[1] = _metricTab(selected: this.segmentedControlValue);
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
              if (value is int) {
                segmentedControlValue = value;
              }
              widget.onChanged?.call(segmentedControlValue);
            });
          }),
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
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    this.mainAxisAlignment: MainAxisAlignment.start,
    this.mainAxisSize: MainAxisSize.max,
    this.crossAxisAlignment: CrossAxisAlignment.center,
    this.verticalDirection: VerticalDirection.down,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: this.crossAxisAlignment,
      mainAxisSize: this.mainAxisSize,
      mainAxisAlignment: this.mainAxisAlignment,
      verticalDirection: this.verticalDirection,
      children: List.generate(this.itemCount, (index) => this.itemBuilder(context, index)).toList(),
    );
  }
}

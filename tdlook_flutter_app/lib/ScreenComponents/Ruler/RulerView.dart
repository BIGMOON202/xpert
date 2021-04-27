import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/ScreenComponents/Ruler/RulerValues.dart';
import 'package:tdlook_flutter_app/ScreenComponents/Ruler/RulerViewController.dart';

import '../../UIComponents/ResourceImage.dart';

extension StringToInt on String {
  int getIntValue() {
    return int.parse(this.replaceAll(RegExp('[^0-9]'), ''));
  }
}

typedef void ValueChangedCallback(String value, double rawValue);

class RulerView extends StatefulWidget {
  final ValueChangedCallback onValueChange;
  final Color backgroundColor;
  final Color cursorColor;
  final RulerViewController controller;

  /// the marker on the ruler, default is a arrow
  final Widget marker;

  /// the fraction digits of the picker value
  RulerView({
    @required this.onValueChange,
    this.backgroundColor = Colors.white,
    this.controller,
    this.cursorColor,
    this.marker,
  }) : assert(controller != null);

  @override
  _RulerViewState createState() => _RulerViewState();
}

class _RulerViewState extends State<RulerView> {
  double lastOffset = 0;
  bool isPosFixed = false;
  String value;
  // ScrollController _scrollController;

  int minValue = 150;
  int maxValue = 220;
  // int numberOfRulerElements;
  // String _value = '4\'11\'\'';
  // String _valueMeasure = '';
  var rulerGap = 0;
  // var _listHeight = 300.0;
  // double _lineOffset = 7.0;
  // double _lineHeight = 1.0;
  // double _itemHeight;
  // double _maxNumberOfVisibleElements;
  // double _rawMetricValue = 150;

  Map<int, bool> visibleItems = Map();

  // int _lastSelectedIndex = 0;
  // int _indexToJump = 0;

///////////////////////// NEW /////////////////////////
  final ScrollController _controller = ScrollController();
  final double _rowHeight = 20;
  final double _lineHeight = 1;

  String _selectedImperialValue;
  String _selectedMetricValue;

  ValueChangedCallback get _onValueChange => widget.onValueChange;
  RulerValues _rulerValues;

  @override
  void initState() {
    super.initState();
    _selectedImperialValue = widget.controller.defaultImperialHeightValue;
    _selectedMetricValue = widget.controller.defaultMetricHeightValue;
    _rulerValues = RulerValues.heights(widget.controller.measurementSystem);
    widget.controller.addListener(() {
      setState(() {
        _rulerValues = RulerValues.heights(widget.controller.measurementSystem);
      });
      _scrollToSelectedValue();
    });

    visibleItems[0] = true;
    visibleItems[9] = true;

    _controller.addListener(() {
      _calculateIndexByPosition(_controller.offset);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _changeValue();
      if (_controller.hasClients) {
        _scrollToSelectedValue();
      }
    });
  }

  Future _scrollToSelectedValue({bool isAnimated = false}) async {
    int index = 0;
    switch (widget.controller.measurementSystem) {
      case MeasurementSystem.imperial:
        index = _rulerValues.valuesList.indexOf(_selectedImperialValue);
        break;
      case MeasurementSystem.metric:
        index = _rulerValues.valuesList.indexOf(_selectedMetricValue);
        break;
    }
    final pos = (index * _rowHeight) + (_rowHeight * .5) + (_lineHeight * .5);
    if (isAnimated) {
      _controller.animateTo(
        pos,
        duration: Duration(microseconds: 300),
        curve: Curves.bounceOut,
      );
    } else {
      _controller.jumpTo(pos);
    }
    _controller.jumpTo(pos);
    _changeValue();
  }

  void _changeValue() {
    switch (widget.controller.measurementSystem) {
      case MeasurementSystem.imperial:
        _onValueChange(
            _selectedImperialValue, double.parse(_selectedMetricValue));
        break;
      case MeasurementSystem.metric:
        _onValueChange(
            _selectedMetricValue, double.parse(_selectedMetricValue));
        break;
    }
  }

  void _calculateIndexByPosition(double position) {
    final contentSize = _rulerValues.length * _rowHeight;
    var index = 0;
    if (position <= 0) {
      index = 0;
    } else if (position >= contentSize) {
      index = _rulerValues.length - 1;
    } else {
      index = position ~/ _rowHeight;
    }
    final val = _rulerValues.getValueAtIndex(index);

    setState(() {
      switch (widget.controller.measurementSystem) {
        case MeasurementSystem.imperial:
          _selectedImperialValue = val;
          _selectedMetricValue = _rulerValues.getConverted(val);
          break;
        case MeasurementSystem.metric:
          _selectedImperialValue = _rulerValues.getConverted(val);
          _selectedMetricValue = val;
          break;
      }
      _changeValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 60, top: 60, bottom: 60),
      child: SizedBox(
        width: 102,
        child: _buldRuler(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didUpdateWidget(RulerView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget _textWidgetForRuler({int index}) {
    String text = _rulerValues.getValueAtIndex(index);
    switch (widget.controller.measurementSystem) {
      case MeasurementSystem.metric:
        final intValue = int.parse(text);
        return (intValue % 10 == 0)
            ? _bigText(text)
            : (intValue % 5 == 0)
                ? _smallText(text)
                : null;
        break;
      case MeasurementSystem.imperial:
        final right = text.split("’").last;
        int ddf = right.getIntValue();
        return (ddf == 0)
            ? _bigText(text)
            : (ddf == 6)
                ? _smallText(text)
                : null;
        break;
    }
    return null;
  }

  Text _bigText(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
    );
  }

  Text _smallText(String text) {
    return Text(
      text,
      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
    );
  }

  double _lineWidthForRulerAt({int index}) {
    final value = _rulerValues.getValueAtIndex(index);
    if (widget.controller.measurementSystem == MeasurementSystem.metric) {
      final intValue = int.parse(value);
      return (intValue % 10 == 0)
          ? 30
          : (intValue % 5 == 0)
              ? 22
              : 12;
    } else {
      final right = value.split("’").last;
      int ddf = right.getIntValue();
      return (ddf == 0)
          ? 30
          : (ddf == 6)
              ? 22
              : 12;
    }
  }

  Widget _buldRuler() {
    return Stack(
      children: [
        _buildListOfValues(),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(1),
              ),
              color: Colors.white.withOpacity(0.9),
            ),
            width: 66,
            height: 2,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
              width: 17,
              height: 17,
              child: ResourceImage.imageWithName('ic_leftTriangle.png')),
        )
      ],
    );
  }

  Widget _buildListOfValues() {
    // final itemCount = numberOfRulerElements + 1;
    return LayoutBuilder(
      builder: (context, constraints) => ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemBuilder: (_, index) {
          return SizedBox(
            height: _rowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Container(
                        height: _lineHeight,
                        width: _lineWidthForRulerAt(index: index),
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                  height: _rowHeight,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: _textWidgetForRuler(index: index) ?? SizedBox()),
                ),
              ],
            ),
          );
        },
        padding: EdgeInsets.only(
            top: (constraints.maxHeight * 0.5),
            bottom: (constraints.maxHeight * 0.5)),
        itemCount: _rulerValues.length,
        controller: _controller,
      ),
    );
  }
}

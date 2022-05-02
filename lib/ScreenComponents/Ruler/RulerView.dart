import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/ScreenComponents/Ruler/RulerValues.dart';
import 'package:tdlook_flutter_app/ScreenComponents/Ruler/RulerViewController.dart';

import '../../UIComponents/ResourceImage.dart';

class RulerView extends StatefulWidget {
  final Color? backgroundColor;
  final RulerViewController? controller;

  /// the marker on the ruler, default is a arrow
  final Widget? marker;

  /// the fraction digits of the picker value
  RulerView({
    this.backgroundColor = Colors.white,
    this.controller,
    this.marker,
  }) : assert(controller != null);

  @override
  _RulerViewState createState() => _RulerViewState();
}

class _RulerViewState extends State<RulerView> {
  String? value;

  final ScrollController _controller = ScrollController();
  final double _rowHeight = 20;
  final double _lineHeight = 1;
  final double _contentWidth = 140;
  final double _centerLineWidth = 80;

  late String _selectedImperialValue;
  late String _selectedMetricValue;
  late RulerValues _rulerValues;

  RulerViewController get _rulerCtrl => widget.controller!;
  RulerViewType get _type => _rulerCtrl.type;
  MeasurementSystem get _system => _rulerCtrl.measurementSystem;

  @override
  void initState() {
    super.initState();
    _selectedImperialValue = _rulerCtrl.defaultImperialValue;
    _selectedMetricValue = _rulerCtrl.defaultMetricValue;
    _rulerValues = _rulerCtrl.values;
    _rulerCtrl.addListener(() {
      setState(() {
        _rulerValues = _rulerCtrl.values;
      });
      _scrollToSelectedValue();
    });

    _controller.addListener(() {
      _calculateIndexByPosition(_controller.offset);
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _changeValue();
      if (_controller.hasClients) {
        _scrollToSelectedValue();
      }
    });
  }

  Future _scrollToSelectedValue({bool isAnimated = false}) async {
    int index = 0;
    switch (_system) {
      case MeasurementSystem.imperial:
        index = _rulerValues.values.indexOf(_selectedImperialValue);
        break;
      case MeasurementSystem.metric:
        index = _rulerValues.values.indexOf(_selectedMetricValue);
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
    switch (_system) {
      case MeasurementSystem.imperial:
        _rulerCtrl.onChangedValue(_selectedImperialValue, double.parse(_selectedMetricValue));
        break;
      case MeasurementSystem.metric:
        _rulerCtrl.onChangedValue(_selectedMetricValue, double.parse(_selectedMetricValue));
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
    debugPrint('position: $position');
    debugPrint('index: $index');
    final val = _rulerValues.getValueAtIndex(index);

    setState(() {
      _convertValueIfNeeded(val);
      _changeValue();
    });
  }

  void _convertValueIfNeeded(String value) {
    switch (_type) {
      case RulerViewType.heights:
        switch (_system) {
          case MeasurementSystem.imperial:
            _selectedImperialValue = value;
            debugPrint('imp: $value');
            _selectedMetricValue = _rulerValues.getConvertedHeight(value);
            debugPrint('selectedMetric: $_selectedMetricValue');

            break;
          case MeasurementSystem.metric:
            debugPrint('met: $value');
            _selectedImperialValue = _rulerValues.getConvertedHeight(value);
            _selectedMetricValue = value;
            break;
        }

        break;
      case RulerViewType.weights:
        switch (_system) {
          case MeasurementSystem.imperial:
            _selectedImperialValue = value;
            _selectedMetricValue = _rulerValues.getConvertedWeight(value);
            break;
          case MeasurementSystem.metric:
            _selectedMetricValue = value;
            break;
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 60, top: 60, bottom: 60),
      child: SizedBox(
        width: _contentWidth,
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

  Widget? _textWidgetForRuler({required int index}) {
    String text = _rulerValues.getValueAtIndex(index);
    if (_system == MeasurementSystem.imperial && _type == RulerViewType.heights) {
      final right = text.split("’").last;
      int ddf = right.getIntValue();
      return (ddf == 0)
          ? _bigText(text)
          : (ddf == 6)
              ? _smallText(text)
              : null;
    } else {
      final intValue = int.parse(text);
      return (intValue % 10 == 0)
          ? _bigText(text)
          : (intValue % 5 == 0)
              ? _smallText(text)
              : null;
    }
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

  double _lineWidthForRulerAt({required int index}) {
    final value = _rulerValues.getValueAtIndex(index);
    if (_system == MeasurementSystem.imperial && _type == RulerViewType.heights) {
      final right = value.split("’").last;
      int ddf = right.getIntValue();
      return (ddf == 0)
          ? 30
          : (ddf == 6)
              ? 22
              : 12;
    } else {
      final intValue = int.parse(value);
      return (intValue % 10 == 0)
          ? 30
          : (intValue % 5 == 0)
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
            width: _centerLineWidth,
            height: 2,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
              width: 17, height: 17, child: ResourceImage.imageWithName('ic_leftTriangle.png')),
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
                  width: 54,
                  height: _rowHeight,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: _textWidgetForRuler(index: index) ?? SizedBox(),
                      )),
                ),
              ],
            ),
          );
        },
        padding: EdgeInsets.only(
            top: (constraints.maxHeight * 0.5), bottom: (constraints.maxHeight * 0.5)),
        itemCount: _rulerValues.length,
        controller: _controller,
      ),
    );
  }
}

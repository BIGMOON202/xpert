import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextStyle extends TextStyle {
  Color textColor;

  CustomTextStyle.withTextColor(Color textColor):
      textColor = textColor,
      super();

  @override
  TextDecoration get decoration => TextDecoration.none;
  @override
  double get fontSize =>  18;

  @override
  FontWeight get fontWeight => FontWeight.bold;

  @override
  Color get color => textColor;
}

class CustomText extends Text {
  Color color = Colors.white;

  CustomText(String data) : super(data);

  CustomText.withColor(String data, Color color) :
        color = color,
    super(data);

  @override
  // TODO: implement style
  TextStyle get style => CustomTextStyle.withTextColor(color);
}
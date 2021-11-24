import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextStyle extends TextStyle {
  Color textColor;

  CustomTextStyle.withTextColor(Color textColor):
      textColor = textColor,
      super();

  @override
  // TODO: implement decoration
  TextDecoration get decoration => TextDecoration.none;
  @override
  // TODO: implement fontSize
  double get fontSize =>  18;

  @override
  // TODO: implement fontWeight
  FontWeight get fontWeight => FontWeight.bold;

  @override
  // TODO: implement color
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextStyle extends TextStyle {
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
  Color get color => Colors.white;
}

class CustomText extends Text {


  CustomText(String data) : super(data);

  @override
  // TODO: implement style
  TextStyle get style => CustomTextStyle();
}
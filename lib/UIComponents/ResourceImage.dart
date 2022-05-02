import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ResourceImage {
  static Image imageWithName(
    String? name, {
    Color? color,
    BoxFit? fit,
  }) {
    var assetsPath = "lib/Resources/";
    var image = Image(image: AssetImage(assetsPath + (name ?? '')), fit: fit);
    return image;
  }
}

extension ImageExtension on Image {
  ColorFiltered apply({required Color color}) {
    return ColorFiltered(child: this, colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
  }
}

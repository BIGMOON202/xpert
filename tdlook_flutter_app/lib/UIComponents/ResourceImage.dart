import 'package:flutter/cupertino.dart';


class ResourceImage extends Image {
  static Image imageWithName(String name, {Color color}) {
    var assetsPath = "lib/Resources/";
    var image = Image.asset(assetsPath + name);
    return image;
  }
}

extension ImageExtension on Image {
  ColorFiltered apply({@required Color color}) {
    return ColorFiltered(child: this, colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
  }
}
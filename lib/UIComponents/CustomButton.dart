import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';

class VerticalButton extends StatefulWidget {
  String imageName;
  String? title;
  String? subtitle;
  bool isSelected = false;

  VerticalButton(this.imageName, {this.title, this.subtitle});

  @override
  _CustomButtonState createState() => _CustomButtonState(imageName, title, subtitle);
}

class _CustomButtonState extends State<VerticalButton> {
  String? imageName;
  String? title;
  String? subtitle;
  bool _isSelected = false;
  Color _backgroundColor = Colors.black;

  _CustomButtonState(this.imageName, this.title, this.subtitle);

  _changeColor(bool isSelected) {
    setState(() {
      _backgroundColor = _isSelected ? Colors.grey : Colors.black;
    });
  }

  @override
  Widget build(BuildContext context) {
    var column = Column(
      children: [
        SizedBox(
          width: 37,
          height: 52,
          child: ResourceImage.imageWithName(imageName ?? ''),
        ),
        CustomText(title ?? ''),
        CustomText(subtitle ?? '')
      ],
    );

    var container = Container(
      color: _backgroundColor,
      child: column,
    );

    var gestureDetector = GestureDetector(
      child: container,
      onTap: () {
        _isSelected = !_isSelected;
        _changeColor(_isSelected);
        debugPrint('MyButton was tapped!');
      },
    );

    return gestureDetector;
  }
}

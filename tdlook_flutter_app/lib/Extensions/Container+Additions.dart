import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';


class SizeProviderWidget extends StatefulWidget {
final Widget child;
final Function(Size) onChildSize;

const SizeProviderWidget({Key key, this.onChildSize, this.child})
: super(key: key);
@override
_SizeProviderWidgetState createState() => _SizeProviderWidgetState();
}

class _SizeProviderWidgetState extends State<SizeProviderWidget> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.onChildSize(context.size);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String iconName;
  final String messageName;
  EmptyStateWidget({Key key, this.iconName, this.messageName}) : super(key:key);

  String _defaultIcon = 'ic_date_empty.png';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build


    return Center(child:
    Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      children: [
      SizedBox(
          width: 40,
          height: 40,
          child: ResourceImage.imageWithName(iconName ?? _defaultIcon)),
      SizedBox(height: 16),
      Text(messageName ?? '', style: TextStyle(color: SharedParameters().optionColor),)]));
  }
}
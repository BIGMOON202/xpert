

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Painter.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';

class EventCompletionGraphWidget  extends StatelessWidget {
  final Event event;
  const EventCompletionGraphWidget({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var eventStatusColor = event.status.displayColor() ?? Colors.white;
    var _descriptionColor = Colors.white.withAlpha(100);//HexColor.fromHex('898A9D');

    var _doublePercent = (event.completeMeasuremensCount /event.totalMeasuremensCount);
      var percent = _doublePercent.isNaN ? 0 : (_doublePercent * 100).toInt();
      var angle = _doublePercent.isNaN ? 0.0 : _doublePercent * 360;
      var w = new Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [CustomPaint(
              painter: CurvePainter(color: eventStatusColor,
                  angle: angle),
              child: SizedBox(width: 45, height: 45,),
            ),
              Text('$percent%', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w400),)],
          ),
          SizedBox(width: 8,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('${event.completeMeasuremensCount}', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('/${event.totalMeasuremensCount}', style: TextStyle(color: _descriptionColor, fontSize: 11, fontWeight: FontWeight.w400))],
          )
        ],
      );
      return w;
  }
}
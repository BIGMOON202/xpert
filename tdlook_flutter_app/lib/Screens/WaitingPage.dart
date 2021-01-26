import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/UpdateMeasurementWorker.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';

class WaitingPage extends StatefulWidget {

  final XFile frontPhoto;
  final XFile sidePhoto;
  final MeasurementResults measurement;
  WaitingPage({Key key, this.measurement, this.frontPhoto, this.sidePhoto}): super(key: key);
  @override
  _WaitingPageState createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> with SingleTickerProviderStateMixin {
  static Color _backgroundColor = HexColor.fromHex('16181B');
  AnimationController animationController;

  UpdateMeasurementBloc _updateMeasurementBloc;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 20),
    );

    animationController.repeat();


    print('MEASUREMENTS:'
        '\nid:${widget.measurement.id}'
        '\ngende: ${widget.measurement.gender},'
        '\nheight:${widget.measurement.height}'
        '\nweight:${widget.measurement.weight}'
        '\nclavicle:${widget.measurement.clavicle}');
    _updateMeasurementBloc = UpdateMeasurementBloc(widget.measurement, widget.frontPhoto, widget.sidePhoto);
    _updateMeasurementBloc.call();
    _updateMeasurementBloc.chuckListStream.listen((event) {
      print('Measurement updated: ${event.data.id}');
      _updateMeasurementBloc.uploadPhotos();
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    var container = Stack(
      children: [
        Center(
          child: SizedBox(
            width: 214,
            height: 214,
              child: new AnimatedBuilder(animation: animationController,
                  child: ResourceImage.imageWithName('logo_waiting.png'),
                  builder: (BuildContext context, Widget _widget) {
                    return new Transform.rotate(
                      angle: animationController.value * 6.3,
                      child: _widget,
                    );
    }
    ) ),
        ),
      Align(
        alignment: Alignment.center,
        child: Text('''CREATING YOUR
            3D MODEL''',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 2,
            ),),


      ],
    );

    var scaffold = Scaffold(
      appBar: AppBar(
        title: Text('The magic is happening'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: _backgroundColor,
      body: container,
    );

    return scaffold;
  }
}
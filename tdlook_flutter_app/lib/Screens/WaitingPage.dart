import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/UpdateMeasurementWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/AnalizeErrorPage.dart';
import 'package:tdlook_flutter_app/Screens/RecommendationsPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:web_socket_channel/io.dart';


class WaitingPageArguments {
  final XFile frontPhoto;
  final XFile sidePhoto;
  final MeasurementResults measurement;
  final bool shouldUploadMeasurements;

  WaitingPageArguments({Key key, this.measurement, this.frontPhoto, this.sidePhoto, this.shouldUploadMeasurements});
}

class WaitingPage extends StatefulWidget {

  static const String route = '/waiting_results';

  WaitingPageArguments arguments;
  WaitingPage({Key key, this.arguments}): super(key: key);
  @override
  _WaitingPageState createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> with SingleTickerProviderStateMixin {
  static Color _backgroundColor = HexColor.fromHex('16181B');
  AnimationController animationController;

  UpdateMeasurementBloc _updateMeasurementBloc;

  String _stateName = '';


  _handleResult(AnalizeResult result) {
    print('move to recomendations');
    animationController.dispose();
    if (result.status != 'error') {
        widget.arguments.measurement.isComplete = true;

        Navigator.pushNamedAndRemoveUntil(context, RecommendationsPage.route, (route) => false,
            arguments: RecommendationsPageArguments(measurement: widget.arguments.measurement, showRestartButton: true));
    } else {

      Navigator.pushNamedAndRemoveUntil(context, AnalizeErrorPage.route, (route) => false,
          arguments: AnalizeErrorPageArguments(
              measurement: widget.arguments.measurement,
              frontPhoto: widget.arguments.frontPhoto,
              sidePhoto: widget.arguments.sidePhoto,
              result: result));
    }
  }

  _show({String error}) {

    Navigator.pushNamedAndRemoveUntil(context, AnalizeErrorPage.route, (route) => false,
        arguments: AnalizeErrorPageArguments(
            measurement: widget.arguments.measurement,
            frontPhoto: widget.arguments.frontPhoto,
            sidePhoto: widget.arguments.sidePhoto,
            errorText: error));


    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (_) => new CupertinoAlertDialog(
    //       // title: new Text("Cupertino Dialog"),
    //       content: new Text(error),
    //       actions: <Widget>[
    //         FlatButton(
    //           child: Text('OK'),
    //           onPressed: () {
    //             Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    //           },
    //         )
    //       ],
    //     ));
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 20),
    );

    animationController.repeat();

    // openSocket();

    print('MEASUREMENTS:'
        '\nid:${widget.arguments.measurement.id}'
        '\ngende: ${widget.arguments.measurement.gender},'
        '\nheight:${widget.arguments.measurement.height}'
        '\nweight:${widget.arguments.measurement.weight}'
        '\nclavicle:${widget.arguments.measurement.clavicle}');
    _updateMeasurementBloc = UpdateMeasurementBloc(widget.arguments.measurement, widget.arguments.frontPhoto, widget.arguments.sidePhoto, widget.arguments.shouldUploadMeasurements);
    _updateMeasurementBloc.call();
    _updateMeasurementBloc.chuckListStream.listen((event) {

      switch (event.status) {
        case Status.LOADING:
          setState(() {
            _stateName = event.message;
          });
          break;

        case Status.COMPLETED:
          _handleResult(event.data);
          break;

        case Status.ERROR:
          _show(error: event.message);
          break;
      }
    });
  }

  openSocket() async {
    var socketLink = 'wss://wlb-expertfit-test.3dlook.me/ws/measurement/${widget.arguments.measurement.uuid}/';
    print('w socket link: ${socketLink}');

    var channel = await IOWebSocketChannel.connect(socketLink);

    channel.stream.listen((message) {
      print('w socket message: $message');
      channel.sink.add('w received!');
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
        child: SizedBox(width: 125, child: Text('${_stateName.toUpperCase()}',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2,
        ),)),
      Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Padding(padding: EdgeInsets.all(12),
            child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6.0)
                ),
                color: Colors.white.withAlpha(10)
            ),
              child: Padding(
                padding: EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                child: Row(
                  children: [SizedBox(width: 30, height: 50, child: ResourceImage.imageWithName('lock_phone_ic.png'),),
                  SizedBox(width: 16,),
                  Flexible(child:Text('Please do not lock your phone. We are computing your measurements and forming your perfect fit.',
                    maxLines: 4,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 12)))],
                ),
              ),
            ),

          ),
        ),
      )

      ],
    );

    var scaffold = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('XpertFit is building your perfect fit'),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      backgroundColor: _backgroundColor,
      body: container,
    );

    return scaffold;
  }
}
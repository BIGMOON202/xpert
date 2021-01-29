import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/UpdateMeasurementWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/RecommendationsPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:web_socket_channel/io.dart';


class WaitingPageArguments {
  final XFile frontPhoto;
  final XFile sidePhoto;
  final MeasurementResults measurement;

  WaitingPageArguments({Key key, this.measurement, this.frontPhoto, this.sidePhoto});
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
    if (result.status != 'error') {
        widget.arguments.measurement.isComplete = true;

        Navigator.pushNamedAndRemoveUntil(context, RecommendationsPage.route, (route) => false,
            arguments: RecommendationsPageArguments(measurement: widget.arguments.measurement, showRestartButton: true));
    } else {
      var textList = result.detail.map((e) => '${e.name}: ${e.message}').toList();
          var text = textList.join("\n");
      _show(error: text);
    }
  }

  _show({String error}) {
    showDialog(
        context: context,
        builder: (_) => new CupertinoAlertDialog(
          // title: new Text("Cupertino Dialog"),
          content: new Text(error),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            )
          ],
        ));
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
    _updateMeasurementBloc = UpdateMeasurementBloc(widget.arguments.measurement, widget.arguments.frontPhoto, widget.arguments.sidePhoto);
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


      ],
    );

    var scaffold = Scaffold(
      appBar: AppBar(
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
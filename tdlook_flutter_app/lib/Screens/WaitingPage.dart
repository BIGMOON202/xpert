import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
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

  WaitingPageArguments(
      {Key key,
      this.measurement,
      this.frontPhoto,
      this.sidePhoto,
      this.shouldUploadMeasurements});
}

class WaitingPage extends StatefulWidget {
  static const String route = '/waiting_results';

  WaitingPageArguments arguments;
  WaitingPage({Key key, this.arguments}) : super(key: key);
  @override
  _WaitingPageState createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static Color _backgroundColor = SessionParameters().mainBackgroundColor;
  AnimationController animationController;

  UpdateMeasurementBloc _updateMeasurementBloc;

  String _stateName = '';

  _handleResult(AnalizeResult result) {
    Screen.keepOn(false);
    print('move to recomendations');
    animationController.dispose();
    _updateMeasurementBloc.dispose();
    if (result.status != 'error') {
      widget.arguments.measurement.isComplete = true;

      Navigator.pushNamedAndRemoveUntil(
          context, RecommendationsPage.route, (route) => false,
          arguments: RecommendationsPageArguments(
              measurement: widget.arguments.measurement,
              showRestartButton: true));
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, AnalizeErrorPage.route, (route) => false,
          arguments: AnalizeErrorPageArguments(
              measurement: widget.arguments.measurement,
              frontPhoto: widget.arguments.frontPhoto,
              sidePhoto: widget.arguments.sidePhoto,
              result: result));
    }
  }

  _show({String error}) {
    Navigator.pushNamedAndRemoveUntil(
        context, AnalizeErrorPage.route, (route) => false,
        arguments: AnalizeErrorPageArguments(
            measurement: widget.arguments.measurement,
            frontPhoto: widget.arguments.frontPhoto,
            sidePhoto: widget.arguments.sidePhoto,
            errorText: error));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Screen.keepOn(true);
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 20),
    );

    animationController.repeat();

    print('MEASUREMENTS:'
        '\nid:${widget.arguments.measurement.id}'
        '\ngende: ${widget.arguments.measurement.gender},'
        '\nheight:${widget.arguments.measurement.height}'
        '\nweight:${widget.arguments.measurement.weight}'
        '\nclavicle:${widget.arguments.measurement.clavicle}');
    _updateMeasurementBloc = UpdateMeasurementBloc(
        widget.arguments.measurement,
        widget.arguments.frontPhoto,
        widget.arguments.sidePhoto,
        widget.arguments.shouldUploadMeasurements);
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _updateMeasurementBloc.updateAppState(state);
  }

  @override
  Widget build(BuildContext context) {
    var container = Stack(
      children: [
        Center(
          child: SizedBox(
              width: 214,
              height: 214,
              child: AnimatedBuilder(
                  animation: animationController,
                  child: ResourceImage.imageWithName('logo_waiting.png'),
                  builder: (BuildContext context, Widget _widget) {
                    return Transform.rotate(
                      angle: animationController.value * 6.3,
                      child: _widget,
                    );
                  })),
        ),
        Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 125,
              child: Text(
                '${_stateName.toUpperCase()}',
                style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
            )),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  color: Colors.white.withAlpha(10)),
              child: Padding(
                padding:
                    EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      height: 50,
                      child: ResourceImage.imageWithName('lock_phone_ic.png'),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Flexible(
                        child: Text(
                            'Please do not lock your phone. We are computing your measurements and forming your perfect fit.',
                            maxLines: 4,
                            style: TextStyle(
                                color: SessionParameters().mainFontColor,
                                fontWeight: FontWeight.normal,
                                fontSize: 12)))
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );

    var scaffold = Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
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

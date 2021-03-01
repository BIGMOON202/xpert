import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'dart:async';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'WaitingPage.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:sensors/sensors.dart';
import 'dart:math' as math;
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Screens/PhotoRulesPage.dart';

class CameraCapturePageArguments {
  final MeasurementResults measurement;
  final PhotoType photoType;
  final XFile frontPhoto;
  final XFile sidePhoto;

  CameraCapturePageArguments({this.measurement, this.photoType, this.frontPhoto, this.sidePhoto});
}

class CameraCapturePage extends StatefulWidget {

  static const String route = '/capture_photo';

  final XFile frontPhoto;
  final XFile sidePhoto;
  final MeasurementResults measurement;
  final PhotoType photoType;
  final Gender gender;
  final CameraCapturePageArguments arguments;

  const CameraCapturePage ({ Key key, this.photoType, this.gender, this.measurement, this.frontPhoto, this.sidePhoto, this.arguments}): super(key: key);


  @override
  _CameraCapturePageState createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {


  XFile _frontPhoto;
  XFile _sidePhoto;

  List<CameraDescription> cameras;
  CameraController controller;
  Future<void> _initializeCameraFuture;

  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];
  bool _gyroIsValid = true;
  bool _isTakingPicture = false;

  double _zAngle = 0;

  @override
  void initState() {
    super.initState();

    print('selectedGender on camera: ${widget.gender.apiFlag()}');


    _frontPhoto = widget.frontPhoto;
    _sidePhoto = widget.sidePhoto;

    initCamera();


    // accelerometerEvents.listen((AccelerometerEvent event) {
    //   setState(() {
    //     print(event.z.abs());
    //     _zAngle = event.z;
    //     _gyroIsValid = !(event.z.abs() > 3);
    //   });
    // });


    _streamSubscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        // print(event.z.abs());
        _zAngle = event.z;
        _gyroIsValid = !(event.z.abs() > 3);
      });
    }));
  }

  double cameraRatio = 1;

  Future<void> initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();

    controller = CameraController(cameras[0], ResolutionPreset.medium);
    _initializeCameraFuture = controller.initialize();
    _initializeCameraFuture.then((_) {
      if (!mounted) {
        return;
      }
      cameraRatio = controller.value.aspectRatio;
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();

    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }

    super.dispose();
  }

  PhotoType activePhotoType() {
    if (widget.arguments != null) {
      return widget.arguments.photoType;
    }
    return widget.photoType;
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    double xScale() {
      return cameraRatio / deviceRatio;
    }
    final yScale = 1;

    void _moveToNextPage() {
      if (widget.arguments == null) {
        if (widget.photoType == PhotoType.front) {


          Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
              PhotoRulesPage(photoType: PhotoType.side,
                  measurement: widget.measurement,
                  frontPhoto: _frontPhoto,
                  gender: widget.gender),
          ));
        } else {

          Navigator.pushNamedAndRemoveUntil(context, WaitingPage.route, (route) => false,
              arguments: WaitingPageArguments(
                  measurement: widget.measurement,
              frontPhoto: _frontPhoto,
              sidePhoto: _sidePhoto, shouldUploadMeasurements: true));
        }
      } else {
        if (widget.arguments.photoType == PhotoType.front) {

          if (widget.arguments.sidePhoto == null) {
            //make side photo

            Navigator.pushNamed(context, CameraCapturePage.route,
                arguments: CameraCapturePageArguments(measurement: widget.arguments.measurement,
                    frontPhoto: _frontPhoto,
                    sidePhoto: widget.arguments.sidePhoto));

          } else {
            //make calculations
            Navigator.pushNamedAndRemoveUntil(context, WaitingPage.route, (route) => false,
                arguments: WaitingPageArguments(
                    measurement: widget.arguments.measurement,
                    frontPhoto: _frontPhoto,
                    sidePhoto: widget.arguments.sidePhoto, shouldUploadMeasurements: false));
          }
        } else {

          //make calculations
          Navigator.pushNamedAndRemoveUntil(context, WaitingPage.route, (route) => false,
              arguments: WaitingPageArguments(
                  measurement: widget.arguments.measurement,
                  frontPhoto: widget.arguments.frontPhoto,
                  sidePhoto: _sidePhoto, shouldUploadMeasurements: false));
        }
      }
    }

    void _handleTap() async {
      setState(() {
        _isTakingPicture = true;
      });
      XFile file = await controller.takePicture();
      // Uint8List imageBytes = await file.readAsBytes();
      // String va = base64Encode(imageBytes);

      setState(() {
        _isTakingPicture = false;
      });

      if (activePhotoType() == PhotoType.front) {
        _frontPhoto = file;
      } else {
        _sidePhoto = file;
      }
      _moveToNextPage();
    }

    var frameWidget = SafeArea(child: Center(child: Padding(padding: EdgeInsets.only(top: 8, left: 40, right: 40, bottom: 34) ,child:
    FittedBox(
      child: ResourceImage.imageWithName(_gyroIsValid ? 'frame_green.png' : 'frame_red.png'),
      fit: BoxFit.fitWidth,
      ),
    ),
    ));

    var rulerContainer = Align(
      alignment: Alignment.centerLeft,
        child: SizedBox(width: 48,
          height: 360,
          child: GyroWidget(angle: _zAngle,),),
    );

    var align = Align(
        alignment: Alignment.bottomCenter,
        child:SafeArea(child: Container(
            width: 100,
            height: 200,
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
                children: [
            Opacity(opacity: _gyroIsValid ? 1.0 : 0.7,
                child: MaterialButton(
              onPressed: _gyroIsValid ? _handleTap : null,
              // textColor: Colors.white,
              child: Stack(
                alignment: Alignment.center,
                  children:[
                ResourceImage.imageWithName('ic_capture.png'),
                    Visibility(visible: _isTakingPicture, child: CircularProgressIndicator())]),
            ))]
            )
        ),
        ));

    if ((controller == null) || (!controller.value.isInitialized)) {
      return Container();
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: activePhotoType() == PhotoType.front ? Text('Front photo') : Text('Side photo'),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: SharedParameters().mainBackgroundColor,
        body: Stack(
        children: [
          FutureBuilder(future: _initializeCameraFuture,
            builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
                aspectRatio: deviceRatio,
                child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(xScale(), 1, 1),
              child: CameraPreview(controller),
              ));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }),
          frameWidget,
          align,
          rulerContainer
        ],
    ));
  }
}

class GyroWidget extends StatefulWidget {
  final double angle;
  const GyroWidget({Key key, this.angle}): super(key: key);
  @override
  _GyroWidgetState createState() => _GyroWidgetState();
}

class _GyroWidgetState extends State<GyroWidget> {


  double _rulerHeight = 360;
  double _arrowHeight = 40;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    double arrowTopOffset() {
      var arrowOffset = _arrowHeight * 0.5;
      var angle = widget.angle._roundToPrecision(0);
      var center = _rulerHeight * 0.5;
      var errorGapValue = (center - 20) / 10;


      var position = (angle * errorGapValue + center);

      // 0 - 360

    return position - arrowOffset;
    }

    var arrow = Positioned(
        top: arrowTopOffset(),
        child: SizedBox(
          width: 8,
          height: _arrowHeight,
          child: ResourceImage.imageWithName('ic_pointer.png'),
    ));


    return Stack(
        children:[Row(children: [Expanded(child:Container()), Expanded(child:Stack(children: [arrow]))]),
          Row(children: [Expanded(flex: 2, child: ResourceImage.imageWithName('ic_gyro_ruler.png')),
    Expanded(child: Container())])]);
  }
}

extension RoundValue on double {
  double _roundToPrecision(int n) {
    int fac = math.pow(10, n);
    return (this * fac).round() / fac;
  }
}
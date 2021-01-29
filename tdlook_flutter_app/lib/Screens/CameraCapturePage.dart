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

class CameraCapturePage extends StatefulWidget {

  final XFile frontPhoto;
  final XFile sidePhoto;
  final MeasurementResults measurement;
  final PhotoType photoType;
  final Gender gender;
  const CameraCapturePage ({ Key key, this.photoType, this.gender, this.measurement, this.frontPhoto, this.sidePhoto}): super(key: key);

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


  @override
  void initState() {
    super.initState();

    print('selectedGender on camera: ${widget.gender.apiFlag()}');


    _frontPhoto = widget.frontPhoto;
    _sidePhoto = widget.sidePhoto;

    initCamera();


    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _gyroIsValid = !(event.z.abs() > 3);
      });
    });


    _streamSubscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
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


  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    double xScale() {
      return cameraRatio / deviceRatio;
    }
    final yScale = 1;

    void _moveToNextPage() {

      if (widget.photoType == PhotoType.front) {
        Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
            PhotoRulesPage(photoType: PhotoType.side, measurement: widget.measurement, frontPhoto: _frontPhoto, gender: widget.gender),
        ));
      } else {

        Navigator.pushNamedAndRemoveUntil(context, WaitingPage.route, (route) => false,
            arguments: WaitingPageArguments(
                measurement: widget.measurement,
            frontPhoto: _frontPhoto,
            sidePhoto: _sidePhoto));
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

      if (widget.photoType == PhotoType.front) {
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
          title: widget.photoType == PhotoType.front ? Text('Front photo') : Text('Side photo'),
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
        ],
    ));
  }
}
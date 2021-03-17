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

  CaptureMode _captureMode;
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

    _captureMode = SessionParameters().captureMode;
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

    var camera = _captureMode == CaptureMode.withFriend ? cameras[0] : cameras[1];
    controller = CameraController(camera, ResolutionPreset.medium);
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

    Widget frameWidget(){
      if (_captureMode == CaptureMode.withFriend) {
        return SafeArea(child: Center(child: Padding(padding: EdgeInsets.only(top: 8, left: 40, right: 40, bottom: 34) ,child:
        FittedBox(
          child: ResourceImage.imageWithName(_gyroIsValid ? 'frame_green.png' : 'frame_red.png'),
          fit: BoxFit.fitWidth,
        ),
        ),
        ));
      } else {

        Widget subWidget() {
          if (_gyroIsValid == false) {
            return Container(
                decoration: BoxDecoration(
                    color: _gyroIsValid ? Colors.transparent : Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.all(Radius.circular(30))
                ),
                child:
          Center(child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Padding(padding: EdgeInsets.only(left:35), child: SizedBox(width: 96, height: 360, child: GyroWidget(angle: _zAngle, captureMode: _captureMode,))),
                SizedBox(height: 39),
                Text('Place your phone vertically on a table.\n\nAngle the phone so that the arrow\nline up on the green.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16))
          ])));
          } else {
            return Container();
          }
        }

        return Container(
          decoration: BoxDecoration(
              border: Border.all(
                width: 10,
                color: _gyroIsValid ? Colors.green : Colors.red,
              ),
              borderRadius: BorderRadius.all(Radius.circular(40))
          ),
          child: subWidget());
      }
    }

    Widget rulerContainer() {
      if (_captureMode == CaptureMode.withFriend) {
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(width: 48,
            height: 360,
            child: GyroWidget(angle: _zAngle, captureMode: _captureMode,),),
        );
      } else {
        return Container();
    }}


      Widget captureButton()  {
      if (_captureMode == CaptureMode.withFriend) {
      return Align(
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
      } else {
        return Container();
      }}

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
          backgroundColor: SessionParameters().mainBackgroundColor,
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
              frameWidget(),
              captureButton(),
              rulerContainer()
            ],
          ));
    }
  }

class GyroWidget extends StatefulWidget {
  final double angle;
  final CaptureMode captureMode;
  const GyroWidget({Key key, this.angle, this.captureMode}): super(key: key);
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
          width: 16,
          height: _arrowHeight,
          child: ResourceImage.imageWithName('ic_pointer.png'),
    ));

    Widget image() {
      if (widget.captureMode == CaptureMode.withFriend) {
        return ResourceImage.imageWithName('ic_gyro_ruler.png');
      } else {
        return ResourceImage.imageWithName('big_gyro.png');
      }
    }

    return Stack(
        children:[Row(children: [Expanded(flex:3, child:Container()), Expanded(flex:2, child:Stack(children: [arrow]))]),
          Row(children: [Expanded(flex: 2, child: image()), Expanded(child: Container())])]);
  }
}

extension RoundValue on double {
  double _roundToPrecision(int n) {
    int fac = math.pow(10, n);
    return (this * fac).round() / fac;
  }
}
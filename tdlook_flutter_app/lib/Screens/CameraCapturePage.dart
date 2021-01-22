import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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

  final PhotoType photoType;
  final Gender gender;
  const CameraCapturePage ({ Key key, this.photoType, this.gender}): super(key: key);

  @override
  _CameraCapturePageState createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {

  List<CameraDescription> cameras;
  CameraController controller;
  Future<void> _initializeCameraFuture;

  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];
  bool _gyroIsValid = true;

  @override
  void initState() {
    super.initState();

    initCamera();

    print('Init _streamSubscriptions');

    accelerometerEvents.listen((AccelerometerEvent event) {
      print(event);

      // var maxAngle = 40.0;
      // var currentAngle = event.z * 180/ math.pi;
      setState(() {
        _gyroIsValid = !(event.z.abs() > 3);
      });
    });

    // userAccelerometerEvents.listen((UserAccelerometerEvent event) {
    //   print(event);
    // });

    // gyroscopeEvents.listen((GyroscopeEvent event) {
    //   setState(() {
    //     var x = event.x;
    //     var y = event.y;
    //     var z = event.z;
    //     _gyroscopeValues = <double>[event.x, event.y, event.z];
    //     print('$x $y $z');
    //   });
    // });
    _streamSubscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _gyroIsValid = !(event.z.abs() > 3);
      });
    }));
  }

  Future<void> initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();

    controller = CameraController(cameras[0], ResolutionPreset.medium);
    _initializeCameraFuture = controller.initialize();
    _initializeCameraFuture.then((_) {
      if (!mounted) {
        return;
      }
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
    void _moveToNextPage() {

      if (widget.photoType == PhotoType.front) {
        Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>

            PhotoRulesPage(photoType: PhotoType.side,),
        ));
      } else {
        Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
            WaitingPage(),
        ));
      }


    }

    void _handleTap() {
      _moveToNextPage();
    }

    var frameWidget = Center(child: Padding(padding: EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 80) ,child:
    FittedBox(
      child: ResourceImage.imageWithName(_gyroIsValid ? 'frame_green.png' : 'frame_red.png'),
      fit: BoxFit.fitWidth,
      ),
    ),
    );;

    var align = Align(
        alignment: Alignment.bottomCenter,
        child:SafeArea(child: Container(
            width: 100,
            height: 200,
            child:
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
                children: [
              // Row(mainAxisAlignment:  MainAxisAlignment.center,
              //   children: [
              //   SizedBox(width: 30,
              //   height: 30, child:
              //     Container(
              //       child: Center( child: Text('1', textAlign: TextAlign.center, style: TextStyle(color: widget.photoType == PhotoType.front ? Colors.black : Colors.white),)),
              //       decoration: new BoxDecoration(
              //         color: widget.photoType == PhotoType.front ? Colors.white : Colors.transparent,
              //         borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              //         border: Border.all(width: 1, color: Colors.white),
              //       ),
              //      ),),
              //   SizedBox(width: 14,),
              //   SizedBox(width: 30,
              //     height: 30, child:
              //     Container(
              //       child: Center(child:Text('2', textAlign: TextAlign.center,style: TextStyle(color: widget.photoType == PhotoType.side ? Colors.black : Colors.white),)),
              //
              //       decoration: new BoxDecoration(
              //           color: widget.photoType == PhotoType.side ? Colors.white : Colors.transparent,
              //           borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              //           border: Border.all(width: 1, color: Colors.white)
              //     ),
              //     ),)
              // ],),
            // SizedBox(height: 20,),
            MaterialButton(

              onPressed: () {
                _handleTap();
                // controller.takePicture();
                print('next button pressed');
              },
              // textColor: Colors.white,
              child: ResourceImage.imageWithName('ic_capture.png'),
              // color: Colors.white,
            )]
            )
        ),
        ));

    if ((controller == null) || (!controller.value.isInitialized)) {
      return Container();
    }
    return Scaffold(
        appBar: AppBar(
          title: widget.photoType == PhotoType.front ? Text('Front photo') : Text('Side photo'),
          backgroundColor: SharedParameters().mainBackgroundColor,
          shadowColor: Colors.transparent,
        ),

        backgroundColor: SharedParameters().mainBackgroundColor,
        body: Stack(
        children: [
          FutureBuilder(future: _initializeCameraFuture,
            builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(controller);
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
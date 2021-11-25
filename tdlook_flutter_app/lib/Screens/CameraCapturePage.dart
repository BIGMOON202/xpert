import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/AnalizeErrorPage.dart';
import 'package:tdlook_flutter_app/Screens/Helpers/HandsFreeAnalizer.dart';
import 'package:tdlook_flutter_app/Screens/Helpers/HandsFreeCaptureStep.dart';
import 'dart:async';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/constants/keys.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock/wakelock.dart';
import 'WaitingPage.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:sensors/sensors.dart';
import 'dart:math' as math;
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Screens/PhotoRulesPage.dart';
import 'package:flutter_picker_view/flutter_picker_view.dart';
import 'package:tdlook_flutter_app/Extensions/XFile+Extension.dart';

class CameraCapturePageArguments {
  final MeasurementResults measurement;
  final PhotoType photoType;
  final XFile frontPhoto;
  final XFile sidePhoto;
  final PhotoError previousPhotosError;
  final Gender gender;


  CameraCapturePageArguments(
      {this.measurement,
      this.photoType,
      this.frontPhoto,
      this.sidePhoto,
      this.previousPhotosError,
      this.gender});
}

class CameraCapturePage extends StatefulWidget {
  static const String route = '/capture_photo';

  final XFile frontPhoto;
  final XFile sidePhoto;
  final MeasurementResults measurement;
  final PhotoType photoType;
  final Gender gender;
  final CameraCapturePageArguments arguments;

  const CameraCapturePage(
      {Key key,
      this.photoType,
      this.gender,
      this.measurement,
      this.frontPhoto,
      this.sidePhoto,
      this.arguments})
      : super(key: key);

  @override
  _CameraCapturePageState createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage>
    with WidgetsBindingObserver {
  HandsFreeAnalizer _handsFreeWorker;
  CaptureMode _captureMode;
  XFile _frontPhoto;
  XFile _sidePhoto;
  PhotoType _photoType;

  List<CameraDescription> cameras;
  CameraController controller;
  Future<void> _initializeCameraFuture;

  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  bool _gyroIsValid = true;
  bool _isTakingPicture = false;

  String _timerText = '';
  double _zAngle = 0;
  bool isMovingToResultAfterHF = false;
  bool isDisposed = false;

  int minAngle = 80;
  int maxAngle = 105;
  var lastGyroData = DateTime.now().millisecondsSinceEpoch;

  
  _moveTodebugSession() async {
    var isSimulator = await Application.isSimulator();
    print('isSimulator: $isSimulator');
    if (isSimulator == true) {
      String _mockFrontImage = 'lib/Resources/frontTest.jpg';
      String _mockSideImage = 'lib/Resources/frontTest.jpg';

      var frontBytes = await rootBundle.load(_mockFrontImage);
      _frontPhoto = await frontBytes.convertToXFile();

      var sideBytes = await rootBundle.load(_mockSideImage);
      _sidePhoto = await sideBytes.convertToXFile();

      _moveToNextPage();
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    print(
        'passed arguments: ${widget.arguments?.frontPhoto} ${widget.arguments?.frontPhoto}');

    if (widget.arguments != null) {
      _photoType = widget.arguments.photoType;
    } else {
      _photoType = widget.photoType;
    }

    print('selectedGender on camera: ${widget.gender.apiFlag()}');

    _captureMode = SessionParameters().captureMode;
    _frontPhoto = widget.frontPhoto;
    _sidePhoto = widget.sidePhoto;



    _moveTodebugSession();
    initCamera();




    // accelerometerEvents.listen((AccelerometerEvent event) {
    //   setState(() {
    //     print(event.z.abs());
    //     _zAngle = event.z;
    //     _gyroIsValid = !(event.z.abs() > 3);
    //   });
    // });

    bool updatedFirstStep = false;
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {

        var newTime = DateTime.now().millisecondsSinceEpoch;

        if ((newTime - lastGyroData) < Application.gyroUpdatesFrequency) {
          return;
        }
        lastGyroData = newTime;

        // print('z:${event.z}');
        _zAngle = event.z;
        var oldGyroPosition = _gyroIsValid;

        _gyroIsValid = !(gyroValueIsValid(value: event.z) || event.x.abs() > 3);

        if (oldGyroPosition == true &&
            _gyroIsValid == false &&
            updatedFirstStep == false) {
          print('update initial step');
          updatedFirstStep = true;
          _setupHandsFreeInitialStepIfNeeded();
        }

        if (oldGyroPosition == true &&
            _gyroIsValid == false &&
            greatSoundPlayedAfterFront == false) {
          print('update initial step');
          greatSoundPlayedAfterFront = true;
          _setupHandsFreeInitialStepIfNeeded();
        }

        _handsFreeWorker?.gyroIsValid = _gyroIsValid;
      });
    }));
  }

  bool gyroValueIsValid({double value}) {
    var convertedValue = 90 + value * 90/10;
    // print('converted: ${convertedValue}');
    return !(convertedValue >= this.minAngle && convertedValue <= this.maxAngle);
  }

  void subscribeOnGyroUpdates() {
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {

        var newTime = DateTime.now().millisecondsSinceEpoch;
        if ((newTime - lastGyroData) < Application.gyroUpdatesFrequency) {
          return;
        }
        lastGyroData = newTime;

        // print('zz:${event.z}');
        _zAngle = event.z;
        var oldGyroPosition = _gyroIsValid;

        _gyroIsValid = !(gyroValueIsValid(value: event.z) || event.x.abs() > 3);

        _handsFreeWorker?.gyroIsValid = _gyroIsValid;
      });
    }));
  }

  double cameraRatio = 1;

  Future<void> initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();

    if (cameras != null && cameras.length != 0) {
      var camera =
      _captureMode == CaptureMode.withFriend ? cameras[0] : cameras[1];
      controller = CameraController(camera, ResolutionPreset.high, enableAudio: false);
      _initializeCameraFuture = controller.initialize();
      _initializeCameraFuture.then((_) {
        if (!mounted) {
          return;
        }

        cameraRatio = controller.value.previewSize.height /
            controller.value.previewSize.width;

        // FlashMode flashMode = _captureMode == CaptureMode.handsFree ? FlashMode.always : FlashMode.off;
        controller.setFlashMode(FlashMode.off);
        controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
        setState(() {
          isDisposed = false;
        });
      });
    }


    if (_captureMode == CaptureMode.handsFree) {
      Wakelock.enable();
      print('_handsFreeWorker init');
      _handsFreeWorker = HandsFreeAnalizer();
      _setupHandsFreeInitialStepIfNeeded();

      // _handsFreeWorker.reset();
      _handsFreeWorker.onCaptureBlock = () {
        print('Should take photo');
        _handleTap();
      };
      _handsFreeWorker.onTimerUpdateBlock = (String val) {
        print('timer text: $val');
        setState(() {
          _timerText = val;
        });
      };
      // _handsFreeWorker.start(andReset: true);
    }
  }



  var greatSoundPlayedAfterFront = false;

  void _setupHandsFreeInitialStepIfNeeded() {
    TFStep initialStep;
    PhotoError previousError = widget?.arguments?.previousPhotosError;
    print('previousError $previousError');
    switch (previousError) {
      case PhotoError.both:
        if (_photoType == PhotoType.front) {
          initialStep =
              _gyroIsValid ? TFStep.retakeFrontIntro : TFStep.retakeFrontGreat;
        } else {
          initialStep = greatSoundPlayedAfterFront
              ? TFStep.retakeSideIntro
              : TFStep.retakeFrontDone;
        }
        break;

      case PhotoError.front:
        initialStep = _gyroIsValid
            ? TFStep.retakeOnlyFrontIntro
            : TFStep.retakeOnlyFrontGreat;
        break;

      case PhotoError.side:
        initialStep = _gyroIsValid
            ? TFStep.retakeOnlySideIntro
            : TFStep.retakeOnlySideGreat;
        break;

      default:
        if (_photoType == PhotoType.front) {
          initialStep = TFStep.frontGreat;
        } else {
          initialStep =
              greatSoundPlayedAfterFront ? TFStep.sideIntro : TFStep.frontDone;
        }
    }

    print('previousError $initialStep');
    _handsFreeWorker?.firstStepInFlow = initialStep;
    _handsFreeWorker?.moveToNextFlowIfGyroIsValid();
  }

  void _cancelGyroUpdates() {
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  void _stopPage() {
    _cancelGyroUpdates();
    _handsFreeWorker?.onCaptureBlock = null;
    _handsFreeWorker?.onTimerUpdateBlock = null;
    _handsFreeWorker?.stopFlow();
    _handsFreeWorker?.dispose(andPlayFinalStep: isMovingToResultAfterHF);
    // _cancelGyroUpdates();

    // setState(() {
    //   controller?.dispose();
    //   controller = null;
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('dipose camera page');
    _cancelGyroUpdates();
    _stopPage();
    controller?.dispose();
    // controller = null;
    print('did dipose camera page');
    super.dispose();
    print('did super dipose camera page');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('appState: $state');
    bool shouldStop = (state != AppLifecycleState.resumed);
    if (shouldStop == true) {
      _cancelGyroUpdates();
    } else {
      subscribeOnGyroUpdates();
    }
    _handsFreeWorker.handleAppState(state);
  }

  PhotoType activePhotoType() {
    return _photoType;
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
    if (SessionParameters().captureMode == CaptureMode.handsFree) {
      if (activePhotoType() == PhotoType.front &&
          widget.arguments?.previousPhotosError != PhotoError.front) {
        greatSoundPlayedAfterFront = false;
        _photoType = PhotoType.side;
        _setupHandsFreeInitialStepIfNeeded();
        // _handsFreeWorker.increaseStep();
      } else {
        _moveToNextPage();
      }
    } else {
      _moveToNextPage();
    }
  }

  void _showPicker() {
    PickerController pickerController = PickerController(count: 2, selectedItems: [minAngle,maxAngle]);

    PickerViewPopup.showMode(
        PickerShowMode.AlertDialog, // AlertDialog or BottomSheet
        controller: pickerController,
        context: context,
        title: Text('AlertDialogPicker',style: TextStyle(fontSize: 14),),
        cancel: Text('cancel', style: TextStyle(color: Colors.grey),),
        onCancel: () {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('AlertDialogPicker.cancel'))
          );
        },
        confirm: Text('confirm', style: TextStyle(color: Colors.blue),),
        onConfirm: (controller) {
          // List<int> selectedItems = [];
          minAngle = controller.selectedRowAt(section: 0);
          maxAngle = controller.selectedRowAt(section: 1);
          // selectedItems.add(controller.selectedRowAt(section: 0));
          // selectedItems.add(controller.selectedRowAt(section: 1));

          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('MIN angle is:$minAngle, MAX angle is: $maxAngle'))
          );
        },
        builder: (context, popup) {
          return Container(
            height: 150,
            child: popup,
          );
        },
        itemExtent: 40,
        numberofRowsAtSection: (section) {
          return 180;
        },
        itemBuilder: (section, row) {
          return Text('$row',style: TextStyle(fontSize: 12),);
        }
    );
  }

  void _moveToNextPage() {
    Wakelock.disable();

    // _handsFreeWorker?.pause();
    // _handsFreeWorker = null;
    if (_captureMode == CaptureMode.handsFree) {
      isMovingToResultAfterHF = true;
    }

    if (_captureMode == CaptureMode.handsFree) {
      _stopPage();
    }
    print('widget.arguments: ${widget.arguments}');
    if (widget.arguments == null) {
      if (_photoType == PhotoType.front) {
        if (Application.isProMode == false) {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (BuildContext context) => PhotoRulesPage(
                    photoType: PhotoType.side,
                    measurement: widget.measurement,
                    frontPhoto: _frontPhoto,
                    gender: widget.gender),
              ));
        } else {
          Navigator.pushNamed(context, CameraCapturePage.route,
              arguments: CameraCapturePageArguments(
                  measurement: widget.arguments.measurement,
                  frontPhoto: _frontPhoto,
                  sidePhoto: widget.arguments.sidePhoto));
        }

      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, WaitingPage.route, (route) => false,
            arguments: WaitingPageArguments(
                measurement: widget.measurement,
                frontPhoto: _frontPhoto,
                sidePhoto: _sidePhoto,
                shouldUploadMeasurements: true));
      }
    } else {
      if (_captureMode == CaptureMode.withFriend) {
        if (_photoType == PhotoType.front) {
          if (widget.arguments.sidePhoto == null) {
            //make side photo

            Navigator.pushNamed(context, CameraCapturePage.route,
                arguments: CameraCapturePageArguments(
                    measurement: widget.arguments.measurement,
                    frontPhoto: _frontPhoto,
                    sidePhoto: widget.arguments.sidePhoto));
          } else {
            //make calculations
            Navigator.pushNamedAndRemoveUntil(
                context, WaitingPage.route, (route) => false,
                arguments: WaitingPageArguments(
                    measurement: widget.arguments.measurement,
                    frontPhoto: _frontPhoto,
                    sidePhoto: widget.arguments.sidePhoto,
                    shouldUploadMeasurements: false));
          }
        } else {
          //make calculations
          Navigator.pushNamedAndRemoveUntil(
              context, WaitingPage.route, (route) => false,
              arguments: WaitingPageArguments(
                  measurement: widget.arguments.measurement,
                  frontPhoto: widget.arguments.frontPhoto,
                  sidePhoto: _sidePhoto,
                  shouldUploadMeasurements: false));
        }
      } else {
        XFile _frontToUpload = _frontPhoto;
        XFile _sideToUpload = _sidePhoto;

        if (widget.arguments.frontPhoto != null) {
          _frontToUpload = widget.arguments.frontPhoto;
        }
        if (widget.arguments.sidePhoto != null) {
          _sideToUpload = widget.arguments.sidePhoto;
        }

        Navigator.pushNamedAndRemoveUntil(
            context, WaitingPage.route, (route) => false,
            arguments: WaitingPageArguments(
                measurement: widget.arguments.measurement,
                frontPhoto: _frontToUpload,
                sidePhoto: _sideToUpload,
                shouldUploadMeasurements: false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    double xScale() {
      return cameraRatio / deviceRatio;
    }

    final yScale = 1;

    Widget frameWidget() {
      if (_captureMode == CaptureMode.withFriend) {
        return SafeArea(
            child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 8, left: 40, right: 40, bottom: 34),
            child: FittedBox(
              child: ResourceImage.imageWithName(
                  _gyroIsValid ? 'frame_green.png' : 'frame_red.png'),
              fit: BoxFit.fitWidth,
            ),
          ),
        ));
      } else {
        Widget subWidget() {
          if (_gyroIsValid == false) {
            return Container(
                decoration: BoxDecoration(
                    color: _gyroIsValid
                        ? Colors.transparent
                        : Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Stack(children: [
                  Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        Padding(
                            padding: EdgeInsets.only(left: 35),
                            child: SizedBox(
                                width: 96,
                                height: 360,
                                child: GyroWidget(
                                  angle: _zAngle,
                                  captureMode: _captureMode,
                                ))),
                        SizedBox(height: 39),
                        Text(
                            'Place your phone vertically on a table.\n\nAngle the phone so that the arrow\nline up on the green.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 16))
                      ]))
                ]));
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
                borderRadius: BorderRadius.all(Radius.circular(40))),
            child: subWidget());
      }
    }

    Widget rulerContainer() {
      if (_captureMode == CaptureMode.withFriend) {
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 48,
            height: 360,
            child: GyroWidget(
              angle: _zAngle,
              captureMode: _captureMode,
            ),
          ),
        );
      } else {
        return Container();
      }
    }

    Widget captureButton() {
      if (_captureMode == CaptureMode.withFriend) {
        return Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                  width: 100,
                  height: 200,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Opacity(
                            opacity: _gyroIsValid ? 1.0 : 0.7,
                            child: MaterialButton(
                              onPressed: _gyroIsValid ? _handleTap : null,
                              // textColor: Colors.white,
                              child:
                                  Stack(alignment: Alignment.center, children: [
                                ResourceImage.imageWithName('ic_capture.png'),
                                Visibility(
                                    visible: _isTakingPicture,
                                    child: CircularProgressIndicator())
                              ]),
                            ))
                      ])),
            ));
      } else {
        return Container();
      }
    }

    if ((controller == null) || (!controller.value.isInitialized)) {
      return Container();
    }
    return VisibilityDetector(
      key: Keys.cameraCapturePageKey,
      onVisibilityChanged: (visibilityInfo) {
        var visiblePercentage = visibilityInfo.visibleFraction * 100;
        if (visiblePercentage == 100) {
          if (isDisposed) {
            initCamera();
          }
        } else {
          controller?.dispose()?.whenComplete(() {
            setState(() {
              isDisposed = true;
            });
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: activePhotoType() == PhotoType.front
              ? Text('Front photo')
              : Text('Side photo'),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        backgroundColor: SessionParameters().mainBackgroundColor,
        body: Stack(
          children: [
            Container(
              color: Colors.black,
              child: FutureBuilder(
                  future: _initializeCameraFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        !isDisposed) {
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
            ),


            frameWidget(),
            captureButton(),
            rulerContainer(),
            Visibility(
                visible: _timerText != '',
                child: Center(
                    child: Text(_timerText,
                        style: TextStyle(fontSize: 270, color: Colors.green)))),
            Visibility(
                visible: _isTakingPicture,
                child: Container(color: Colors.white))
          ],
        ),
      ),
    );
  }
}

class GyroWidget extends StatefulWidget {
  final double angle;
  final CaptureMode captureMode;
  const GyroWidget({Key key, this.angle, this.captureMode}) : super(key: key);
  @override
  _GyroWidgetState createState() => _GyroWidgetState();
}

class _GyroWidgetState extends State<GyroWidget> {
  double _rulerHeight = 360;
  double _arrowHeight = 40;

  bool isDebug = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    double arrowTopOffset() {
      var arrowOffset = _arrowHeight * 0.5;
      var angle = widget.angle;//._roundToPrecision(0);
      var center = _rulerHeight * 0.5;
      var errorGapValue = (center - 300) / 10;

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
        var padding = Padding(
            padding: EdgeInsets.only(top: 15),
          child: ResourceImage.imageWithName('ic_gyro_ruler.png'),
        );
        return padding;
      } else {
        return ResourceImage.imageWithName('big_gyro.png');
      }
    }

    Widget content() {

        return Stack(children: [
          Row(children: [
            Expanded(flex: 3, child: Container()),
            Expanded(flex: 2, child: Stack(children: [arrow]))
          ]),
          Row(children: [
            Expanded(flex: 2, child: image()),
            Expanded(child: Container())
          ])
        ]);
    }

    return content();
  }
}

extension RoundValue on double {
  double _roundToPrecision(int n) {
    int fac = math.pow(10, n);
    return (this * fac).round() / fac;
  }
}

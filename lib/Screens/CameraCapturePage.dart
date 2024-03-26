import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:sensors/sensors.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/XFile+Extension.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Screens/AnalizeErrorPage.dart';
import 'package:tdlook_flutter_app/Screens/Helpers/HandsFreeAnalizer.dart';
import 'package:tdlook_flutter_app/Screens/Helpers/HandsFreeCaptureStep.dart';
import 'package:tdlook_flutter_app/Screens/PhotoRulesPage.dart';
import 'package:tdlook_flutter_app/UIComponents/ResourceImage.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:wakelock/wakelock.dart';

import 'WaitingPage.dart';

class RestartCameraEvent {}

class CameraCapturePageArguments {
  final MeasurementResults? measurement;
  final PhotoType? photoType;
  final XFile? frontPhoto;
  final XFile? sidePhoto;
  final PhotoError? previousPhotosError;
  final Gender? gender;

  CameraCapturePageArguments({
    this.measurement,
    this.photoType,
    this.frontPhoto,
    this.sidePhoto,
    this.previousPhotosError,
    this.gender,
  });
}

class CameraCapturePage extends StatefulWidget {
  static const String route = '/capture_photo';

  final XFile? frontPhoto;
  final XFile? sidePhoto;
  final MeasurementResults? measurement;
  final PhotoType? photoType;
  final Gender? gender;
  final CameraCapturePageArguments? arguments;

  const CameraCapturePage({
    Key? key,
    this.photoType,
    this.gender,
    this.measurement,
    this.frontPhoto,
    this.sidePhoto,
    this.arguments,
  }) : super(key: key);

  @override
  _CameraCapturePageState createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> with WidgetsBindingObserver {
  HandsFreeAnalizer? _handsFreeWorker;
  CaptureMode? _captureMode;
  XFile? _frontPhoto;
  XFile? _sidePhoto;
  PhotoType? _photoType;

  List<CameraDescription>? cameras;
  CameraController? _controller;
  Future<void>? _initializeCameraFuture;

  List<double>? _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];
  bool _gyroIsValid = true;
  bool _isTakingPicture = false;

  String _timerText = '';
  double _zAngle = 0;
  bool isMovingToResultAfterHF = false;
  late bool _isDisposed;

  int minAngle = 80;
  int maxAngle = 105;
  double _cameraRatio = 1;
  var lastGyroData = DateTime.now().millisecondsSinceEpoch;
  PhotoError? get _previousPhotosError => widget.arguments?.previousPhotosError;
  String _displayedFileName = '';
  int _cameraInitVersion = 0;
  late Key _visibilityDetectorWidgetKey;

  _moveTodebugSession() async {
    var isSimulator = await Application.isSimulator();
    logger.d('isSimulator: $isSimulator');
    if (isSimulator == true) {
      String _mockFrontImage = 'lib/Resources/frontTest.jpg';
      String _mockSideImage = 'lib/Resources/frontTest.jpg';

      var frontBytes = await rootBundle.load(_mockFrontImage);
      _frontPhoto = await frontBytes.convertToXFile();

      var sideBytes = await rootBundle.load(_mockSideImage);
      _sidePhoto = await sideBytes.convertToXFile();

      await _moveToNextPage();
    }
  }

  @override
  void didChangeDependencies() {
    // _isDisposed = false;
    // SchedulerBinding.instance.addPostFrameCallback((_) {
    //   _initCamera();
    // });
    super.didChangeDependencies();
  }

  void _onRefresh() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        logger.w('OnRefresh');
        //_isDisposed = true;
        //_initCamera();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    logger.d('passed arguments: ${widget.arguments?.frontPhoto} ${widget.arguments?.frontPhoto}');

    if (widget.arguments != null) {
      _photoType = widget.arguments?.photoType;
    } else {
      _photoType = widget.photoType;
    }
    _visibilityDetectorWidgetKey = Key('CameraCapturePageKey$_photoType');
    //_visibilityDetectorWidgetKey = Key('CameraCapturePageKey');

    logger.d('selectedGender on camera: ${widget.gender?.apiFlag()}');

    _captureMode = SessionParameters().captureMode;
    _frontPhoto = widget.frontPhoto;
    _sidePhoto = widget.sidePhoto;

    _moveTodebugSession();
    _isDisposed = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initCamera();
    });

    //Future.delayed(Duration(seconds: 1)).then((value) => initCamera());

    // accelerometerEvents.listen((AccelerometerEvent event) {
    //   setState(() {
    //    logger.d(event.z.abs());
    //     _zAngle = event.z;
    //     _gyroIsValid = !(event.z.abs() > 3);
    //   });
    // });

    bool updatedFirstStep = false;
    _streamSubscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        var newTime = DateTime.now().millisecondsSinceEpoch;

        if ((newTime - lastGyroData) < Application.gyroUpdatesFrequency) {
          return;
        }
        lastGyroData = newTime;

        //logger.d('z:${event.z}');
        _zAngle = event.z;
        var oldGyroPosition = _gyroIsValid;

        _gyroIsValid = !(gyroValueIsValid(value: event.z) || event.x.abs() > 3);

        if (oldGyroPosition == true && _gyroIsValid == false && updatedFirstStep == false) {
          logger.i('update initial step');
          updatedFirstStep = true;
          _setupHandsFreeInitialStepIfNeeded();
        }

        if (oldGyroPosition == true &&
            _gyroIsValid == false &&
            greatSoundPlayedAfterFront == false) {
          logger.i('update initial step');
          greatSoundPlayedAfterFront = true;
          _setupHandsFreeInitialStepIfNeeded();
        }

        _handsFreeWorker?.gyroIsValid = _gyroIsValid;
      });
    }));
  }

  bool gyroValueIsValid({required double value}) {
    var convertedValue = 90 + value * 90 / 10;
    //logger.d('converted: ${convertedValue}');
    return !(convertedValue >= this.minAngle && convertedValue <= this.maxAngle);
  }

  void subscribeOnGyroUpdates() {
    _streamSubscriptions.add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        var newTime = DateTime.now().millisecondsSinceEpoch;
        if ((newTime - lastGyroData) < Application.gyroUpdatesFrequency) {
          return;
        }
        lastGyroData = newTime;

        //logger.d('zz:${event.z}');
        _zAngle = event.z;
        var oldGyroPosition = _gyroIsValid;

        _gyroIsValid = !(gyroValueIsValid(value: event.z) || event.x.abs() > 3);

        _handsFreeWorker?.gyroIsValid = _gyroIsValid;
      });
    }));
  }

  Future<void> _initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      cameras = await availableCameras();
      logger.d('STARTED... INIT CAMERA');
      if (cameras != null && cameras?.length != 0) {
        final camera = _captureMode == CaptureMode.withFriend ? cameras![0] : cameras![1];
        _controller = CameraController(camera, ResolutionPreset.high, enableAudio: false);
        _cameraInitVersion = _cameraInitVersion + 1;
        _initializeCameraFuture = _controller?.initialize();
        _initializeCameraFuture?.then((_) {
          if (!mounted) {
            return;
          }

          _cameraRatio = (_controller!.value.previewSize?.height ?? 0) /
              (_controller!.value.previewSize?.width ?? 1);

          // FlashMode flashMode = _captureMode == CaptureMode.handsFree ? FlashMode.always : FlashMode.off;
          _controller?.setFlashMode(FlashMode.off);
          _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
          _controller?.resumePreview();
          logger.d('STARTED... $_cameraInitVersion');

          setState(() => _isDisposed = false);
        });

        //await _controller?.resumePreview();
      }

      if (_captureMode == CaptureMode.handsFree) {
        Wakelock.enable();
        logger.i('_handsFreeWorker init');
        _handsFreeWorker = HandsFreeAnalizer();
        _setupHandsFreeInitialStepIfNeeded();

        // _handsFreeWorker.reset();
        _handsFreeWorker?.onCaptureBlock = () {
          logger.i('Should take scan');
          _handleTap();
        };
        _handsFreeWorker?.onTimerUpdateBlock = (String val) {
          logger.d('timer text: $val');
          setState(() {
            _timerText = val;
          });
        };
        _handsFreeWorker?.onFileNameChangedBlock = (String val) {
          setState(() {
            if (_displayedFileName.isEmpty) {
              _displayedFileName = val;
            } else {
              _displayedFileName += ' - $val';
            }
          });
        };
        // _handsFreeWorker.start(andReset: true);
      }
    } on CameraException catch (e) {
      logger.e('CameraException: $e');
      _showSnakMessage('CameraException: $e');
    } catch (e) {
      logger.e('CameraError: $e');
      _showSnakMessage('CameraError: $e');
    } finally {
      logger.e('Finally');
    }
  }

  var greatSoundPlayedAfterFront = false;

  void _setupHandsFreeInitialStepIfNeeded() {
    TFStep? initialStep;
    logger.d('previousError $_previousPhotosError');
    switch (_previousPhotosError) {
      case PhotoError.both:
        if (_photoType == PhotoType.front) {
          initialStep = _gyroIsValid ? TFStep.retakeFrontIntro : TFStep.retakeFrontGreat;
        } else {
          initialStep =
              greatSoundPlayedAfterFront ? TFStep.retakeSideIntro : TFStep.retakeFrontDone;
        }
        break;

      case PhotoError.front:
        initialStep = _gyroIsValid ? TFStep.retakeOnlyFrontIntro : TFStep.retakeOnlyFrontGreat;
        break;

      case PhotoError.side:
        initialStep = _gyroIsValid ? TFStep.retakeOnlySideIntro : TFStep.retakeOnlySideGreat;
        break;

      default:
        if (_photoType == PhotoType.front) {
          initialStep = TFStep.frontGreat;
        } else {
          initialStep = greatSoundPlayedAfterFront ? TFStep.sideIntro : TFStep.frontDone;
        }
    }

    logger.d('[01] initialStep: $initialStep');
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
    logger.i('dipose camera page');
    _cancelGyroUpdates();
    _stopPage();
    //_controller?.dispose();
    logger.i('did dipose camera page');
    super.dispose();
    logger.i('did super dipose camera page');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logger.d('appState: $state');
    bool shouldStop = (state != AppLifecycleState.resumed);
    if (shouldStop == true) {
      _cancelGyroUpdates();
    } else {
      subscribeOnGyroUpdates();
    }
    _handsFreeWorker?.handleAppState(state);
  }

  PhotoType? activePhotoType() {
    return _photoType;
  }

  Future<void> _handleTap() async {
    final bool isInitialized = _controller?.value.isInitialized ?? false;
    if (_isTakingPicture || !isInitialized || _isDisposed) return;
    setState(() => _isTakingPicture = true);
    await Future.delayed(const Duration(milliseconds: 230), () {});

    try {
      XFile? file = await _controller?.takePicture();
      if (Platform.isAndroid && _captureMode == CaptureMode.handsFree && file != null) {
        final File rotatedImage = await FlutterExifRotation.rotateImage(path: file.path);
        file = XFile.fromData(rotatedImage.readAsBytesSync());
      }
      await Future.delayed(const Duration(milliseconds: 230), () {});
      setState(() {
        _isTakingPicture = false;
        logger.d('ARC: _isDisposed = true');
        _isDisposed = true;
      });

      //await Future.delayed(const Duration(milliseconds: 230), () {});

      //await _controller?.dispose();
      // _controller = null;
      await Wakelock.disable();
      await Future.delayed(const Duration(milliseconds: 230), () {});
      // setState(() {
      //   _isTakingPicture = false;
      //   _isDisposed = true;
      // });

      //await Future.delayed(const Duration(milliseconds: 230), () {});

      if (activePhotoType() == PhotoType.front) {
        _frontPhoto = file;
      } else {
        _sidePhoto = file;
      }
      if (SessionParameters().captureMode == CaptureMode.handsFree) {
        if (activePhotoType() == PhotoType.front && _previousPhotosError != PhotoError.front) {
          greatSoundPlayedAfterFront = false;
          _photoType = PhotoType.side;
          _setupHandsFreeInitialStepIfNeeded();
          // _handsFreeWorker.increaseStep();
        } else {
          await _moveToNextPage();
        }
      } else {
        await _moveToNextPage();
      }
    } catch (e) {
      logger.e('Tap error: $e');
      setState(() => _isTakingPicture = false);
      _showSnakMessage('Tap error: $e');
    } finally {
      setState(() => _isTakingPicture = false);
      logger.e('Finnaly tap');
    }
  }

  void _showSnakMessage(String message) {
    if (kDebugMode) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        logger.w('timeStamp: $timeStamp');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      });
    }
  }

  void _delayedPush(VoidCallback callback) {
    Future.delayed(Duration(milliseconds: 330), callback);
  }

  Future<void> _moveToNextPage() async {
    // await Wakelock.disable();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_captureMode == CaptureMode.handsFree) {
        isMovingToResultAfterHF = true;
      }

      if (_captureMode == CaptureMode.handsFree) {
        _stopPage();
      }
      logger.d('widget.arguments: ${widget.arguments}');
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
              ),
            );
          } else {
            Navigator.pushNamed(context, CameraCapturePage.route,
                    arguments: CameraCapturePageArguments(
                        measurement: widget.arguments?.measurement,
                        frontPhoto: _frontPhoto,
                        sidePhoto: widget.arguments?.sidePhoto))
                .then((value) {
              if (value is RestartCameraEvent) {
                _onRefresh();
              }
            });
          }
        } else {
          _delayedPush(
            () => Navigator.pushNamedAndRemoveUntil(
              context,
              WaitingPage.route,
              (route) => false,
              arguments: WaitingPageArguments(
                measurement: widget.measurement,
                frontPhoto: _frontPhoto,
                sidePhoto: _sidePhoto,
                shouldUploadMeasurements: true,
              ),
            ),
          );
        }
      } else {
        if (_captureMode == CaptureMode.withFriend) {
          if (_photoType == PhotoType.front) {
            if (widget.arguments?.sidePhoto == null) {
              //make side photo

              Navigator.pushNamed(context, CameraCapturePage.route,
                      arguments: CameraCapturePageArguments(
                          measurement: widget.arguments?.measurement,
                          frontPhoto: _frontPhoto,
                          sidePhoto: widget.arguments?.sidePhoto))
                  .then((value) {
                if (value is RestartCameraEvent) {
                  _onRefresh();
                }
              });
            } else {
              //make calculations
              _delayedPush(() => Navigator.pushNamedAndRemoveUntil(
                  context, WaitingPage.route, (route) => false,
                  arguments: WaitingPageArguments(
                      measurement: widget.arguments?.measurement,
                      frontPhoto: _frontPhoto,
                      sidePhoto: widget.arguments?.sidePhoto,
                      shouldUploadMeasurements: false)));
            }
          } else {
            //make calculations
            _delayedPush(() => Navigator.pushNamedAndRemoveUntil(
                context, WaitingPage.route, (route) => false,
                arguments: WaitingPageArguments(
                    measurement: widget.arguments?.measurement,
                    frontPhoto: widget.arguments?.frontPhoto,
                    sidePhoto: _sidePhoto,
                    shouldUploadMeasurements: true)));
          }
        } else {
          XFile? _frontToUpload = _frontPhoto;
          XFile? _sideToUpload = _sidePhoto;

          if (widget.arguments?.frontPhoto != null) {
            _frontToUpload = widget.arguments?.frontPhoto;
          }
          if (widget.arguments?.sidePhoto != null) {
            _sideToUpload = widget.arguments?.sidePhoto;
          }

          _delayedPush(
            () => Navigator.pushNamedAndRemoveUntil(
              context,
              WaitingPage.route,
              (route) => false,
              arguments: WaitingPageArguments(
                measurement: widget.arguments?.measurement,
                frontPhoto: _frontToUpload,
                sidePhoto: _sideToUpload,
                shouldUploadMeasurements: false,
              ),
            ),
          );
        }
      }
    });
  }

  Widget _buildCaptureButton() {
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
                    splashColor: Colors.transparent,
                    elevation: 0,
                    onPressed: _gyroIsValid ? _handleTap : null,
                    // textColor: Colors.white,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ResourceImage.imageWithName('ic_capture.png'),
                        Visibility(visible: _isTakingPicture, child: CircularProgressIndicator())
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildFrameWidget() {
    if (_captureMode == CaptureMode.withFriend) {
      return SafeArea(
          child: Center(
        child: Padding(
          padding: EdgeInsets.only(
            top: 8,
            left: 40,
            right: 40,
            bottom: 34,
          ),
          child: FittedBox(
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
              borderRadius: BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                          ),
                        ),
                      ),
                      SizedBox(height: 39),
                      Text(
                        'Place your phone vertically on a table.\n\nAngle the phone so that the arrow\nline up on the green.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
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
        child: subWidget(),
      );
    }
  }

  Widget _buildRuller() {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    double xScale() {
      return _cameraRatio / deviceRatio;
    }

    return VisibilityDetector(
      key: _visibilityDetectorWidgetKey,
      onVisibilityChanged: (visibilityInfo) {
        final visiblePercentage = visibilityInfo.visibleFraction * 100;
        logger
            .d('STARTED... visiblePercentage: $visiblePercentage ($_visibilityDetectorWidgetKey)');
        if (visiblePercentage == 100) {
          if (_isDisposed) {
            _initCamera();
          }
        } else if (visiblePercentage == 0) {
          //_controller?.dispose();
        } else {
          // if (_isPictureTaked) {
          //   _controller?.dispose().whenComplete(() {
          //     _isDisposed = true;
          //   });
          // }
          // _controller?.dispose().whenComplete(() {
          //   setState(() {
          //     _isDisposed = true;
          //   });
          // });

          // _controller?.dispose().whenComplete(() {
          //   setState(() {
          //     _isDisposed = true;
          //   });
          // });
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        extendBodyBehindAppBar: true,
        backgroundColor: SessionParameters().mainBackgroundColor,
        body: Stack(
          children: [
            Container(
              color: Colors.black,
              child: FutureBuilder(
                future: _initializeCameraFuture,
                builder: (context, snapshot) {
                  final bool isInitialized = _controller?.value.isInitialized ?? false;
                  if (snapshot.connectionState == ConnectionState.done &&
                      isInitialized &&
                      !_isDisposed) {
                    return AspectRatio(
                      aspectRatio: deviceRatio,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.diagonal3Values(xScale(), 1, 1),
                        child: _controller!.buildPreview(), // CameraPreview(_controller!),
                      ),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            _buildFrameWidget(),
            _buildCaptureButton(),
            _buildRuller(),
            Visibility(
              visible: _timerText != '',
              child: Center(
                child: Text(
                  _timerText,
                  style: TextStyle(fontSize: 270, color: Colors.green),
                ),
              ),
            ),
            Visibility(
              visible: _isTakingPicture,
              child: Container(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: activePhotoType() == PhotoType.front ? Text('Front scan') : Text('Side scan'),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
    );
  }
}

class GyroWidget extends StatefulWidget {
  final double? angle;
  final CaptureMode? captureMode;
  const GyroWidget({Key? key, this.angle, this.captureMode}) : super(key: key);
  @override
  _GyroWidgetState createState() => _GyroWidgetState();
}

class _GyroWidgetState extends State<GyroWidget> {
  double _rulerHeight = 360;
  double _arrowHeight = 40;

  bool isDebug = false;

  @override
  Widget build(BuildContext context) {
    double arrowTopOffset() {
      var arrowOffset = _arrowHeight * 0.5;
      var angle = widget.angle ?? 0; //._roundToPrecision(0);
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
        Row(children: [Expanded(flex: 2, child: image()), Expanded(child: Container())])
      ]);
    }

    return content();
  }
}

extension RoundValue on double {
  double _roundToPrecision(int n) {
    num fac = math.pow(10, n);
    return (this * fac).round() / fac;
  }
}

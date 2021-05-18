import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:video_player/video_player.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Screens/PhotoRulesPage.dart';

class TutorialStep {
  String text;
  int startDelay;

  TutorialStep(String text, int startDelay) {
    this.text = text;
    this.startDelay = startDelay;
  }
}

class HowTakePhotoPage extends StatefulWidget {

  final Gender gender;
  final MeasurementResults measurements;

  const HowTakePhotoPage ({ Key key, this.gender, this.measurements}): super(key: key);

  @override
  _HowTakePhotoPageState createState() => _HowTakePhotoPageState();
}

class _HowTakePhotoPageState extends State<HowTakePhotoPage>  {


VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  bool _continueButtonEnable = false;
  double _videoProgress = 0.0;
  String _currentStepName = '';
  List<TutorialStep> _steps;
  List<Future> _runningSteps;
  bool _isPlaying = false;
  List<Timer> _activeTimers = List<Timer>();

  Future<bool> _enableContinueTimer() async {
    await Future.delayed(Duration(seconds: SessionParameters().delayForPageAction));
  }

  @override
  void didUpdateWidget(covariant HowTakePhotoPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    print('DID UPDATE');
  }

  void _runContinueButtonTimer() {
    _enableContinueTimer().then((value) {
      setState(() {
        _continueButtonEnable = true;
      });
    });
  }

  Future<void> changeTutorialTextFuture(TutorialStep step) async {

    Timer timer;
    timer = Timer(Duration(seconds: step.startDelay), () {
      _activeTimers.remove(timer);
      setState(() {
        _currentStepName = step.text;
      });
    });
    _activeTimers.add(timer);
    // await Future.delayed(Duration(seconds: step.startDelay));


  }

  // Running multiple futures
  Future _runMultipleFutures() async {
    // Create list of multiple futures
    _runningSteps = List<Future>();
    for(int i = 0; i < _steps.length; i++) {
      _runningSteps.add(changeTutorialTextFuture(_steps[i]));
    }
    // Wait for all futures to complete
    await Future.wait(_runningSteps);
    // We're done with all futures execution
    print('All the futures has completed');
  }

  void _replayAction() {
    setState(() {
      _controller.seekTo(Duration.zero);
      _controller.play();
      _videoProgress = 0;
    });

    _runMultipleFutures();
  }

  void _stopTutorialMessages() {
    for(int i = 0; i < _activeTimers.length; i++) {
      Timer t = _activeTimers[i];
      t.cancel();
    }
  }

  void _checkVideoProgress(){
    // Implement your calls inside these conditions' bodies :

    var progress = 0.0;

    if  (_controller.value.position != null) {
      progress = _controller.value.position.inMilliseconds / _controller.value.duration.inMilliseconds;
    }

    setState(() {
      _videoProgress = progress;
      _isPlaying = true;
    });

    if(_controller.value.position == Duration(seconds: 0, minutes: 0, hours: 0)) {
      // print('video Started');
    }

    if(_controller.value.position == _controller.value.duration) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  void initState() {

    if (SessionParameters().captureMode == CaptureMode.withFriend) {
      _steps = [TutorialStep('Ask someone to help take 2 photos of you. Keep the device at 90° angle at the waistline.', 0),
        TutorialStep('For the side photo turn to your left.', 6)];

      var videoName = widget.gender.friendsModeVideoName;

      _controller = VideoPlayerController.asset('lib/Resources/$videoName');
    } else {
      _steps = [TutorialStep('Stand your device upright on a table.\nYou can use an object to help hold it up.', 0),
        TutorialStep('Angle the phone so that the arrows line up on the green.', 3),
        TutorialStep('Take 3 to 4 steps away from your device.', 7),
        TutorialStep('Please turn up the volume and follow the voice instructions.', 14)];

      var videoName = widget.gender.handsFreeModeVideoName;

      _controller = VideoPlayerController.asset('lib/Resources/$videoName');
    }




    _initializeVideoPlayerFuture = _controller.initialize();

    _controller.setLooping(false);
    _controller.addListener(_checkVideoProgress);



    _initializeVideoPlayerFuture.then((value) {
      print('READY FOR PLAY');

      setState(() {
        _isPlaying = true;
        _controller.play();
      });

      _runMultipleFutures();
    });

    _runContinueButtonTimer();

    super.initState();
  }

  void resetSteps() {
    for(int i = 0; i < _steps.length; i++) {
      _runningSteps.add(changeTutorialTextFuture(_steps[i]));
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    void _moveToNextPage() {
      _controller.pause();
      _stopTutorialMessages();
      _isPlaying = false;
      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
      // RulerPageWeight(),
      PhotoRulesPage(photoType: PhotoType.front, gender: widget.gender, measurement: widget.measurements)
      ));
    }




    var videoLayer = Padding(
      padding: EdgeInsets.only(top: 58, left: 12, right: 12, bottom: 16),
        child: FutureBuilder(

      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(aspectRatio: _controller.value.aspectRatio,
          child:  VideoPlayer(_controller),);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    ));

    var videoLayerContainer = Column(children: [
      Container(
      color: SessionParameters().mainBackgroundColor,
      child: videoLayer,
    ),
    Padding(
      padding: EdgeInsets.only(left: 12, right: 12),
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(SessionParameters().selectionColor),
          backgroundColor: Colors.white.withOpacity(0.1),
      value: _videoProgress,
    )),
    Expanded(
      flex: 2,
        child: Container( child: Align(
        alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.only(left: 12, right: 12),
                        child: Text(_currentStepName, textAlign: TextAlign.center, style: TextStyle(color: Colors.white))),
                SizedBox(width: 120,
                  child: Visibility(
                    visible: !_isPlaying,
                    child:
                FlatButton(child:
                  Row(children: [Icon(Icons.replay, color: SessionParameters().selectionColor,),
                    SizedBox(width: 10,),
                    Container(child: Text('Replay', style: TextStyle(color: SessionParameters().selectionColor),))],
                  ),
                  onPressed: _replayAction,
                ),
                )),
              ]
          )
        )
    //   Center(child:
    //     FlatButton(
    //       color: Colors.orange,
    //       child: Row(children: [Icon(Icons.replay), SizedBox(width: 10,),Text('Replay')],),
    // ),)
    ))
    ]);


    var nextButton = Visibility(

        visible: true,
        child:Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(left:12, right: 12, bottom: 12),
                child: SafeArea(child: Container(
                width: double.infinity,
                child: MaterialButton(
                  disabledColor: SessionParameters().selectionColor.withOpacity(0.5),
                  onPressed: _continueButtonEnable ? _moveToNextPage : null,
                  textColor: Colors.white,
                  child: CustomText('CONTINUE'),
                  color: SessionParameters().selectionColor,
                  height: 50,
                  // padding: EdgeInsets.only(left: 12, right: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  // padding: EdgeInsets.all(4),
                )),
            ))));

    var container = Stack(
      children: [
        nextButton,
        videoLayerContainer
      ],
    );

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('How to take photos'),
          backgroundColor: SessionParameters().mainBackgroundColor,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: SessionParameters().mainBackgroundColor,
        body: container);
  }
}
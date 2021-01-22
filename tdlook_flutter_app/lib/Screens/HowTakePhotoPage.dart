import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Extensions/Customization.dart';
import 'package:tdlook_flutter_app/Extensions/TextStyle+Extension.dart';
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

  const HowTakePhotoPage ({ Key key, this.gender }): super(key: key);

  @override
  _HowTakePhotoPageState createState() => _HowTakePhotoPageState();
}

class _HowTakePhotoPageState extends State<HowTakePhotoPage> {


VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  bool _continueButtonEnable = false;
  double _videoProgress = 0.0;
  String _currentStepName = '';
  List<TutorialStep> _steps;
  List<Future> _runningSteps;
  bool _isPlaying = false;

  Future<bool> _enableContinueTimer() async {
    await Future.delayed(Duration(seconds: 2));
  }

  void _runContinueButtonTimer() {
    print('run timer');
    _enableContinueTimer().then((value) {
      print('timer off');
      setState(() {
        _continueButtonEnable = true;
      });
    });
  }

  Future<void> changeTutorialTextFuture(TutorialStep step) async {
    await Future.delayed(Duration(seconds: step.startDelay));

    setState(() {
      _currentStepName = step.text;
    });
  }

  // Running multiple futures
  Future _runMultipleFutures() async {
    // Create list of multiple futures
    _runningSteps = List<Future>();
    for(int i = 0; i < _steps.length; i++) {
      _runningSteps.add(changeTutorialTextFuture(_steps[i]));
    }
    // Waif for all futures to complete
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

  }

  void _checkVideoProgress(){
    // Implement your calls inside these conditions' bodies :
    var position = _controller.value.position.inMicroseconds;
    var duration = _controller.value.duration.inMicroseconds;

    print('Duration $position - $duration');

    var progress = _controller.value.position.inMilliseconds / _controller.value.duration.inMilliseconds;

    setState(() {
      _videoProgress = progress;
      _isPlaying = true;
    });

    if(_controller.value.position == Duration(seconds: 0, minutes: 0, hours: 0)) {
      print('video Started');
    }

    if(_controller.value.position == _controller.value.duration) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  void initState() {

    _steps = [TutorialStep('Ask someone to help take 2 photos of you. Keep the device at 90° angle at the waistline.', 0),
              TutorialStep('For the side photo turn to your left.', 6)];

    var videoName = widget.gender.friendsModeVideoName;

    _controller = VideoPlayerController.asset('lib/Resources/$videoName');


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
      print('next button pressed');
      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) =>
      // RulerPageWeight(),
        PhotoRulesPage(photoType: PhotoType.front, gender: widget.gender)
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
      color: SharedParameters().mainBackgroundColor,
      child: videoLayer,
    ),
    Padding(
      padding: EdgeInsets.only(left: 12, right: 12),
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(SharedParameters().selectionColor),
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
                  Row(children: [Icon(Icons.replay, color: SharedParameters().selectionColor,),
                    SizedBox(width: 10,),
                    Container(child: Text('Replay', style: TextStyle(color: SharedParameters().selectionColor),))],
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
            child:SafeArea(child: Container(
                width: double.infinity,
                child: MaterialButton(
                  disabledColor: SharedParameters().selectionColor.withOpacity(0.5),
                  onPressed: _continueButtonEnable ? _moveToNextPage : null,
                  textColor: Colors.white,
                  child: CustomText('CONTINUE'),
                  color: SharedParameters().selectionColor,
                  height: 50,
                  // padding: EdgeInsets.only(left: 12, right: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  // padding: EdgeInsets.all(4),
                )),
            )));

    var container = Stack(
      children: [
        nextButton,
        videoLayerContainer
      ],
    );

    return Scaffold(
        appBar: AppBar(
          title: Text('How to take photos'),
          backgroundColor: SharedParameters().mainBackgroundColor,
          shadowColor: Colors.transparent,
        ),
        backgroundColor: SharedParameters().mainBackgroundColor,
        body: container);
  }
}
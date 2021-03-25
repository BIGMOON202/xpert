
import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Extensions/Future+Extension.dart';
import 'package:tdlook_flutter_app/Screens/Helpers/HandsFreeCaptureStep.dart';
import 'dart:developer' as dev;
class HandsFreeWorker {

  static final HandsFreeWorker _instance = HandsFreeWorker._internal();
  HandsFreeWorker._internal() {

    print('init HandsFreeWorker');
    player.fixedPlayer = AudioPlayer();
    player.fixedPlayer?.startHeadlessService();
    // initialization logic
  }

  factory HandsFreeWorker() {
    return _instance;
  }

  bool _isPlaying = false;
  AudioCache player = AudioCache();

  TFStep _step;
  bool _gyroIsValid = false;
  bool _gyroHasChangedDuringStep = false;
  Timer pauseTimer;

  VoidCallback onCaptureBlock;
  ValueChanged<String> onTimerUpdateBlock;

  TFStep _forceFirstStep = TFStep.frontPlacePhoneVertically;

  set forceFistStep(TFStep value) => {
    _forceFirstStep = value,
    if (value == null) {
      _initialStep = value
    }
  };


  TFStep _initialStep;

  set gyroHasChangedDuringStep(bool value) => {
    _gyroHasChangedDuringStep = value
  };

  // set step(TFStep value) => {
  // debugPrint('observer change step: $value'),
  // _step = value,
  // gyroHasChangedDuringStep = false,
  //   handleNewStep(_step)
  // };

  set gyroIsValid(bool value) => {

    if (_gyroIsValid != value) {
      debugPrint('gyroIsValid changed: ${value}, old: ${_gyroIsValid}'),
      _gyroIsValid = value,
      _gyroHasChangedDuringStep = true,
      // handle(isValidGyroChange: value)
    } else {
      _gyroIsValid = value
    }
  };


  void start({bool andReset}) {

    // dev.debugger();
    debugPrint('start and reset: $andReset');
    if (andReset == true) {
      reset();
    }

    debugPrint('initial step: $_initialStep');
    debugPrint('player: ${player.fixedPlayer}');
    if (_isPlaying == true && _step?.couldBeInterrapted() == false) {
      return;
    }

    var firstStep = _forceFirstStep;

    if (_initialStep != null && _gyroHasChangedDuringStep == true && _gyroIsValid == true) {
      debugPrint('2');
      var newStepIndex = _initialStep.index + 1;
      if (TFStep.values.length > newStepIndex) {
        forceFistStep = TFStep.values[newStepIndex];
        firstStep = TFStep.great;
      }

    }

    setNew(firstStep);
  }

  void pause() {

  }

  void reset() {
    print('reset()');
      pauseTimer = null;
      player.fixedPlayer.stop();
      _step = null;
  }

  void handleNewStep(TFStep newStep) async {
      debugPrint('handleNewSte:$newStep');
      // dev.debugger();

      if (newStep == null) {
        debugPrint('newStep == null');
        return;
      }

      if (_isPlaying == true) {
        debugPrint('_isPlaying == true');
        return;
      }

      var audioFile = 'HandsFreeAudio\/${newStep.audioTrackName()}.mp3';

      player.fixedPlayer = AudioPlayer();
      player.fixedPlayer?.startHeadlessService();
      debugPrint('should play: $audioFile');
      await player.play(audioFile);
      debugPrint('playing: $audioFile');
      _isPlaying = true;
      player.fixedPlayer.onPlayerStateChanged.listen((event) {
        print('new player status: ${event}');
        if (event == AudioPlayerState.COMPLETED) {
          _isPlaying = false;
          moveToNextStep();
        }
      });
  }

  void shouldStartWith({TFStep step}) {
    print('shouldStartWith: ${step}');
    _initialStep = step;
    forceFistStep = step;
    if (_gyroIsValid == true) {
      start();
    }
  }
  /*
  func shouldStart(with step: CapturingMessageName?) {
        _initialStep = step
        initialStep = step
        if self.gyroIsValid == true {
            start()
        } else {
//            reset()
        }
    }
   */


  // This function is called once gyro is changed (became valid or invalid)
  void handle({bool isValidGyroChange}) {
  var oldValue = _gyroIsValid;
  gyroIsValid = isValidGyroChange;
  if (oldValue == isValidGyroChange) {
    return;
  }
  print('hanldle new gyro: ${isValidGyroChange}');
    // dev.debugger();

    if (_step == null) {
    print('_step == null');
    // First launch
    start();
  } else if (_step != null && isValidGyroChange == false) {
    print('_step != null && isValidGyroChange == false');
    // Gyro became invalid
    pause();
  } else if (_step != null && isValidGyroChange == true && oldValue == false) {
    print('_step != null && isValidGyroChange == true && oldValue == false');

    // Gyro became valid, but launch "great" sound only if there is no other help command in the queue.
    print('pauseTimer: ${pauseTimer}');
  if (pauseTimer != null) { return; }

    print('_step != null && isValidGyroChange == true && oldValue == false');
    FutureExtension.enableContinueTimer(delay: 2).then((value) {
    if (_gyroIsValid == false) {return;}
    start(andReset: false);
  });
  }
  }

  void setNew(TFStep newStep) {
    debugPrint('setNew step: $newStep');

    void assignNewStep() {
      _step = newStep;
      gyroHasChangedDuringStep = false;
      handleNewStep(_step);
    }

    switch (newStep) {
      case TFStep.frontGreat:
      // case TFStep.retakeFrontGreat:
      // case TFStep.retakeOnlyFrontGreat:
      // case TFStep.retakeOnlySideGreat:
        if (_gyroHasChangedDuringStep == false && _gyroIsValid == true) {
          var newStepIndex = newStep.index + 1;
          if (TFStep.values.length > newStepIndex) {
            setNew(TFStep.values[newStepIndex]);
          }
        } else {
          assignNewStep();
        }
        return;
      default:
        assignNewStep();
        return;
    }
  }

  void resume() {
    moveToNextStep();
  }

  void moveToNextStep() {
    print('moveToNextStep');
    if (_gyroIsValid == false) {
      return;
    }
    print('moveToNextStep 1');

    if (_isPlaying == true && _step?.couldBeInterrapted() == false) {
      return;
    }
    print('moveToNextStep 2');

    print('_step = ${_step}');

    if (_step.restartAfter() == true) {
      start(andReset: true);
      return;
    }

    print('moveToNextStep 3');

    pauseTimer = null;

    if (_step != null && _step.shouldShowTimer() == true) {
      var interval = _step.afterDelayValue();
      var timerInterval = 1.0;
      Timer _timer;
      print('shouldShowTimer');

      const oneSec = const Duration(seconds: 1);
      _timer = new Timer.periodic(
        oneSec,
            (Timer timer) {
          if (interval == 0) {
            // fire complete
            timer.cancel();
            onTimerUpdateBlock('');
          } else {
            interval--;
            print("timer interval $interval");
            onTimerUpdateBlock( interval > 0 ? '${interval.toStringAsFixed(0)}': '');
          }
        },
      );
    }

    var duration = Duration(seconds: _step.afterDelayValue().toInt());
    print('duration');
    pauseTimer = Timer(duration, () {
      print('timer fired after ${duration}');

      if (_gyroIsValid == false) {
        print('_gyroIsValid == false');
        return;
      }

      if (_step.shouldCaptureAfter() == true) {
        onCaptureBlock();
      } else {
        increaseStep();
      }
      pauseTimer = null;
    });

  }

  void increaseStep() {
    print('increaseStep');

    if (_isPlaying == true && _step?.couldBeInterrapted() == false) {
      return;
    }

    var newStepIndex = _step.index + 1;
    print('newStepIndex: $newStepIndex');

    if (TFStep.values.length > newStepIndex) {

      setNew(TFStep.values[newStepIndex]);
    }
  }
}
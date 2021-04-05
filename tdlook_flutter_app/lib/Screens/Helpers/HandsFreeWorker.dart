
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
    // player.fixedPlayer?.startHeadlessService();
    // initialization logic
  }

  factory HandsFreeWorker() {
    return _instance;
  }

  static String _playerID = 'handsFreePlayer';
  static String _tickPlayerID = 'tickPlayerID';

  bool _isPlaying = false;
  AudioCache player = AudioCache();

  TFStep _step;
  bool _gyroIsValid = false;
  bool _gyroHasChangedDuringStep = false;
  Timer pauseTimer;

  VoidCallback onCaptureBlock;
  ValueChanged<String> onTimerUpdateBlock;

  TFStep _forceFirstStep = TFStep.frontGreat;

  set forceFistStep(TFStep value) => {
  print('set forceFistStep ${value}'),
  _forceFirstStep = value,
    if (value == null) {
      _initialStep = value
    }
  };


  TFStep _initialStep;

  set gyroHasChangedDuringStep(bool value) => {
    _gyroHasChangedDuringStep = value
  };

  set gyroIsValid(bool value) => {

    if (_gyroIsValid != value) {
      debugPrint('gyroIsValid will change: ${value}, old: ${_gyroIsValid}'),
      _gyroHasChangedDuringStep = true,
      handle(isValidGyroChange: value)
    },
    _gyroIsValid = value
  };


  AudioCache _tickPlayer;
  void _playSound(TFOptionalSound sound) {
    if (_tickPlayer == null) {
      _tickPlayer = AudioCache();
    }
    var audioFile = 'HandsFreeAudio\/${sound.fileName}.mp3';
    _tickPlayer.respectSilence = sound.respectsSilentMode;
    _tickPlayer.fixedPlayer.setReleaseMode(ReleaseMode.STOP);
    debugPrint('should play tick: $audioFile');
    _tickPlayer.play(audioFile);
  }


  void start({bool andReset}) {

    // dev.debugger();
    TFStep _firstStep;

    debugPrint('start and reset: $andReset');
    if (andReset == true) {
      reset();
      _firstStep = _forceFirstStep;
    } else {
      _firstStep = _initialStep;
      var newStepIndex = _initialStep.index + 1;
      if (TFStep.values.length > newStepIndex) {
        _firstStep = TFStep.values[newStepIndex];
      }
    }

    debugPrint('initial step: ${_initialStep.toString()}');
    debugPrint('player: ${player.fixedPlayer}');
    if (_isPlaying == true && _step?.couldBeInterrapted() == false) {
      return;
    }

    setNew(_firstStep);
  }

  void pause() {
    print('called pause');
    _captureTimer?.cancel();
    _captureTimer = null;
    player.fixedPlayer?.stop();
    pauseTimer = null;
    onTimerUpdateBlock('');

    checkGyroIn5sec();
  }

  void reset() {
    print('reset()');

    forceFistStep = _initialStep;
    _captureTimer?.cancel();
    _captureTimer = null;
    pauseTimer?.cancel();
    pauseTimer = null;
    _step = null;
    player.fixedPlayer.stop();
  }

  void stop() {
    print('stop()');
    _captureTimer?.cancel();
    _captureTimer = null;
    pauseTimer?.cancel();
    pauseTimer = null;
    _step = null;
    player.fixedPlayer.stop();
    _tickPlayer?.fixedPlayer?.release();
    _tickPlayer?.fixedPlayer?.stop();
  }


  void handleNewStep(TFStep newStep) async {
      debugPrint('handleNewSte: ${newStep.toString()}');
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

      player.fixedPlayer = AudioPlayer(playerId: _playerID);
      player.fixedPlayer?.startHeadlessService();
      debugPrint('should play: $audioFile');
      _isPlaying = true;
      await player.play(audioFile);
      debugPrint('playing: $audioFile');
      player.fixedPlayer.onPlayerStateChanged.listen((event) {
        print('new player status: ${event}');
        if (event != AudioPlayerState.PLAYING) {
          _isPlaying = false;
        }

        if (event == AudioPlayerState.COMPLETED) {
          if (_step == null) {
            return;
          }
          moveToNextStep();
        }
      });
  }

  void shouldStartWith({TFStep step}) {
    print('shouldStartWith: ${step.toString()}');
    _initialStep = step;
    forceFistStep = step;
    if (_gyroIsValid == true) {
      start();
    }
  }

  // This function is called once gyro is changed (became valid or invalid)
  void handle({bool isValidGyroChange}) {
  var oldValue = _gyroIsValid;
  gyroIsValid = isValidGyroChange;
  if (oldValue == isValidGyroChange) {
    return;
  }

  Timer _checkGyroAfter2Sec;
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
    if (pauseTimer != null) {
      print('pauseTimer != null');
      return;
    }

      print('enableContinueTimer for 2 seconds before continue after gyro is ok');
    if (_checkGyroAfter2Sec != null) {
      print('_checkGyroAfter2Sec != null');
      return;
    }
    print('will checkGyroAfter2Sec');
    const duration = const Duration(seconds: 1);
    _checkGyroAfter2Sec = Timer(duration, () {
      debugPrint('checking gyro after 2 sec');
      _checkGyroAfter2Sec = null;
      if (_gyroIsValid == false) {
        debugPrint('checked gyro after 2 sec: _gyroIsValid == false');
        return;}
      // moveToNextStep();
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
      // case TFStep.frontGreat:
      // // case TFStep.retakeFrontGreat:
      // // case TFStep.retakeOnlyFrontGreat:
      // // case TFStep.retakeOnlySideGreat:
      //   if (_gyroHasChangedDuringStep == false && _gyroIsValid == true) {
      //     var newStepIndex = newStep.index + 1;
      //     if (TFStep.values.length > newStepIndex) {
      //       setNew(TFStep.values[newStepIndex]);
      //     }
      //   } else {
      //     assignNewStep();
      //   }
      //   return;
      default:
        assignNewStep();
        return;
    }
  }

  Timer _captureTimer;
  Timer checkGyroTimer;

  ///check is gyro is still incorrect - if so, replay intro
  void checkGyroIn5sec() {
    debugPrint('check gyro after 5 sec');
    if (checkGyroTimer != null) {
      debugPrint('checkGyroTimer != null');
      return;
    }

    const duration = const Duration(seconds: 5);
    checkGyroTimer = Timer(duration, () {

      debugPrint('checked gyro after 5 sec');
      checkGyroTimer = null;

      if (_gyroIsValid == true || _step == null) {return;}
      start(andReset: true);
    });
  }

  void moveToNextStep() {
    print('moveToNextStep');
    if (_gyroIsValid == false) {
      checkGyroIn5sec();
      return;
    } else {
      checkGyroTimer = null;
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
      print('shouldShowTimer');

      const oneSec = const Duration(seconds: 1);
      _captureTimer = new Timer.periodic(
        oneSec,
            (Timer timer) {

          if (interval == 0) {

            // fire complete
            timer.cancel();
            onTimerUpdateBlock('');
            _captureTimer = null;

          } else {
            _playSound(TFOptionalSound.tick);
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
        _playSound(TFOptionalSound.capture);
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
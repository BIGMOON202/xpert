import 'dart:async';
import 'dart:io' show Platform;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Screens/Helpers/HandsFreeCaptureStep.dart';
import 'package:tdlook_flutter_app/utilt/logger.dart';

class HandsFreeWorker {
  static final HandsFreeWorker _instance = HandsFreeWorker._internal();
  HandsFreeWorker._internal() {
    logger.i('init HandsFreeWorker');
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

  TFStep? _step;
  bool _gyroIsValid = false;
  bool _gyroHasChangedDuringStep = false;
  Timer? pauseTimer;

  VoidCallback? onCaptureBlock;
  ValueChanged<String>? onTimerUpdateBlock;

  TFStep? _forceFirstStep = TFStep.frontGreat;

  set forceFistStep(TFStep? value) => {
        logger.d('set forceFistStep ${value}'),
        _forceFirstStep = value,
        if (value == null) {_initialStep = value}
      };

  TFStep? _initialStep;

  set gyroHasChangedDuringStep(bool value) => {_gyroHasChangedDuringStep = value};

  set gyroIsValid(bool value) => {
        if (_gyroIsValid != value)
          {
            logger.d('gyroIsValid will change: ${value}, old: ${_gyroIsValid}'),
            _gyroHasChangedDuringStep = true,
            handle(isValidGyroChange: value)
          },
        _gyroIsValid = value
      };

  AudioCache? _tickPlayer;
  void _playSound(TFOptionalSound sound) {
    if (_tickPlayer == null) {
      _tickPlayer = AudioCache();
    }
    var audioFile = 'HandsFreeAudio\/${sound.fileName}.mp3';
    _tickPlayer?.respectSilence = sound.respectsSilentMode;
    _tickPlayer?.fixedPlayer?.setReleaseMode(ReleaseMode.STOP);
    logger.d('should play tick: $audioFile');
    _tickPlayer?.play(audioFile);
  }

  void start({bool? andReset}) {
    // dev.debugger();
    TFStep? _firstStep;

    logger.d('start and reset: $andReset');
    if (andReset == true) {
      reset();
      _firstStep = _forceFirstStep;
    } else {
      _firstStep = _initialStep;
      var newStepIndex = (_initialStep?.index ?? 0) + 1;
      if (TFStep.values.length > newStepIndex) {
        _firstStep = TFStep.values[newStepIndex];
      }
    }

    logger.d('initial step: ${_initialStep.toString()}');
    logger.d('player: ${player.fixedPlayer}');
    if (_isPlaying == true && _step?.couldBeInterrapted() == false) {
      return;
    }

    setNew(_firstStep);
  }

  void pause() {
    logger.i('called pause');
    _captureTimer?.cancel();
    _captureTimer = null;
    player.fixedPlayer?.stop();
    pauseTimer = null;
    onTimerUpdateBlock?.call('');

    checkGyroIn5sec();
  }

  void reset() {
    logger.i('reset()');

    forceFistStep = _initialStep;
    _captureTimer?.cancel();
    _captureTimer = null;
    pauseTimer?.cancel();
    pauseTimer = null;
    _step = null;
    player.fixedPlayer?.stop();
  }

  void stop() {
    logger.i('stop()');
    _captureTimer?.cancel();
    _captureTimer = null;
    pauseTimer?.cancel();
    pauseTimer = null;
    _step = null;
    player.fixedPlayer?.stop();
    _tickPlayer?.fixedPlayer?.release();
    _tickPlayer?.fixedPlayer?.stop();
  }

  void handleNewStep(TFStep? newStep) async {
    logger.d('handleNewSte: ${newStep.toString()}');
    // dev.debugger();

    if (newStep == null) {
      logger.i('newStep == null');
      return;
    }

    if (_isPlaying == true) {
      logger.i('_isPlaying == true');
      return;
    }

    var audioFile = 'HandsFreeAudio\/${newStep.audioTrackName()}.mp3';

    player.fixedPlayer = AudioPlayer(playerId: _playerID);
    if (Platform.isIOS) {
      player.fixedPlayer?.notificationService.startHeadlessService();
    }
    logger.d('should play: $audioFile');
    _isPlaying = true;
    await player.play(audioFile);
    logger.d('playing: $audioFile');
    player.fixedPlayer?.onPlayerStateChanged.listen((event) {
      logger.d('new player status: $event');
      if (event != PlayerState.PLAYING) {
        _isPlaying = false;
      }

      if (event == PlayerState.COMPLETED) {
        if (_step == null) {
          return;
        }
        moveToNextStep();
      }
    });
  }

  void shouldStartWith({TFStep? step}) {
    logger.d('shouldStartWith: ${step.toString()}');
    _initialStep = step;
    forceFistStep = step;
    if (_gyroIsValid == true) {
      start();
    }
  }

  // This function is called once gyro is changed (became valid or invalid)
  void handle({required bool isValidGyroChange}) {
    var oldValue = _gyroIsValid;
    gyroIsValid = isValidGyroChange;
    if (oldValue == isValidGyroChange) {
      return;
    }

    Timer? _checkGyroAfter2Sec;
    logger.d('hanldle new gyro: $isValidGyroChange');
    // dev.debugger();

    if (_step == null) {
      logger.i('_step == null');
      // First launch
      start();
    } else if (_step != null && isValidGyroChange == false) {
      logger.i('_step != null && isValidGyroChange == false');
      // Gyro became invalid
      pause();
    } else if (_step != null && isValidGyroChange == true && oldValue == false) {
      logger.i('_step != null && isValidGyroChange == true && oldValue == false');

      // Gyro became valid, but launch "great" sound only if there is no other help command in the queue.
      logger.d('pauseTimer: $pauseTimer');
      if (pauseTimer != null) {
        logger.i('pauseTimer != null');
        return;
      }

      logger.i('enableContinueTimer for 2 seconds before continue after gyro is ok');
      if (_checkGyroAfter2Sec != null) {
        logger.i('_checkGyroAfter2Sec != null');
        return;
      }
      logger.i('will checkGyroAfter2Sec');
      const duration = const Duration(seconds: 1);
      _checkGyroAfter2Sec = Timer(duration, () {
        logger.i('checking gyro after 2 sec');
        _checkGyroAfter2Sec = null;
        if (_gyroIsValid == false) {
          logger.i('checked gyro after 2 sec: _gyroIsValid == false');
          return;
        }
        // moveToNextStep();
        start(andReset: false);
      });
    }
  }

  void setNew(TFStep? newStep) {
    logger.d('setNew step: $newStep');

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

  Timer? _captureTimer;
  Timer? checkGyroTimer;

  ///check is gyro is still incorrect - if so, replay intro
  void checkGyroIn5sec() {
    logger.i('check gyro after 5 sec');
    if (checkGyroTimer != null) {
      logger.i('checkGyroTimer != null');
      return;
    }

    const duration = const Duration(seconds: 5);
    checkGyroTimer = Timer(duration, () {
      logger.i('checked gyro after 5 sec');
      checkGyroTimer = null;

      if (_gyroIsValid == true || _step == null) {
        return;
      }
      start(andReset: true);
    });
  }

  void moveToNextStep() {
    logger.i('moveToNextStep');
    if (_gyroIsValid == false) {
      checkGyroIn5sec();
      return;
    } else {
      checkGyroTimer = null;
    }
    logger.i('moveToNextStep 1');

    if (_isPlaying == true && _step?.couldBeInterrapted() == false) {
      return;
    }
    logger.i('moveToNextStep 2');

    logger.d('_step = $_step');

    if (_step?.restartAfter() == true) {
      start(andReset: true);
      return;
    }

    logger.i('moveToNextStep 3');

    pauseTimer = null;

    if (_step != null && _step?.shouldShowTimer() == true) {
      var interval = _step?.afterDelayValue() ?? 0;
      var timerInterval = 1.0;
      logger.i('shouldShowTimer');

      const oneSec = const Duration(seconds: 1);
      _captureTimer = Timer.periodic(
        oneSec,
        (Timer timer) {
          if (interval == 0) {
            // fire complete
            timer.cancel();
            onTimerUpdateBlock?.call('');
            _captureTimer = null;
          } else {
            _playSound(TFOptionalSound.tick);
            interval--;
            logger.d("timer interval $interval");
            onTimerUpdateBlock?.call(interval > 0 ? '${interval.toStringAsFixed(0)}' : '');
          }
        },
      );
    }

    var duration = Duration(seconds: _step?.afterDelayValue().toInt() ?? 0);
    logger.i('duration');
    pauseTimer = Timer(duration, () {
      logger.d('timer fired after ${duration}');

      if (_gyroIsValid == false) {
        logger.i('_gyroIsValid == false');
        return;
      }

      if (_step?.shouldCaptureAfter() == true) {
      
        _playSound(TFOptionalSound.capture);
        if (onCaptureBlock != null) {
          Timer(Duration(milliseconds: 400), onCaptureBlock!);
        }
        //onCaptureBlock?.call();
      } else {
        increaseStep();
      }
      pauseTimer = null;
    });
  }

  void increaseStep() {
    logger.i('increaseStep');

    if (_isPlaying == true && _step?.couldBeInterrapted() == false) {
      return;
    }

    var newStepIndex = (_step?.index ?? 0) + 1;
    logger.d('newStepIndex: $newStepIndex');

    if (TFStep.values.length > newStepIndex) {
      setNew(TFStep.values[newStepIndex]);
    }
  }
}

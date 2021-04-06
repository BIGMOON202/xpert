

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Screens/Helpers/HandsFreeCaptureStep.dart';
import 'package:tdlook_flutter_app/Screens/Helpers/HandsFreePlayer.dart';

class HandsFreeAnalizer {
  static final HandsFreeAnalizer _instance = HandsFreeAnalizer._internal();
  HandsFreeAnalizer._internal() {
    _player = HandsFreePlayer();
  }

  factory HandsFreeAnalizer() {
    return _instance;
  }

  HandsFreePlayer _player;
  TFStep firstStepInFlow;
  TFStep _currentStep;
  bool _gyroIsValid;

  Timer _timerCheckGyroEvery5Sec;
  Timer _timerCheckGyroIsStillValid;

  VoidCallback get onCaptureBlock {
    return _player.onCaptureBlock;
  }
  set onCaptureBlock(VoidCallback value) => {
    _player.onCaptureBlock = value
  };

  ValueChanged<String> get onTimerUpdateBlock {
    return _player.onTimerUpdateBlock;
  }
  set onTimerUpdateBlock(ValueChanged<String> value) => {
    _player.onTimerUpdateBlock = value
  };

  set gyroIsValid(bool value) => {
    if (_gyroIsValid != value) {
      handle(isValidGyroChange: value)
    },
    _gyroIsValid = value
  };

  void handle({bool isValidGyroChange}) {

    var oldValue = _gyroIsValid;
    var newValue = isValidGyroChange;

    if (oldValue == newValue) {
      return;
    }

    if (newValue == true) {
      _checkGyroAfter2SecondsOfGreen();
      //wait for 2 seconds and after this start flow from first step

    } else if (newValue == false) {
      gyroBecameInvalid();
      // stop and play sound to put phone vertically
    }
  }

  void _checkGyroAfter2SecondsOfGreen() {
    print('_checkGyroAfter2SecondsOfGreen');
    _player.stop();
    // cancel checking gyro - because it became valid
    _timerCheckGyroEvery5Sec?.cancel();

    if (_timerCheckGyroIsStillValid?.isActive == true) {
      return;
    }
    _timerCheckGyroIsStillValid = Timer(Duration(seconds: 2), () {
      if (_gyroIsValid == true) {
        startFlow();
      }
    });
  }

  void dispose() {

    print('dispose handsFree');
    _gyroIsValid = null;
    _player.stop();
    _timerCheckGyroIsStillValid?.cancel();
    _timerCheckGyroEvery5Sec?.cancel();
  }

  void startFlow() {
    print('start');
    _currentStep = firstStepInFlow;
    _player.playStep(step: _currentStep);
  }

  void stopFlow() {
    _timerCheckGyroIsStillValid?.cancel();
    _currentStep = null;
  }

  void gyroBecameInvalid() {
    // cancel checking gyro - because it became invalid

    stopFlow();
    isGyroStillInvalid();
  }

  void isGyroStillInvalid() {
    print('isGyroStillInvalid');
    onTimerUpdateBlock('');

    _player.stop();
    if (_timerCheckGyroEvery5Sec?.isActive == true) {
      return;
    }

    _player.playSound(sound: _placeVerticallySoundName());

    //8 sec for track + 5 sec for pause between
    _timerCheckGyroEvery5Sec = Timer(Duration(seconds: 5 + 8), () {
      if (_gyroIsValid == false) {
        isGyroStillInvalid();
      }
    });
  }

  void moveToNextFlowIfGyroIsValid() {
    if (_gyroIsValid == true) {
      startFlow();
    }
  }

  void handleAppState(AppLifecycleState state) {
    bool shouldStop = (state != AppLifecycleState.resumed);
    print('should Stop HF: $shouldStop');
    if (shouldStop == true) {
      stopFlow();
      dispose();
    } else {
      isGyroStillInvalid();
    }
    // _player.setSound(on: shouldStop);
  }

  TFOptionalSound _placeVerticallySoundName() {
    switch (firstStepInFlow) {
      case TFStep.retakeFrontIntro:
      case TFStep.retakeFrontGreat:
      case TFStep.retakeOnlyFrontIntro:
      case TFStep.retakeOnlyFrontGreat:
        return TFOptionalSound.placePhoneRetakeFront;

      case TFStep.retakeOnlySideIntro:
      case TFStep.retakeOnlySideGreat:
        return TFOptionalSound.placePhoneRetakeOnlySide;

      default:
        return TFOptionalSound.placePhone;
    }
  }

}

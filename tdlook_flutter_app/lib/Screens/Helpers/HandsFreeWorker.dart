
import 'dart:async';

import 'package:tdlook_flutter_app/Extensions/Future+Extension.dart';

enum TFStep {
  frontPlacePhoneVertically, frontGreat, frontTakeSteps, frontCheckBody, frontCheckFeet, frontHoldPosition, frontDone,
  sideIntro, sideTurnBody, sideStayStill, sideDone
}

class HandsFreeWorker {

  static final HandsFreeWorker _instance = HandsFreeWorker._internal();
  HandsFreeWorker._internal() {
    // initialization logic
  }

  factory HandsFreeWorker() {
    return _instance;
  }



  String audioTrackName() {

    switch (_step) {
    case TFStep.frontPlacePhoneVertically:    return "tf1.1";
    case TFStep.frontGreat:                   return "tf1.2";
    case TFStep.frontTakeSteps:               return "tf1.3";
    case TFStep.frontCheckBody:               return "tf1.4";
    case TFStep.frontCheckFeet:               return "tf1.5";
    case TFStep.frontHoldPosition:            return "tf1.6";
    case TFStep.frontDone:                    return "tf1.7";

    case TFStep.sideIntro:                    return "tf2.1";
    case TFStep.sideTurnBody:                 return "tf2.2";
    case TFStep.sideStayStill:                return "tf2.3";
    case TFStep.sideDone:                     return "tf2.4";

    // case .retakeFrontIntro:             return "tf3.1"
    // case .retakeFrontGreat:             return "tf3.2"
    // case .retakeFrontTakeSteps:         return "tf3.3"
    // case .retakeFrontCheckFeet:         return "tf3.4"
    // case .retakeFrontHoldPosition:      return "tf1.6"
    // case .retakeFrontDone:              return "tf3.5"
    //
    // case .retakeSideIntro:              return "tf4.1"
    // case .retakeSideTurnBody:           return "tf4.2"
    // case .retakeSideStayStill:          return "tf4.3"
    // case .retakeSideDone:               return "tf4.4"
    //
    // case .retakeOnlyFrontIntro:         return "tf5.1"
    // case .retakeOnlyFrontGreat:         return "tf5.2"
    // case .retakeOnlyFrontTakeSteps:     return "tf5.3"
    // case .retakeOnlyFrontCheckBody:     return "tf5.4"
    // case .retakeOnlyFrontCheckFeet:     return "tf5.5"
    // case .retakeOnlyFrontHoldPosition:  return "tf5.6"
    // case .retakeOnlyFrontDone:          return "tf5.7"
    //
    // case .retakeOnlySideIntro:          return "tf6.1"
    // case .retakeOnlySideGreat:          return "tf6.2"
    // case .retakeOnlySideTakeSteps:      return "tf6.3"
    // case .retakeOnlySideCheckBody:      return "tf6.4"
    // case .retakeOnlySideTurnBody:       return "tf6.5"
    // case .retakeOnlySideStayStill:      return "tf6.6"
    // case .retakeOnlySideDone:           return "tf6.7"

    // case .great:                        return "tf1.2"
    }
  }

  double afterDelayValue() {
  switch (_step) {
    // case TFStep.great:
    // return 2.0
    case TFStep.frontPlacePhoneVertically: return 2.0;

    case TFStep.frontTakeSteps: return 3.0;
    case TFStep.frontHoldPosition:

    // case TFStep.retakeFrontHoldPosition:
    //
    // case TFStep. retakeOnlyFrontHoldPosition:

    case TFStep.sideStayStill: return 4;

    // case TFStep.retakeSideStayStill:
    //
    // case TFStep.retakeOnlySideStayStill:

    default: return 1;
    }
  }

  bool shouldShowTimer() {
    switch (_step) {
    case TFStep.frontHoldPosition:

    // case TFStep.retakeFrontHoldPosition:
    //
    // case TFStep. retakeOnlyFrontHoldPosition:
    //
    case TFStep.sideStayStill:

    // case TFStep.retakeSideStayStill:
    //
    // case TFStep.retakeOnlySideStayStill:
    return true;

    default:
    return false;
    }
  }

  bool shouldCaptureAfter() {

    switch (_step) {
    case TFStep.frontHoldPosition:

    // case TFStep.retakeFrontHoldPosition:
    //
    // case TFStep.retakeOnlyFrontHoldPosition:
    //
    case TFStep.sideStayStill:

    // case TFStep.retakeSideStayStill:
    //
    // case TFStep.retakeOnlySideStayStill:
    return true;

    default:
    return false;
    }
  }

  bool restartAfter() {
  switch (_step) {
  // case TFStep.great:
  //   // return true
  default:
  return false;
  }
  }

  TFStep _step;
  bool _gyroIsValid = false;
  bool _gyroHasChangedDuringStep = false;
  Timer pauseTimer;

  set gyroHasChangedDuringStep(bool value) => {


    _gyroHasChangedDuringStep = value
  };

  set step(TFStep value) => {
    gyroHasChangedDuringStep = false,
    handleNewStep(_step)
  };

  set gyroIsValid(bool value) => {

    if (_gyroIsValid != value) {
      _gyroHasChangedDuringStep = true
    },
    _gyroIsValid = value
  };


  void start({bool andReset}) {

  }

  void pause() {

  }

  void reset() {

  }

  void handleNewStep(TFStep newStep) {

  }

  // This function is called once gyro is changed (became valid or invalid)
  void handle({bool isValidGyroChange}) {

  var oldValue = _gyroIsValid;
  gyroIsValid = isValidGyroChange;


  if (_step == null) {
  // First launch
    start();
  } else if (_step != null && isValidGyroChange == false) {
  // Gyro became invalid
    pause();
  } else if (_step != null && isValidGyroChange == true && oldValue == false) {
  // Gyro became valid, but launch "great" sound only if there is no other help command in the queue.
  if (pauseTimer != null) { return; }


  FutureExtension.enableContinueTimer(delay: 2).then((value) {
    if (_gyroIsValid == false) {return;}
    start(andReset: false);
  });
  }
  }

}
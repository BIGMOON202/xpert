
import 'package:tdlook_flutter_app/Extensions/Application.dart';

enum TFOptionalSound {
  tick, capture, placePhone, placePhoneRetakeFront,placePhoneRetakeOnlySide, waitForResults
}

extension OptionalSoundExtension on TFOptionalSound {
  String get fileName {
    switch (this) {
      case TFOptionalSound.tick: return 'tick';
      case TFOptionalSound.capture: return 'iPhone_Camera_Shutter_1';
      case TFOptionalSound.placePhone: return 'tf1.1';
      case TFOptionalSound.placePhoneRetakeFront: return 'tf3.1';
      case TFOptionalSound.placePhoneRetakeOnlySide: return 'tf6.1';
      case TFOptionalSound.waitForResults: return 'tf2.4';
    }
  }

  bool get respectsSilentMode {
    switch (this) {
      case TFOptionalSound.tick:
      case TFOptionalSound.placePhone:
      case TFOptionalSound.placePhoneRetakeFront:
      case TFOptionalSound.placePhoneRetakeOnlySide:
      case TFOptionalSound.waitForResults:
        return false;

      case TFOptionalSound.capture:
        return true;

    }
  }
}


enum TFStep {
  //frontPlacePhoneVertically
  frontGreat, frontTakeSteps, frontCheckBody, frontCheckFeet, frontHoldPosition, frontDone,
  sideIntro, sideTurnBody, sideStayStill, sideDone, great,


  retakeFrontIntro, retakeFrontGreat, retakeFrontTakeSteps, retakeFrontCheckFeet, retakeFrontHoldPosition, retakeFrontDone,
  retakeSideIntro, retakeSideTurnBody, retakeSideStayStill, retakeSideDone,

  retakeOnlyFrontIntro, retakeOnlyFrontGreat,
  retakeOnlyFrontTakeSteps, retakeOnlyFrontCheckBody,
  retakeOnlyFrontCheckFeet, retakeOnlyFrontHoldPosition,retakeOnlyFrontDone,

  retakeOnlySideIntro, retakeOnlySideGreat, retakeOnlySideTakeSteps, retakeOnlySideCheckBody,
  retakeOnlySideTurnBody, retakeOnlySideStayStill, retakeOnlySideDone
}

extension TFStepExtension on TFStep {
  String audioTrackName() {

    switch (this) {
      // case TFStep.frontPlacePhoneVertically:    return "tf1.1";
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

    case TFStep.retakeFrontIntro:             return "tf3.1";
    case TFStep.retakeFrontGreat:             return "tf3.2";
    case TFStep.retakeFrontTakeSteps:         return "tf3.3";
    case TFStep.retakeFrontCheckFeet:         return "tf3.4";
    case TFStep.retakeFrontHoldPosition:      return "tf1.6";
    case TFStep.retakeFrontDone:              return "tf3.5";

    case TFStep.retakeSideIntro:              return "tf4.1";
    case TFStep.retakeSideTurnBody:           return "tf4.2";
    case TFStep.retakeSideStayStill:          return "tf4.3";
    case TFStep.retakeSideDone:               return "tf4.4";

    case TFStep.retakeOnlyFrontIntro:         return "tf5.1";
    case TFStep.retakeOnlyFrontGreat:         return "tf5.2";
    case TFStep.retakeOnlyFrontTakeSteps:     return "tf5.3";
    case TFStep.retakeOnlyFrontCheckBody:     return "tf5.4";
    case TFStep.retakeOnlyFrontCheckFeet:     return "tf5.5";
    case TFStep.retakeOnlyFrontHoldPosition:  return "tf5.6";
    case TFStep.retakeOnlyFrontDone:          return "tf5.7";

    case TFStep.retakeOnlySideIntro:          return "tf6.1";
    case TFStep.retakeOnlySideGreat:          return "tf6.2";
    case TFStep.retakeOnlySideTakeSteps:      return "tf6.3";
    case TFStep.retakeOnlySideCheckBody:      return "tf6.4";
    case TFStep.retakeOnlySideTurnBody:       return "tf6.5";
    case TFStep.retakeOnlySideStayStill:      return "tf6.6";
    case TFStep.retakeOnlySideDone:           return "tf6.7";


    case TFStep.great:                        return "tf1.2";
    }
  }

  double afterDelayValue() {
    // if (Application.isInDebugMode) {
    //   if (this == TFStep.frontHoldPosition || this == TFStep.sideStayStill) {
    //     return 4;
    //   }
    //   return 0.0;
    // }

    switch (this) {
      case TFStep.great: return 2.0;
      // case TFStep.frontPlacePhoneVertically: return 2.0;

      case TFStep.frontTakeSteps: return 3.0;

      case TFStep.frontHoldPosition:
      case TFStep.retakeFrontHoldPosition:
      case TFStep.retakeOnlyFrontHoldPosition:

      case TFStep.sideStayStill:
      case TFStep.retakeSideStayStill:
      case TFStep.retakeOnlySideStayStill:
      return 4;

      default: return 1;
    }
  }

  bool shouldShowTimer() {
    switch (this) {
      case TFStep.frontHoldPosition:

      case TFStep.retakeFrontHoldPosition:
      //
      case TFStep. retakeOnlyFrontHoldPosition:
      //
      case TFStep.sideStayStill:

      case TFStep.retakeSideStayStill:
      //
      case TFStep.retakeOnlySideStayStill:
        return true;

      default:
        return false;
    }
  }

  bool shouldCaptureAfter() {

    switch (this) {
      case TFStep.frontHoldPosition:

      case TFStep.retakeFrontHoldPosition:
      //
      case TFStep.retakeOnlyFrontHoldPosition:
      //
      case TFStep.sideStayStill:

      case TFStep.retakeSideStayStill:
      //
      case TFStep.retakeOnlySideStayStill:
        return true;

      default:
        return false;
    }
  }

  bool couldBeInterrapted() {
    switch (this) {
      // case TFStep.frontPlacePhoneVertically: return false;
      default: return true;
    }
  }

  bool restartAfter() {
    switch (this) {
      case TFStep.great: return true;
      default: return false;
    }
  }
}

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Screens/Helpers/HandsFreeCaptureStep.dart';

class HandsFreePlayer {
  AudioCache player = AudioCache();
  static String _playerID = 'handsFreePlayer';

  HandsFreePlayer() {

  }

  VoidCallback onCaptureBlock;
  ValueChanged<String> onTimerUpdateBlock;

  Timer _timerPauseBetweenSteps;
  Timer _captureTimer;
  Timer _timerTickingBeforePhoto;


  Future<void> playStep({TFStep step}) async {

    var audioFile = 'HandsFreeAudio\/${step.audioTrackName()}.mp3';
    player.fixedPlayer = AudioPlayer(playerId: _playerID);
    player.respectSilence = false;
    debugPrint('should play: $audioFile');
    // _isPlaying = true;
    player.fixedPlayer?.setVolume(volumeIsOn ? 1 : 0);
    print('volumeIsOn: $volumeIsOn');

    await player.play(audioFile);
    debugPrint('playing: $audioFile');
    player.fixedPlayer.onPlayerStateChanged.listen((event) {
      print('new player status: ${event}');
      if (event == PlayerState.COMPLETED) {
        _handleTheEndOf(step: step);
      }
    });
  }

  void stop() {
    print('player was stopped');
    _timerTickingBeforePhoto?.cancel();
    _timerPauseBetweenSteps?.cancel();
    _captureTimer?.cancel();
    player?.fixedPlayer?.stop();
  }

  void _handleTheEndOf({TFStep step}) {

    // play timer if needed
    if (step != null && step.shouldShowTimer() == true) {
      var interval = step.afterDelayValue();
      print('shouldShowTimer');

      const oneSec = const Duration(seconds: 1);
      _timerTickingBeforePhoto = new Timer.periodic(
        oneSec,
            (Timer timer) {

          if (interval == 0) {

            // fire complete
            timer.cancel();
            onTimerUpdateBlock('');

          } else {
            interval--;
            if (interval > 0) {
              playSound(sound: TFOptionalSound.tick);
            }
            print("timer interval $interval");
            onTimerUpdateBlock( interval > 0 ? '${interval.toStringAsFixed(0)}': '');
          }
        },
      );
    }

    // handle the pause after step
    var duration = Duration(seconds: step.afterDelayValue().toInt());
    print('duration $duration');
    var durationToCapture = Duration(seconds: step.afterDelayValue().toInt());
    if (step.shouldCaptureAfter()) {
      _captureTimer = Timer(durationToCapture, () {
        if (step.shouldCaptureAfter() == true) {
          playSound(sound: TFOptionalSound.capture);
        }
      });
    }
    _timerPauseBetweenSteps = Timer(duration, () {
      print('timer fired after ${duration}');

      if (step.shouldCaptureAfter() == true) {
        Timer(Duration(milliseconds: 100), onCaptureBlock);
      } else {
        _moveToNext(step: step);
      }
    });
  }

  void playSound({TFOptionalSound sound}) {
    var audioFile = 'HandsFreeAudio\/${sound.fileName}.mp3';
    player.fixedPlayer = AudioPlayer(playerId: _playerID);
    player.respectSilence = sound.respectsSilentMode;
    player.fixedPlayer?.setReleaseMode(ReleaseMode.STOP);
    debugPrint('should play sound: $audioFile');

    player.fixedPlayer?.setVolume(volumeIsOn ? 1 : 0);
    print('volumeIsOn: $volumeIsOn');
    player.play(audioFile);
  }

  void _moveToNext({TFStep step}) {
    print('increaseStep');

    var newStepIndex = step.index + 1;
    print('newStepIndex: $newStepIndex');

    if (TFStep.values.length > newStepIndex) {
      playStep(step: TFStep.values[newStepIndex]);
    }
  }

  bool volumeIsOn = true;

  void setSound({bool on}) {
    volumeIsOn = on;
    player.fixedPlayer.setVolume(on ? 1 : 0);
  }
}
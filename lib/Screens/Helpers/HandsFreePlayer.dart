import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Screens/Helpers/HandsFreeCaptureStep.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';

class HandsFreePlayer {
  AudioCache player = AudioCache();
  static String _playerID = 'handsFreePlayer';

  VoidCallback? onCaptureBlock;
  ValueChanged<String>? onTimerUpdateBlock;
  ValueChanged<String>? onFileNameChangedBlock;

  Timer? _timerPauseBetweenSteps;
  Timer? _captureTimer;
  Timer? _timerTickingBeforePhoto;

  Future<void> playStep({TFStep? step}) async {
    final name = step?.audioTrackName() ?? '';
    var audioFile = 'HandsFreeAudio\/$name.mp3';
    player.fixedPlayer = AudioPlayer(playerId: _playerID);
    player.respectSilence = false;
    onFileNameChangedBlock?.call(name);
    logger.d('[01] play file: $name');
    // _isPlaying = true;
    await player.fixedPlayer?.setVolume(volumeIsOn ? 1 : 0);
    logger.d('volumeIsOn: $volumeIsOn');

    await player.play(audioFile);
    logger.d('playing: $audioFile');
    player.fixedPlayer?.onPlayerStateChanged.listen((event) {
      logger.d('new player status: ${event}');
      if (event == PlayerState.COMPLETED) {
        _handleTheEndOf(step: step);
      }
    });
  }

  void stop() {
    logger.i('player was stopped');
    _timerTickingBeforePhoto?.cancel();
    _timerPauseBetweenSteps?.cancel();
    _captureTimer?.cancel();
    player.fixedPlayer?.stop();
  }

  void _handleTheEndOf({TFStep? step}) async {
    // play timer if needed
    if (step != null && step.shouldShowTimer() == true) {
      var interval = step.afterDelayValue();
      logger.i('shouldShowTimer');

      const oneSec = const Duration(seconds: 1);
      _timerTickingBeforePhoto = new Timer.periodic(
        oneSec,
        (Timer timer) async {
          if (interval == 0) {
            // fire complete
            timer.cancel();
            onTimerUpdateBlock?.call('');
          } else {
            interval--;
            if (interval > 0) {
              await playSound(sound: TFOptionalSound.tick);
            }
            logger.d("timer interval $interval");
            onTimerUpdateBlock?.call(
              interval > 0 ? '${interval.toStringAsFixed(0)}' : '',
            );
          }
        },
      );
    }

    // handle the pause after step
    final seconds = step?.afterDelayValue().toInt() ?? 0;
    final duration = Duration(seconds: seconds);
    logger.d('duration $duration');
    final durationToCapture = Duration(seconds: seconds);
    logger.d('[0] duration: $duration');
    logger.d('[0] durationToCapture: $durationToCapture');
    if (step?.shouldCaptureAfter() == true) {
      _captureTimer = Timer(durationToCapture, () async {
        if (step?.shouldCaptureAfter() == true) {
          await playSound(sound: TFOptionalSound.capture);
        }
      });
    }
    _timerPauseBetweenSteps = Timer(duration, () async {
      logger.d('timer fired after $duration');

      if (step?.shouldCaptureAfter() == true) {
        Timer(Duration(milliseconds: 300), onCaptureBlock!);
      } else {
        await _moveToNext(step: step);
      }
    });
  }

  Future<void> playSound({required TFOptionalSound sound}) async {
    final audioFile = 'HandsFreeAudio\/${sound.fileName}.mp3';
    player.fixedPlayer = AudioPlayer(playerId: _playerID);

    player.respectSilence = sound.respectsSilentMode;
    await player.fixedPlayer?.setReleaseMode(ReleaseMode.STOP);
    await player.fixedPlayer?.setVolume(volumeIsOn ? 1 : 0);
    await player.play(audioFile);
  }

  Future<void> _moveToNext({TFStep? step}) async {
    logger.i('increaseStep');

    var newStepIndex = (step?.index ?? 0) + 1;
    logger.d('newStepIndex: $newStepIndex');

    if (TFStep.values.length > newStepIndex) {
      await playStep(step: TFStep.values[newStepIndex]);
    }
  }

  bool volumeIsOn = true;

  Future<void> setSound({required bool on}) async {
    volumeIsOn = on;
    await player.fixedPlayer?.setVolume(on ? 1 : 0);
  }
}

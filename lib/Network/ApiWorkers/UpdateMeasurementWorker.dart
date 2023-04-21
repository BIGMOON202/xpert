import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/String+Extension.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/MeasurementsWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';

class UpdateMeasurementWorker {
  MeasurementResults? model;
  UpdateMeasurementWorker(this.model);

  NetworkAPI _provider = NetworkAPI();
  Future<MeasurementResults> uploadData() async {
    final response =
        await _provider.patch('measurements/${model?.id}/', useAuth: true, body: model?.toJson());
    logger.d('userinfo $response');
    return MeasurementResults.fromJson(response);
  }
}

class UploadPhotosWorker {
  MeasurementResults? model;
  XFile? frontPhoto;
  XFile? sidePhoto;

  UploadPhotosWorker(this.model, this.frontPhoto, this.sidePhoto);

  NetworkAPI _provider = NetworkAPI();

  Future<PhotoUploaderModel> uploadData() async {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    // var compressedFront = await FlutterNativeImage.compressImage(frontPhoto.path, quality: 70);
    // var frontBytes = await compressedFront.readAsBytes();
    var origFront = await frontPhoto?.readAsBytes();
    //logger.d('size of front:${origFront.lengthInBytes} - ${frontBytes.lengthInBytes}');
    var base64Front = base64Encode(origFront ?? []);

    // var compressedSide = await FlutterNativeImage.compressImage(sidePhoto.path, quality: 70);
    // var sideBytes = await compressedSide.readAsBytes();
    var origSide = await sidePhoto?.readAsBytes();
    var base64Side = base64Encode(origSide ?? []);
    data['front_image'] = base64Front;
    data['side_image'] = base64Side;

    logger.i('uploadPhoto request');
    final Map<String, String> headers = Map<String, String>();
    headers['accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';

    final response = await _provider.post('measurements/${model?.id}/process_person/',
        headers: headers, useAuth: true, body: data);
    logger.d('uploadPhoto: $response');
    return PhotoUploaderModel.fromJson(response);
  }
}

/*
class WaitingForResultsWorker {
  IOWebSocketChannel _channel;

  MeasurementResults model;
  final Function(dynamic) onResultReady;
  dynamic resultData;
  bool isResultReceived = false; // true if result received
  WaitingForResultsWorker(this.model, this.onResultReady);

  parse(dynamic data) async {
   logger.d('parse result: $data');
    resultData = data;
    Future<void> parse() async {
     logger.d(onResultReady);
      resultData = data;
      if (!isResultReceived) {
        isResultReceived = true;
        onResultReady(data);
      }
    }

    await parse();
  }

  close() {
    _onClose();
  }

  startObserve_v2() async {
    if (resultData != null) {
      parse(resultData);
      return;
    }
  }

  startObserve() async {
    if (resultData != null) {
      parse(resultData);
      return;
    }



    var socketLink =
        'wss://${Application.hostName}/ws/measurement/${model.uuid}/';
   logger.d('socket link: ${socketLink}');

    int attemptCounter = 0;
    var results;

    Future<bool> _enableContinueTimer({int delay}) async {
      await Future.delayed(Duration(seconds: delay));
    }

    // final channel = await IOWebSocketChannel.connect(socketLink);
    //
    // channel.stream.listen((message) {
    //   parse(message);
    //  logger.d('message: $message');
    //   channel.sink.close(status.goingAway);
    // });
    final HttpMetric metric = FirebasePerformance.instance
        .newHttpMetric(socketLink, HttpMethod.Get);

    _initialConnect(void onDoneClosure()) async {
     logger.i('trying to connect');
      attemptCounter += 1;
     logger.d('_channel: $_channel');

      _channel = IOWebSocketChannel.connect(socketLink);

      await metric.start();

      _channel.stream.listen((message) async {
        parse(message);
       logger.d('message: $message');
        await metric.stop();
        _channel.sink.close(status.goingAway);
      });
      // _channel = channel;
      // _channel = await IOWebSocketChannel.connect(socketLink);
      // _channel.stream.listen((message) {
      //   if (message == "hello") {
      //    logger.d('message: $message');
      //     return;
      //   }
      //   results = message;
      //   parse(message);
      //  logger.d('message: $message');
      //   _channel.sink.close(status.goingAway);
      // });
      // _channel.sink.add("hello");
    }

    void _onConnectionLost() async {
     logger.i('Disconnected');
      _onClose();
      await metric.stop();
      parse('');
    }

    void _onInitialDisconnected() {
     logger.i('Disconnected');
      _onClose();
      _initialConnect(
          attemptCounter > 3 ? _onConnectionLost : _onInitialDisconnected);
    }

    //TODO remove this shit
    // _enableContinueTimer(delay: 50).then((value) {
    //   logger.i('_enableContinueTimer for check results');
    //   _bloc = RecommendationsListBLOC(model.id.toString());
    //   _bloc.chuckListStream.listen((event) {
    //
    //     switch (event.status) {
    //       case Status.LOADING:
    //         break;
    //
    //       case Status.COMPLETED:
    //         if (_channel != null) {
    //           _channel.sink.close();
    //         }
    //         _channel = null;
    //
    //         if (event.data != null && event.data.length > 0) {
    //           parse('{"status": "success"}');
    //         } else {
    //           parse(event.message);
    //         }
    //         break;
    //       case Status.ERROR:
    //         if (_channel != null) {
    //           _channel.sink.close();
    //         }
    //         _channel = null;
    //         parse('');
    //         break;
    //     }
    //   });
    //   _bloc.call();
    // });

    _initialConnect(_onInitialDisconnected);
  }

  void _onClose() {
   logger.i('OnClose');
    if (_channel != null) {
      _channel.sink.close();
    }
    _channel = null;
  }
} */

class UpdateMeasurementBloc {
  MeasurementResults? model;
  XFile? frontPhoto;
  XFile? sidePhoto;
  bool? shouldUploadMeasurements;
  bool isUploadingSuccess = false;
  bool isMeasurementsReceived = false;
  bool isMeasurementsUpdated = false; // true if result received

  Map _source = {ConnectivityResult.mobile: true};
  MyConnectivity? _connectivity = MyConnectivity.instance;

  UploadPhotosWorker? _uploadPhotosWorker;
  UpdateMeasurementWorker? _userInfoWorker;
  MeasurementsWorker? _checkMeasurementWorker;

  // WaitingForResultsWorker _waitingForResultsWorker;
  StreamController? _listController;

  StreamSink<Response<AnalizeResult>>? chuckListSink;

  Stream<Response<AnalizeResult>>? chuckListStream;

  Future<AnalizeResult> getResults(dynamic result) async {
    logger.i('catch results');

    AnalizeResult analizeResult = AnalizeResult.fromJson(result);
    logger.d('result: $analizeResult');
    return analizeResult;

    // chuckListSink.add(Response.completed(analizeResult));
  }

  handle(dynamic result) async {
    try {
      Map valueMap = json.decode(result);
      AnalizeResult info = await getResults(valueMap);
      if (!isMeasurementsReceived) {
        isMeasurementsReceived = true;
        // chuckListSink.add(Response.completed(info));
      }
    } catch (e) {
      // chuckListSink.add(Response.error(e.toString()));
      logger.e(e);
    }
  }

  bool _isConnected = true;
  UpdateMeasurementBloc(
      this.model, this.frontPhoto, this.sidePhoto, this.shouldUploadMeasurements) {
    _listController = StreamController<Response<AnalizeResult>>();
    chuckListSink = _listController?.sink as StreamSink<Response<AnalizeResult>>;
    chuckListStream = _listController?.stream as Stream<Response<AnalizeResult>>;
    if (shouldUploadMeasurements == true) {
      _userInfoWorker = UpdateMeasurementWorker(model);
    }
    _uploadPhotosWorker = UploadPhotosWorker(model, frontPhoto, sidePhoto);
    // _waitingForResultsWorker = WaitingForResultsWorker(model, handle);
    _checkMeasurementWorker = MeasurementsWorker(model?.id.toString());

    _connectivity?.initialise();
    _connectivity?.myStream.listen((source) {
      logger.d('connection to network: $source');
      _source = source;
      var isConnected = _source.keys.toList()[0] != ConnectivityResult.none;
      logger.d('is connected: $isConnected, previous: $_isConnected');
      if (_isConnected != isConnected && isConnected == true) {
        //reconnection
        logger.i('reconection');
        checkState();
      } else {
        logger.i('without reconection');
      }
      _isConnected = isConnected;
    });
  }

  Future<void> _enableContinueTimer({int? delay}) async {
    await Future.delayed(Duration(seconds: delay ?? 0));
  }

  void setLoading({String? name, int? delay}) {
    _enableContinueTimer(delay: delay ?? 0).then((value) {
      chuckListSink?.add(Response.loading(name));
    });
  }

  checkState() {
    if (isMeasurementsReceived == true) {
      //close observing
      _connectivity = null;
      logger.i('isMeasurementsReceived');
    } else if (isUploadingSuccess) {
      // check results
      logger.i('observeResults_v2');
      observeResults_v2();
    } else if (isMeasurementsUpdated) {
      logger.i('uploadPhotos');
      //re-upload photos
      uploadPhotos();
    } else {
      logger.i('upload measurement update');
      call();
    }
  }

  call() async {
    if (shouldUploadMeasurements == true && _userInfoWorker != null) {
      chuckListSink?.add(Response.loading('Initiating Profile Creation'));
      try {
        final result = await _userInfoWorker?.uploadData();
        chuckListSink?.add(Response.loading('Profile Creation Completed!'));
        isMeasurementsUpdated = true;
        uploadPhotos();
        // chuckListSink.add(Response.completed(info));
      } catch (e) {
        var description = e.toString();
        if (description.contains('in progress')) {
          return;
        }

        chuckListSink?.add(Response.error(description));
        logger.e(e);
      }
    } else {
      uploadPhotos();
    }
  }

  // Did enter foreground
  updateAppState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        logger.i("Did active");
        checkState();
        break;
      default:
        logger.i("Did inactive");
        // _waitingForResultsWorker.close();
        break;
    }
  }

  uploadPhotos() async {
    setLoading(name: 'Uploading scans', delay: 2);
    try {
      PhotoUploaderModel? info = await _uploadPhotosWorker?.uploadData();
      if (info?.detail == 'OK') {
        isUploadingSuccess = true;
        chuckListSink?.add(Response.loading('Scans Upload Completed!'));
        _enableContinueTimer(delay: checkFrequency).then((value) {
          observeResults_v2();
        });
      }
      // else {
      //   chuckListSink.add(Response.error(info.detail));
      // }
    } catch (e) {
      var description = e.toString();
      if (description.contains('in progress')) {
        return;
      }

      chuckListSink?.add(Response.error(description));
      logger.e(e);
    }
  }

  bool isWaitingForMeasurementInfo = false;
  int checkFrequency = 10;
  int timeoutDelay = 180;

  observeResults_v2() async {
    setLoading(name: 'Calculating your Measurements', delay: 2);

    //logger.d('isWaitingForMeasurementInfo: $isWaitingForMeasurementInfo');
    // if (isWaitingForMeasurementInfo == false) {
    //   isWaitingForMeasurementInfo = true;
    checkMeasurement();
    // }
  }

  Timer? _checkMeasurementTimer;
  reScheduleCheckMeasuremet() {
    logger.d('_checkMeasurementTimer1:${_checkMeasurementTimer}');
    _checkMeasurementTimer?.cancel();
    _checkMeasurementTimer = null;
    logger.d('_checkMeasurementTimer2:${_checkMeasurementTimer}');

    var duration = Duration(seconds: checkFrequency);
    _checkMeasurementTimer = Timer.periodic(duration, (Timer t) => checkMeasurement());
  }

  checkMeasurement() async {
    logger.i('fire checkMeasurement');

    reScheduleCheckMeasuremet();
    MeasurementResults? measurement = await _checkMeasurementWorker?.fetchData();
    logger.d('Measurement is complete: ${measurement?.isComplete}');

    if (measurement?.isComplete != null && measurement?.isComplete == true) {
      if (!isMeasurementsReceived) {
        isMeasurementsReceived = true;
        chuckListSink?.add(Response.completed(AnalizeResult()));
      }
    } else if (measurement?.isCalculating == true) {
      // schedule next check
      logger.d('measurement.isCalculating: ${measurement?.isCalculating}');
      logger.i('schedule checkMeasurement');

      reScheduleCheckMeasuremet();
    } else if (measurement?.error != null) {
      logger.d('Measurement error: ${measurement?.error}');

      // show error
      if (!isMeasurementsReceived) {
        isMeasurementsReceived = true;
        chuckListSink?.add(Response.completed(measurement?.error));
      }
    }
  }

  dispose() {
    logger.i('dispose updating worker');
    _checkMeasurementTimer?.cancel();
    _checkMeasurementTimer = null;
    _listController?.close();
  }
}

class PhotoUploaderModel {
  String? detail;

  PhotoUploaderModel({this.detail});

  PhotoUploaderModel.fromJson(Map<String, dynamic> json) {
    detail = json['detail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['detail'] = this.detail;
    return data;
  }
}

extension ErrorProcessingTypeExtension on ErrorProcessingType {
  String iconName() {
    switch (this) {
      case ErrorProcessingType.front_skeleton_processing:
        return 'front_ic.png';
      case ErrorProcessingType.side_skeleton_processing:
        return 'side_ic.png';
      default:
        return '';
    }
  }

  String name() {
    switch (this) {
      case ErrorProcessingType.front_skeleton_processing:
        return 'front';
      case ErrorProcessingType.side_skeleton_processing:
        return 'side';
      default:
        return '';
    }
  }
}

extension DetailExtension on Detail {
  String uiDescription() {
    var msg = this.message?.toLowerCase() ?? '';
    msg = msg.fixAllPhotoTexts;
    switch (msg) {
      case 'side scan in the front':
        return 'It looks like you took the side scan\ninstead of the front one';
      case 'front scan in the side':
        return 'It looks like you took the front scan\ninstead of the side one';
      case 'can\'t detect the human body':
        return 'We don\'t seem to be able to detect your body!';
      case 'the body is not full':
        return 'Sorry! We need to be able to detect your entire body!';
      default:
        const str = 'the pose is wrong, сheck your ';
        if (msg.contains(str) == true) {
          final bodyPart = msg.replaceAll(str, '');
          return 'Oh no! We were not able to detect your $bodyPart';
        }
        return '';
    }
  }

  String? uiTitle() {
    var msg = this.message?.toLowerCase() ?? '';
    msg = msg.fixAllPhotoTexts;
    switch (msg) {
      case 'side scan in the front':
        return 'Please retake the front scan';
      case 'front scan in the side':
        return 'Please retake the side scan';
      case 'can\'t detect the human body':
        return 'Please retake the ${this.type?.name()} scan and ensure your whole body can be seen in the scan!';
      case 'the body is not full':
        return 'Please retake the ${this.type?.name()} scan and ensure your entire body can be seen in the scan, and follow the pose!';
      default:
        const str = 'the pose is wrong, сheck your ';
        if (msg.contains(str) == true) {
          final bodyPart = msg.replaceAll(str, '');
          return 'Remember, your $bodyPart must be seen in the scan!';
        }
        return this.message;
    }
  }
}

class MyConnectivity {
  MyConnectivity._();

  static final _instance = MyConnectivity._();
  static MyConnectivity get instance => _instance;
  final _connectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;

  void initialise() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _checkStatus(result);
    _connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('google.com');
      logger.d('connection status is: $result');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}

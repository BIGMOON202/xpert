import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/MeasurementsWorker.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/ReccomendationsListWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:connectivity_plus/connectivity_plus.dart';

class UpdateMeasurementWorker {
  MeasurementResults model;
  UpdateMeasurementWorker(this.model);

  NetworkAPI _provider = NetworkAPI();
  Future<MeasurementResults> uploadData() async {
    final response = await _provider.patch('measurements/${model.id}/',
        useAuth: true, body: model.toJson());
    print('userinfo ${response}');
    return MeasurementResults.fromJson(response);
  }
}

class UploadPhotosWorker {
  MeasurementResults model;
  XFile frontPhoto;
  XFile sidePhoto;

  UploadPhotosWorker(this.model, this.frontPhoto, this.sidePhoto);

  NetworkAPI _provider = NetworkAPI();

  Future<PhotoUploaderModel> uploadData() async {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    // var compressedFront = await FlutterNativeImage.compressImage(frontPhoto.path, quality: 70);
    // var frontBytes = await compressedFront.readAsBytes();
    var origFront = await frontPhoto.readAsBytes();
    // print('size of front:${origFront.lengthInBytes} - ${frontBytes.lengthInBytes}');
    var base64Front = base64Encode(origFront);

    // var compressedSide = await FlutterNativeImage.compressImage(sidePhoto.path, quality: 70);
    // var sideBytes = await compressedSide.readAsBytes();
    var origSide = await sidePhoto.readAsBytes();
    var base64Side = base64Encode(origSide);
    data['front_image'] = base64Front;
    data['side_image'] = base64Side;

    print('uploadPhoto request');
    final Map<String, dynamic> headers = new Map<String, String>();
    headers['accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';

    final response = await _provider.post(
        'measurements/${model.id}/process_person/',
        headers: headers,
        useAuth: true,
        body: data);
    print('uploadPhoto: ${response}');
    return PhotoUploaderModel.fromJson(response);
  }
}

class WaitingForResultsWorker {
  RecommendationsListBLOC _bloc;
  IOWebSocketChannel _channel;

  MeasurementResults model;
  final Function(dynamic) onResultReady;
  dynamic resultData;
  bool isResultReceived = false; // true if result received
  WaitingForResultsWorker(this.model, this.onResultReady);

  parse(dynamic data) async {
    print('parse result: $data');
    resultData = data;
    Future<void> parse() async {
      print(onResultReady);
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
    print('socket link: ${socketLink}');

    int attemptCounter = 0;
    var results;

    Future<bool> _enableContinueTimer({int delay}) async {
      await Future.delayed(Duration(seconds: delay));
    }

    // final channel = await IOWebSocketChannel.connect(socketLink);
    //
    // channel.stream.listen((message) {
    //   parse(message);
    //   print('message: $message');
    //   channel.sink.close(status.goingAway);
    // });
    final HttpMetric metric = FirebasePerformance.instance
        .newHttpMetric(socketLink, HttpMethod.Get);

    _initialConnect(void onDoneClosure()) async {
      print('trying to connect');
      attemptCounter += 1;
      print('_channel: $_channel');

      _channel = IOWebSocketChannel.connect(socketLink);

      await metric.start();

      _channel.stream.listen((message) async {
        parse(message);
        print('message: $message');
        await metric.stop();
        _channel.sink.close(status.goingAway);
      });
      // _channel = channel;
      // _channel = await IOWebSocketChannel.connect(socketLink);
      // _channel.stream.listen((message) {
      //   if (message == "hello") {
      //     print('message: $message');
      //     return;
      //   }
      //   results = message;
      //   parse(message);
      //   print('message: $message');
      //   _channel.sink.close(status.goingAway);
      // });
      // _channel.sink.add("hello");
    }

    void _onConnectionLost() async {
      print('Disconnected');
      _onClose();
      await metric.stop();
      parse('');
    }

    void _onInitialDisconnected() {
      print('Disconnected');
      _onClose();
      _initialConnect(
          attemptCounter > 3 ? _onConnectionLost : _onInitialDisconnected);
    }

    //TODO remove this shit
    // _enableContinueTimer(delay: 50).then((value) {
    //   debugPrint('_enableContinueTimer for check results');
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
    print('OnClose');
    if (_channel != null) {
      _channel.sink.close();
    }
    _channel = null;
  }
}

class UpdateMeasurementBloc {
  MeasurementResults model;
  XFile frontPhoto;
  XFile sidePhoto;
  bool shouldUploadMeasurements;
  bool isUploadingSuccess = false;
  bool isMeasurementsReceived = false;
  bool isMeasurementsUpdated = false; // true if result received

  Map _source = {ConnectivityResult.mobile: true};
  MyConnectivity _connectivity = MyConnectivity.instance;

  UploadPhotosWorker _uploadPhotosWorker;
  UpdateMeasurementWorker _userInfoWorker;
  MeasurementsWorker _checkMeasurementWorker;

  WaitingForResultsWorker _waitingForResultsWorker;
  StreamController _listController;

  StreamSink<Response<AnalizeResult>> chuckListSink;

  Stream<Response<AnalizeResult>> chuckListStream;

  Future<AnalizeResult> getResults(dynamic result) async {
    print('catch results');

    AnalizeResult analizeResult = AnalizeResult.fromJson(result);
    print('result:$analizeResult');

    chuckListSink.add(Response.completed(analizeResult));
  }

  handle(dynamic result) async {
    try {
      Map valueMap = json.decode(result);
      AnalizeResult info = await getResults(valueMap);
      if (!isMeasurementsReceived) {
        isMeasurementsReceived = true;
        chuckListSink.add(Response.completed(info));
      }
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  bool _isConnected = true;
  UpdateMeasurementBloc(this.model, this.frontPhoto, this.sidePhoto,
      this.shouldUploadMeasurements) {
    _listController = StreamController<Response<AnalizeResult>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;
    if (shouldUploadMeasurements == true) {
      _userInfoWorker = UpdateMeasurementWorker(model);
    }
    _uploadPhotosWorker = UploadPhotosWorker(model, frontPhoto, sidePhoto);
    _waitingForResultsWorker = WaitingForResultsWorker(model, handle);
    _checkMeasurementWorker = MeasurementsWorker(model.id.toString());

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      print('connection to network: $source');
      _source = source;
      var isConnected = _source.keys.toList()[0] != ConnectivityResult.none;
      print('is connected: $isConnected, previous: $_isConnected');
      if (_isConnected != isConnected && isConnected == true) {
        //reconnection
        print('reconection');
        checkState();
      } else {
        print('without reconection');
      }
      _isConnected = isConnected;
    });
  }

  Future<bool> _enableContinueTimer({int delay}) async {
    await Future.delayed(Duration(seconds: delay));
  }

  void setLoading({String name, int delay}) {
    _enableContinueTimer(delay: delay).then((value) {
      chuckListSink.add(Response.loading(name));
    });
  }

  checkState() {
    if (isMeasurementsReceived == true) {
      //close observing
      _connectivity = null;
      print('isMeasurementsReceived');
    } else if (isUploadingSuccess) {
      // check results
      print('observeResults_v2');
      observeResults_v2();
    } else if (isMeasurementsUpdated) {
      print('uploadPhotos');
      //re-upload photos
      uploadPhotos();
    } else {
      print('upload measurement update');
      call();
    }
  }



  call() async {
    if (shouldUploadMeasurements == true && _userInfoWorker != null) {
      chuckListSink.add(Response.loading('Initiating Profile Creation'));
      try {
        var result = await _userInfoWorker.uploadData();
        chuckListSink.add(Response.loading('Profile Creation Completed!'));
        isMeasurementsUpdated = true;
        uploadPhotos();
        // chuckListSink.add(Response.completed(info));
      } catch (e) {

        chuckListSink.add(Response.error(e.toString()));
        var er = e is FetchDataException;

        print('--');
        print(e.hashCode);
        print(e);
        print('--');

      }
    } else {
      uploadPhotos();
    }
  }

  // Did enter foreground
  updateAppState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("Did active");
        checkState();
        break;
      default:
        print("Did inactive");
        _waitingForResultsWorker.close();
        break;
    }
  }



  uploadPhotos() async {
    setLoading(name: 'Uploading photos', delay: 2);
    try {
      PhotoUploaderModel info = await _uploadPhotosWorker.uploadData();
      if (info.detail == 'OK') {
        chuckListSink.add(Response.loading('Photo Upload Completed!'));
        isUploadingSuccess = true;

        _enableContinueTimer(delay: checkFrequency).then((value) {
          observeResults_v2();
        });
      } else {
        chuckListSink.add(Response.error(info.detail));
      }
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print('--');
      print(e.hashCode);
      print(e);
      print('--');
    }
  }

  bool isWaitingForMeasurementInfo = false;
  int checkFrequency = 10;
  int timeoutDelay = 180;

  observeResults_v2() async {
    setLoading(name: 'Calculating your Measurements', delay: 2);

    // print('isWaitingForMeasurementInfo: $isWaitingForMeasurementInfo');
    // if (isWaitingForMeasurementInfo == false) {
    //   isWaitingForMeasurementInfo = true;
      checkMeasurement();
    // }
  }

  Timer _checkMeasurementTimer;
  reScheduleCheckMeasuremet() {
    print('_checkMeasurementTimer1:${_checkMeasurementTimer}');
    _checkMeasurementTimer?.cancel();
    _checkMeasurementTimer = null;
    print('_checkMeasurementTimer2:${_checkMeasurementTimer}');

    var duration = Duration(seconds: checkFrequency);
    _checkMeasurementTimer = Timer.periodic(duration, (Timer t) => checkMeasurement());
  }

  checkMeasurement() async {
    print('fire checkMeasurement');

    reScheduleCheckMeasuremet();
    MeasurementResults measurement = await _checkMeasurementWorker.fetchData();
    print('Measurement is complete: ${measurement.isComplete}');

    if (measurement.isComplete != null && measurement.isComplete == true) {

      if (!isMeasurementsReceived) {
        isMeasurementsReceived = true;
        chuckListSink.add(Response.completed(AnalizeResult()));
      }
    } else if (measurement.isCalculating == true) {
      // schedule next check
      print('measurement.isCalculating: ${measurement.isCalculating}');
      print('schedule checkMeasurement');

      reScheduleCheckMeasuremet();

    } else if (measurement.error != null) {
      print('Measurement error: ${measurement.error}');

      // show error
      if (!isMeasurementsReceived) {
        isMeasurementsReceived = true;
        chuckListSink.add(Response.completed(measurement.error));
      }
    }
  }

  /*
  checkMeasurementCompletion() async {
    MeasurementResults measurement = await _checkMeasurementWorker.fetchData();
    if (measurement.isComplete != null && measurement.isComplete == true) {
      if (!isMeasurementsReceived) {
        isMeasurementsReceived = true;
        chuckListSink.add(Response.completed(AnalizeResult()));
      }
    }
  }

  observeResults() async {
    setLoading(name: 'Calculating your Measurements', delay: 2);
    try {
      _waitingForResultsWorker.startObserve();
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }*/

  dispose() {
    print('dispose updating worker');
    _checkMeasurementTimer?.cancel();
    _checkMeasurementTimer = null;
    _listController?.close();
  }
}

class PhotoUploaderModel {
  String detail;

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
    switch (this.message.toLowerCase()) {
      case 'side photo in the front':
        return 'It looks like you took the side photo\ninstead of the front one';
      case 'front photo in the side':
        return 'It looks like you took the front photo\ninstead of the side one';
      case 'can\'t detect the human body':
        return 'We don\'t seem to be able to detect your body!';
      case 'the body is not full':
        return 'Sorry! We need to be able to detect your entire body!';
      default:
        var str = 'the pose is wrong, сheck your ';
        if (this.message.toLowerCase().contains(str)) {
          var bodyPart = this.message.toLowerCase().replaceAll(str, '') ?? '';
          return 'Oh no! We were not able to detect your $bodyPart';
        }
        return '';
    }
  }

  String uiTitle() {
    switch (this.message.toLowerCase()) {
      case 'side photo in the front':
        return 'Please retake the front photo';
      case 'front photo in the side':
        return 'Please retake the side photo';
      case 'can\'t detect the human body':
        return 'Please retake the ${this.type.name()} photo and ensure your whole body can be seen in the photo!';
      case 'the body is not full':
        return 'Please retake the ${this.type.name()} photo and ensure your entire body can be seen in the photo, and follow the pose!';
      default:
        var str = 'the pose is wrong, сheck your ';
        if (this.message.toLowerCase().contains(str)) {
          var bodyPart = this.message.toLowerCase().replaceAll(str, '') ?? '';
          return 'Remember, your $bodyPart must be seen in the photo!';
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
      print('connection status is: $result');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}

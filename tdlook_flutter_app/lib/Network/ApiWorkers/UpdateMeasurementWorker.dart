import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ApiWorkers/ReccomendationsListWorker.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

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
    _initialConnect(void onDoneClosure()) async {
      print('trying to connect');
      attemptCounter += 1;
      print('_channel: $_channel');

      _channel = IOWebSocketChannel.connect(socketLink);
      _channel.stream.listen((message) {
        parse(message);
        print('message: $message');
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

    void _onConnectionLost() {
      print('Disconnected');
      _onClose();
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

  UploadPhotosWorker _uploadPhotosWorker;
  UpdateMeasurementWorker _userInfoWorker;
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
      chuckListSink.add(Response.completed(info));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

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
  }

  Future<bool> _enableContinueTimer({int delay}) async {
    await Future.delayed(Duration(seconds: delay));
  }

  void setLoading({String name, int delay}) {
    print('DELAYED: ${name} ${DateTime.now().toString()}');
    _enableContinueTimer(delay: delay).then((value) {
      chuckListSink.add(Response.loading(name));
      print('FIRED: ${name} ${DateTime.now().toString()}');
    });
  }

  call() async {
    if (shouldUploadMeasurements == true && _userInfoWorker != null) {
      chuckListSink.add(Response.loading('Initiating Profile Creation'));
      try {
        var result = await _userInfoWorker.uploadData();
        chuckListSink.add(Response.loading('Profile Creation Completed!'));
        uploadPhotos();
        // chuckListSink.add(Response.completed(info));
      } catch (e) {
        chuckListSink.add(Response.error(e.toString()));
        print(e);
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
        if (isUploadingSuccess) {
          print("Start observeResults");
          observeResults();
        } else {
          print("Start uploadPhotos");
          uploadPhotos();
        }
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
        observeResults();
      } else {
        chuckListSink.add(Response.error(info.detail));
      }
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
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
  }

  dispose() {
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

class AnalizeResult {
  String event;
  String status;
  String errorCode;
  List<Detail> detail;
  Data data;

  AnalizeResult(
      {this.event, this.status, this.errorCode, this.detail, this.data});

  AnalizeResult.fromJson(Map<String, dynamic> json) {
    event = json['event'];
    status = json['status'];
    errorCode = json['error_code'];
    if (errorCode != null &&
        errorCode == 'validation_error' &&
        json['detail'] != null) {
      detail = new List<Detail>();
      json['detail'].forEach((v) {
        detail.add(new Detail.fromJson(v));
      });
    }
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['event'] = this.event;
    data['status'] = this.status;
    data['error_code'] = this.errorCode;
    if (this.detail != null) {
      data['detail'] = this.detail.map((v) => v.toJson()).toList();
    }
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Detail {
  ErrorProcessingType type;
  String status;
  String taskId;
  String message;

  Detail({this.type, this.status, this.taskId, this.message});

  Detail.fromJson(Map<String, dynamic> json) {
    type = EnumToString.fromString(ErrorProcessingType.values, json['name']);
    status = json['status'];
    taskId = json['task_id'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['task_id'] = this.taskId;
    data['message'] = this.message;
    return data;
  }
}

enum ErrorProcessingType { front_skeleton_processing, side_skeleton_processing }

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

class Data {
  int measurementId;

  Data({this.measurementId});

  Data.fromJson(Map<String, dynamic> json) {
    measurementId = json['measurement_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['measurement_id'] = this.measurementId;
    return data;
  }
}

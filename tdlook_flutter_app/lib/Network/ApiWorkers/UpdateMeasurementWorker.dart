

import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart' ;
import 'package:web_socket_channel/status.dart' as status;

class UpdateMeasurementWorker {
  MeasurementResults model;
  UpdateMeasurementWorker(this.model);

  NetworkAPI _provider = NetworkAPI();
  Future<MeasurementResults> uploadData() async {
    final response = await _provider.put('measurements/${model.id}/', useAuth: true, body: model.toJson());
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
    var frontBytes = await frontPhoto.readAsBytes();
    var base64Front = base64Encode(frontBytes);

    var sideBytes = await sidePhoto.readAsBytes();
    var base64Side = base64Encode(sideBytes);
    data['front_image'] = base64Front;
    data['side_image'] = base64Side;



    print('uploadPhoto request');
    final Map<String, dynamic> headers = new Map<String, dynamic>();
    headers['accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';

    final response = await _provider.post('measurements/${model.id}/process_person/', useAuth: true, body: data);
    print('uploadPhoto: ${response}');
    return PhotoUploaderModel.fromJson(response);
  }
}

class WaitingForResultsWorker{
  MeasurementResults model;
  final Function(dynamic) onResultReady;

  WaitingForResultsWorker(this.model, this.onResultReady);

  parse(dynamic data) async {
    print('parse result: $data');
    Future<void> parse() async {
      print(onResultReady);
      onResultReady(data);
    }
    await parse();
  }

  startObserve() async {


      var socketLink = 'wss://wlb-expertfit-test.3dlook.me/ws/measurement/${model.uuid}/';
      print('socket link: ${socketLink}');

      final channel = await IOWebSocketChannel.connect(socketLink);

     // var result = await channel.stream.toList();
     //  print('socket message: ${result.first}');
     //  channel.sink.add('received!');
     //  return AnalizeResult.fromJson(result.first);


      channel.stream.listen((message) {
        parse(message);
        print('message: $message');
        // result =  AnalizeResult.fromJson(message);
        // print('result:$result');
        // print(onResultReady);
        // onResultReady(result);
        // print('${result.status}');
        channel.sink.close(status.goingAway);
      });
  }
}

class UpdateMeasurementBloc {
  MeasurementResults model;
  XFile frontPhoto;
  XFile sidePhoto;

  UploadPhotosWorker _uploadPhotosWorker;
  UpdateMeasurementWorker _userInfoWorker;
  WaitingForResultsWorker _waitingForResultsWorker;
  StreamController _listController;

  StreamSink<Response<AnalizeResult>> chuckListSink;

  Stream<Response<AnalizeResult>>  chuckListStream;


  Future<AnalizeResult> getResults(dynamic result ) async {
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

  UpdateMeasurementBloc(this.model, this.frontPhoto, this.sidePhoto) {
    _listController = StreamController<Response<AnalizeResult>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;
    _userInfoWorker = UpdateMeasurementWorker(model);
    _uploadPhotosWorker = UploadPhotosWorker(model, frontPhoto, sidePhoto);
    _waitingForResultsWorker = WaitingForResultsWorker(model, handle);
  }




  call() async {

    chuckListSink.add(Response.loading('Uploading measurements'));
    try {
      MeasurementResults info = await _userInfoWorker.uploadData();
      uploadPhotos();
      // chuckListSink.add(Response.completed(info));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  uploadPhotos() async {
    chuckListSink.add(Response.loading('Uploading photos'));
    try {
      PhotoUploaderModel info = await _uploadPhotosWorker.uploadData();
      if (info.detail == 'OK') {
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
    chuckListSink.add(Response.loading('Waiting for results'));
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
    if (json['detail'] != null) {
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
  String name;
  String status;
  String taskId;
  String message;

  Detail({this.name, this.status, this.taskId, this.message});

  Detail.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    status = json['status'];
    taskId = json['task_id'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['status'] = this.status;
    data['task_id'] = this.taskId;
    data['message'] = this.message;
    return data;
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
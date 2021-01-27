

import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

class WaintingForResultsWorker {
  MeasurementResults model;
  WaintingForResultsWorker(this.model);

  Future<MeasurementResults> listen() {
    //wss://wlb-expertfit-test.3dlook.me/ws/measurement/175a02ad-82ff-47a7-b726-0bf1f14cb603/
    var socketLink = 'wss://wlb-expertfit-test.3dlook.me/ws/measurement/${model.uuid}/';
    print('socket link: ${socketLink}');

    final channel = IOWebSocketChannel.connect(socketLink);
    channel.sink.add("hello socket");
    channel.stream.listen((message) {
      print('socket message: $message');
      channel.sink.add('received!');
    });
  }

}

class UpdateMeasurementBloc {
  MeasurementResults model;
  XFile frontPhoto;
  XFile sidePhoto;

  UploadPhotosWorker _uploadPhotosWorker;
  UpdateMeasurementWorker _userInfoWorker;
  StreamController _listController;

  StreamSink<Response<PhotoUploaderModel>> chuckListSink;

  Stream<Response<PhotoUploaderModel>>  chuckListStream;

  UpdateMeasurementBloc(this.model, this.frontPhoto, this.sidePhoto) {
    _listController = StreamController<Response<PhotoUploaderModel>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;
    _userInfoWorker = UpdateMeasurementWorker(model);
    _uploadPhotosWorker = UploadPhotosWorker(model, frontPhoto, sidePhoto);
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
      chuckListSink.add(Response.completed(info));
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
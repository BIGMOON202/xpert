

import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';

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

    final response = await _provider.post('measurements/${model.id}/process_person/', useAuth: true, body: data);
    print('uploadPhoto: ${response}');
    return PhotoUploaderModel.fromJson(response);
  }
}

class UpdateMeasurementBloc {
  MeasurementResults model;
  XFile frontPhoto;
  XFile sidePhoto;

  UploadPhotosWorker _uploadPhotosWorker;
  UpdateMeasurementWorker _userInfoWorker;
  StreamController _listController;

  StreamSink<Response<MeasurementResults>> chuckListSink;

  Stream<Response<MeasurementResults>>  chuckListStream;

  UpdateMeasurementBloc(this.model, this.frontPhoto, this.sidePhoto) {
    _listController = StreamController<Response<MeasurementResults>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;
    _userInfoWorker = UpdateMeasurementWorker(model);
    _uploadPhotosWorker = UploadPhotosWorker(model, frontPhoto, sidePhoto);
  }




  call() async {

    chuckListSink.add(Response.loading('Getting User Info'));
    try {
      MeasurementResults info = await _userInfoWorker.uploadData();
      chuckListSink.add(Response.completed(info));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  uploadPhotos() async {
    chuckListSink.add(Response.loading('Uploading photod'));
    try {
      PhotoUploaderModel info = await _uploadPhotosWorker.uploadData();
      print('info${info.frontImage}, ${info.sideImage}');
      chuckListSink.add(Response.loading('UPLOAD IS SUCCESSFUL'));
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
  String frontImage;
  String sideImage;

  PhotoUploaderModel({this.frontImage, this.sideImage});

  PhotoUploaderModel.fromJson(Map<String, dynamic> json) {
    frontImage = json['front_image'];
    sideImage = json['side_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['front_image'] = this.frontImage;
    data['side_image'] = this.sideImage;
    return data;
  }
}
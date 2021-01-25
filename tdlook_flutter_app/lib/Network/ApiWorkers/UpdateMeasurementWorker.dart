

import 'dart:async';

import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';

class UpdateMeasurementWorker {
  MeasurementResults model;
  UpdateMeasurementWorker(this.model);

  NetworkAPI _provider = NetworkAPI();
  Future<MeasurementResults> uploadData() async {
    final response = await _provider.get('/measurements/${model.id}/', useAuth: true);
    print('userinfo ${response}');
    return MeasurementResults.fromJson(response);
  }
}

class UpdateMeasurementBloc {
  MeasurementResults model;

  UpdateMeasurementWorker _userInfoWorker;
  StreamController _listController;

  StreamSink<Response<MeasurementResults>> chuckListSink;

  Stream<Response<MeasurementResults>>  chuckListStream;

  UpdateMeasurementBloc(this.model) {
    _listController = StreamController<Response<MeasurementResults>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;
    _userInfoWorker = UpdateMeasurementWorker(model);
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

  dispose() {
    _listController?.close();
  }
}
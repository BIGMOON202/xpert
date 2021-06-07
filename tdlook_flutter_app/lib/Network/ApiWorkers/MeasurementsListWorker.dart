import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/Pagination.dart';

class MeasurementsListWorker {

  Paging _lastPage;
  String eventId;
  MeasurementsListWorker(this.eventId);

  NetworkAPI _provider = NetworkAPI();

  Future<MeasurementsList> fetchData() async {



    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var accessToken = prefs.getString('access');
    final response = await _provider.get('measurements/?event=$eventId',useAuth: true);
    var list = MeasurementsList.fromJson(response);
    debugPrint(list.paging.description);
    return list;
  }
}

class MeasurementsListWorkerBloc {

  String eventId;

  MeasurementsListWorker _measurementsListWorker;
  StreamController _listController;

  StreamSink<Response<MeasurementsList>> chuckListSink;

  Stream<Response<MeasurementsList>>  chuckListStream;

  MeasurementsListWorkerBloc(this.eventId) {
    
    print('Init block EventListWorkerBloc');
    _listController = StreamController<Response<MeasurementsList>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;

    _measurementsListWorker = MeasurementsListWorker(eventId);
  }

  call() async {
    print('call auth');

    chuckListSink.add(Response.loading('Getting measurements'));
    try {
      print('try block');
      MeasurementsList measurementsList = await _measurementsListWorker.fetchData();
      print('$measurementsList');
      chuckListSink.add(Response.completed(measurementsList));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _listController?.close();
  }
}
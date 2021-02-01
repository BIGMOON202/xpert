
import 'dart:async';

import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';

class MeasurementsWorker {

  String measurementID;
  MeasurementsWorker(this.measurementID);

  NetworkAPI _provider = NetworkAPI();

  Future<MeasurementResults> fetchData() async {

    final response = await _provider.get('measurements/$measurementID',useAuth: true);
    return MeasurementResults.fromJson(response);
  }
}

class MeasurementsWorkerBloc {

  String measurementID;

  MeasurementsWorker _measurementsListWorker;
  StreamController _listController;

  StreamSink<Response<MeasurementResults>> chuckListSink;

  Stream<Response<MeasurementResults>>  chuckListStream;

  MeasurementsWorkerBloc(this.measurementID) {

    print('Init block EventListWorkerBloc');
    _listController = StreamController<Response<MeasurementResults>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;

    _measurementsListWorker = MeasurementsWorker(measurementID);
  }

  call() async {
    print('call auth');

    chuckListSink.add(Response.loading('Getting measurements'));
    try {
      print('try block');
      MeasurementResults measurement = await _measurementsListWorker.fetchData();
      print('$measurement');
      chuckListSink.add(Response.completed(measurement));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _listController?.close();
  }
}
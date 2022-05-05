import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/utilt/logger.dart';

class MeasurementsWorker {
  String? measurementID;
  MeasurementsWorker(this.measurementID);

  NetworkAPI _provider = NetworkAPI();

  Future<MeasurementResults> fetchData() async {
    final response = await _provider.get('measurements/$measurementID', useAuth: true);
    return MeasurementResults.fromJson(response);
  }
}

class MeasurementsWorkerBloc {
  String? measurementID;

  late MeasurementsWorker _measurementsListWorker;
  late StreamController _listController;

  late StreamSink<Response<MeasurementResults>> chuckListSink;

  late Stream<Response<MeasurementResults>> chuckListStream;

  MeasurementsWorkerBloc(this.measurementID) {
    logger.i('Init block EventListWorkerBloc');
    final ctrl = StreamController<Response<MeasurementResults>>();
    _listController = ctrl;

    chuckListSink = ctrl.sink;
    chuckListStream = ctrl.stream;

    _measurementsListWorker = MeasurementsWorker(measurementID);
  }

  call() async {
    logger.i('call auth');

    chuckListSink.add(Response.loading('Getting measurements'));
    try {
      logger.i('try block');
      MeasurementResults measurement = await _measurementsListWorker.fetchData();
      logger.d('$measurement');
      chuckListSink.add(Response.completed(measurement));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      logger.e(e);
    }
  }

  dispose() {
    _listController.close();
  }
}

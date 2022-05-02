import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/Pagination.dart';

class MeasurementsListWorker {
  Paging? paging;
  String? eventId;
  MeasurementsListWorker(this.eventId);

  NetworkAPI _provider = NetworkAPI();

  Future<MeasurementsList> fetchData(
      {String? name, int page = 0, int size = kDefaultMeasurementsPerPage}) async {
    final pageParam = page > 0 ? '&page=$page' : '';
    final searchParam = (name != null && name.length > 0) ? '&search=$name' : '';
    final response = await _provider.get(
        'measurements/?event=$eventId&page_size=$size$pageParam&ordering=end_wearer__name$searchParam',
        useAuth: true);
    debugPrint('Response: $response');
    var list = MeasurementsList.fromJson(response);
    this.paging = list.paging;
    return list;
  }
}

class MeasurementsListWorkerBloc {
  MeasurementsListWorker get worker {
    return _measurementsListWorker;
  }

  String? eventId;

  late MeasurementsListWorker _measurementsListWorker;
  late StreamController _listController;

  late StreamSink<Response<MeasurementsList>> chuckListSink;

  late Stream<Response<MeasurementsList>> chuckListStream;

  MeasurementsListWorkerBloc(this.eventId) {
    debugPrint('Init block EventListWorkerBloc');
    final ctrl = StreamController<Response<MeasurementsList>>();
    _listController = ctrl;

    chuckListSink = ctrl.sink;
    chuckListStream = ctrl.stream;

    _measurementsListWorker = MeasurementsListWorker(eventId);
  }

  call({String? name}) async {
    debugPrint('call auth');

    chuckListSink.add(Response.loading('Getting measurements'));
    try {
      debugPrint('try block');
      MeasurementsList measurementsList = await _measurementsListWorker.fetchData(name: name);
      debugPrint('$measurementsList');
      chuckListSink.add(Response.completed(measurementsList));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      debugPrint(e.toString());
    }
  }

  Future<MeasurementsList?> asyncCall({
    int page = 0,
    int size = kDefaultMeasurementsPerPage,
    String? name,
  }) async {
    try {
      MeasurementsList list =
          await _measurementsListWorker.fetchData(name: name, page: page, size: size);
      return list;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  dispose() {
    _listController.close();
  }
}

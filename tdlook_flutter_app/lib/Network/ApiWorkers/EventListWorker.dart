import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/Pagination.dart';
import 'package:tuple/tuple.dart';

class EventListWorker {
  String role;
  String userId;

  EventListWorker({this.role, this.userId});

  NetworkAPI _provider = NetworkAPI();

  Future<Tuple2<EventList, MeasurementsList>> fetchData() async {

    // final SharedPreferences prefs = await SharedPreferences.getInstance();



    // var accessToken = prefs.getString('access');
    var link = 'events/';
    if (role != null && role == 'dealer' && userId != null) {
      link = 'events/?user=$userId';
    }
    final response = await _provider.get(link,useAuth: true);
    if (_provider.shouldRefreshTokenFor(json:response)) {

    } else {
      return Tuple2(EventList.fromJson(response), MeasurementsList(data: [], paging: Paging()));
    }
  }
}

class EventListWorkerEndwearer extends EventListWorker {

  String provider;

  EventListWorkerEndwearer(this.provider);

  @override
  Future<Tuple2<EventList, MeasurementsList>> fetchData() async {

    print('get measurements');
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var accessToken = prefs.getString('access');
    final response = await _provider.get('measurements?provider=$provider',useAuth: true);

    var list = MeasurementsList.fromJson(response);

    print('list $list');
    List<Event> events = new List<Event>();

    list.data.forEach((element) {
      events.add(element.event);
    });
    // print('events: ${events.length}');

    return Tuple2(EventList(data: events, paging: Paging(count: events.length)), list);
  }
}

class EventListWorkerBloc {

  String provider;
  UserType userType;

  EventListWorker _eventListWorker;
  StreamController _listController;

  StreamSink<Response<Tuple2<EventList, MeasurementsList>>> chuckListSink;

  Stream<Response<Tuple2<EventList, MeasurementsList>>>  chuckListStream;

  EventListWorkerBloc(this.provider) {

    print('Init block AuthWorkerBloc');
    _listController = StreamController<Response<Tuple2<EventList, MeasurementsList>>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;
  }

  void set(UserType usertype, [String parsedAPIRole, String userId]) {
    this.userType = usertype;
    if (this.userType == UserType.salesRep) {
      _eventListWorker = EventListWorker(role: parsedAPIRole, userId: userId);
    } else {
      _eventListWorker = EventListWorkerEndwearer(provider);
    }
  }

  call() async {

    chuckListSink.add(Response.loading('Getting events list'));
    try {
      print('try block');
      Tuple2<EventList, MeasurementsList> list = await _eventListWorker.fetchData();
      print('${list.item1.data.length}');
      chuckListSink.add(Response.completed(list));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _listController?.close();
  }
}


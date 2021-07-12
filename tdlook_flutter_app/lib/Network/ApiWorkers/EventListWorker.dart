import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/Pagination.dart';
import 'package:tuple/tuple.dart';

class EventListWorker {
  Paging paging;

  String role;
  String userId;

  EventListWorker({this.role, this.userId});

  NetworkAPI _provider = NetworkAPI();

  Future<Tuple2<EventList, MeasurementsList>> fetchData({String eventName, int page = 0,
    int size = kDefaultMeasurementsPerPage}) async {

    var link = 'events/';
    final pageParam = (page ?? 0) > 0 ? '&page=$page' : '';

    if (role != null && role == 'dealer' && userId != null) {
      link = 'events/?user=$userId';
      if (eventName != null) {
        link = link + '&search=${eventName}';
      }
      link = link + '&page_size=$size$pageParam';
    } else if (eventName != null) {
      link = link + '?search=${eventName}&page_size=$size$pageParam';
    } else {
      link = link + '?page_size=$size$pageParam';
    }
    link = link + '&ordering=-status,name';
    print('link: ${link}');
    final response = await _provider.get(link,useAuth: true);
    print('events: ${response}');

    if (_provider.shouldRefreshTokenFor(json:response)) {

    } else {
      var eventList = EventList.fromJson(response);
      this.paging = eventList.paging;
      return Tuple2(eventList, MeasurementsList(data: [], paging: Paging()));
    }
  }
}

class EventListWorkerEndwearer extends EventListWorker {
  Paging paging;

  String provider;

  EventListWorkerEndwearer(this.provider);

  @override
  Future<Tuple2<EventList, MeasurementsList>> fetchData({String eventName, int page = 0,
    int size = kDefaultMeasurementsPerPage}) async {

    var link = 'measurements?provider=$provider';
        if (eventName != null) {
          link = link + '&search=${eventName}';
        }
    final pageParam = (page ?? 0) > 0 ? '&page=$page' : '';
    link = link + '$pageParam&page_size=$size&ordering=-event__status,event__name';

    print('link: ${link}');
    final response = await _provider.get(link,useAuth: true);

    var list = MeasurementsList.fromJson(response);

    print('list $list');
    List<Event> events = new List<Event>();

    list.data.forEach((element) {
      events.add(element.event);
    });
    print('events: ${events.length}');
    this.paging = Paging(count: events.length);
    return Tuple2(EventList(data: events, paging: paging), list);
  }
}

class EventListWorkerBloc {

  String provider;
  UserType userType;

  EventListWorker get worker {
    return _eventListWorker;
  }

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

  call({String eventName}) async {

    chuckListSink.add(Response.loading('Getting events list'));
    try {
      print('try block');
      Tuple2<EventList, MeasurementsList> list = await _eventListWorker.fetchData(eventName: eventName);
      print('${list.item1.data.length}');
      chuckListSink.add(Response.completed(list));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  Future<Tuple2<EventList, MeasurementsList>> asyncCall(
      {int page = 0, int size = kDefaultMeasurementsPerPage, String searchFilter}) async {
    try {
      Tuple2<EventList, MeasurementsList> list = await _eventListWorker.fetchData(eventName: searchFilter, page: page, size: size);
      return list;
    } catch (e) {
      print(e);
      return null;
    }
  }

  dispose() {
    _listController?.close();
  }
}


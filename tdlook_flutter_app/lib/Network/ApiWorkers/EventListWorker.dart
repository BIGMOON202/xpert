import 'dart:async';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/Pagination.dart';

class EventListWorker {

  NetworkAPI _provider = NetworkAPI();

  Future<EventList> fetchData() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();



    var accessToken = prefs.getString('access');
    final response = await _provider.get('events/',headers: {'Authorization':'JWT $accessToken'});
    if (_provider.shouldRefreshTokenFor(json:response)) {

    } else {
      return EventList.fromJson(response);
    }
  }
}

class EventListWorkerEndwearer extends EventListWorker {

  @override
  Future<EventList> fetchData() async {

    print('get measurements');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var accessToken = prefs.getString('access');
    final response = await _provider.get('measurements/',headers: {'Authorization':'EWJWT $accessToken'});

    var list = MeasurementsList.fromJson(response);

    print('list $list');
    List<Event> events =new List<Event>();

    list.data.forEach((element) {
      events.add(element.event);
    });
    print('events: ${events.length}');

    return EventList(data: events, paging: Paging(count: events.length));
  }
}

class EventListWorkerBloc {

  UserType userType;

  EventListWorker _eventListWorker;
  StreamController _listController;

  StreamSink<Response<EventList>> chuckListSink;

  Stream<Response<EventList>>  chuckListStream;

  EventListWorkerBloc() {


    print('Init block AuthWorkerBloc');
    _listController = StreamController<Response<EventList>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;
  }

  void set(UserType usertype) {
    this.userType = usertype;
    if (this.userType == UserType.salesRep) {
      _eventListWorker = EventListWorker();
    } else {
      _eventListWorker = EventListWorkerEndwearer();
    }
  }

  call() async {

    chuckListSink.add(Response.loading('Getting events list'));
    try {
      print('try block');
      EventList eventList = await _eventListWorker.fetchData();
      print('${eventList.data.length}');
      chuckListSink.add(Response.completed(eventList));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _listController?.close();
  }
}



import 'dart:async';

import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';

class EventInfoWorker {
  String eventId;

  EventInfoWorker({this.eventId});

  NetworkAPI _provider = NetworkAPI();

  Future<Event> fetchData() async {

    var link = 'events/';
    if (eventId != null) {
      link = 'events/$eventId/';
    }

    print('link: ${link}');
    final response = await _provider.get(link,useAuth: true);
    print('event: ${response.length}');
    if (_provider.shouldRefreshTokenFor(json:response)) {

    } else {
      return Event.fromJson(response);
    }
  }
}

class EventInfoWorkerBloc {

  String eventId;

  EventInfoWorker _eventInfoWorker;
  StreamController _controller;

  StreamSink<Response<Event>> chuckListSink;

  Stream<Response<Event>>  chuckListStream;

  EventInfoWorkerBloc(this.eventId) {

    this.eventId = eventId;
    _controller = StreamController<Response<Event>>();

    chuckListSink = _controller.sink;
    chuckListStream = _controller.stream;

    _eventInfoWorker = EventInfoWorker(eventId:eventId);
  }

  call() async {
    chuckListSink.add(Response.loading('Updating event info'));
    try {
      Event event = await _eventInfoWorker.fetchData();
      chuckListSink.add(Response.completed(event));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _controller?.close();
  }
}
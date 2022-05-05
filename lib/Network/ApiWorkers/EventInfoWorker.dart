import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/utilt/logger.dart';

class EventInfoWorker {
  String? eventId;

  EventInfoWorker({this.eventId});

  NetworkAPI _provider = NetworkAPI();

  Future<Event?> fetchData() async {
    var link = 'events/';
    if (eventId != null) {
      link = 'events/$eventId/';
    }
    logger.d('link: $link');
    final response = await _provider.get(link, useAuth: true);
    logger.d('event: ${response.length}');
    if (_provider.shouldRefreshTokenFor(json: response)) {
      return null;
    } else {
      return Event.fromJson(response);
    }
  }
}

class EventInfoWorkerBloc {
  String? eventId;

  late EventInfoWorker _eventInfoWorker;
  late StreamController _controller;
  late StreamSink<Response<Event>> chuckListSink;
  late Stream<Response<Event>> chuckListStream;

  EventInfoWorkerBloc(this.eventId) {
    this.eventId = eventId;

    final ctrl = StreamController<Response<Event>>();
    _controller = ctrl;

    chuckListSink = ctrl.sink;
    chuckListStream = ctrl.stream;

    _eventInfoWorker = EventInfoWorker(eventId: eventId);
  }

  call() async {
    chuckListSink.add(Response.loading('Updating event info'));
    try {
      Event? event = await _eventInfoWorker.fetchData();
      chuckListSink.add(Response.completed(event));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      logger.e(e);
    }
  }

  dispose() {
    _controller.close();
  }
}

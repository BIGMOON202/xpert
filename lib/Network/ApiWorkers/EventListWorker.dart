import 'dart:async';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Models/MeasurementModel.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/Pagination.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';
import 'package:tuple/tuple.dart';

class EventListWorker {
  Paging? paging;

  String? role;
  String? userId;

  EventListWorker({this.role, this.userId});

  NetworkAPI _provider = NetworkAPI();

  Future<Tuple2<EventList, MeasurementsList>?> fetchData({
    String? eventName,
    int page = 0,
    int size = kDefaultMeasurementsPerPage,
  }) async {
    var link = 'events/';
    final pageParam = page > 0 ? '&page=$page' : '';

    if (role != null && role == 'dealer' && userId != null) {
      link = 'events/?user=$userId';
      if (eventName != null) {
        link = link + '&search=$eventName';
      }
      link = link + '&page_size=$size$pageParam';
    } else if (eventName != null) {
      link = link + '?search=$eventName&page_size=$size$pageParam';
    } else {
      link = link + '?page_size=$size$pageParam';
    }
    link = link + '&ordering=-created_at';

    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('userType');
    final userType = EnumToString.fromString(UserType.values, value ?? '');
    if (userType == UserType.salesRep) {
      // Fix: EF-2647
      link = link + '&is_archived=0';
      // Fix: EF-2478, EF-2478 - updated
      // scheduled, in_progress, completed, draft, cancelled
      link = link + '&status__in=scheduled,in_progress,completed,draft';
    }

    //link = link + '&status=-created_at';
    logger.d('link: $link');
    final response = await _provider.get(link, useAuth: true);
    if (_provider.shouldRefreshTokenFor(json: response)) {
      return null;
    } else {
      // final prefs = await SharedPreferences.getInstance();
      // final value = prefs.getString('userType');
      // final userType = EnumToString.fromString(UserType.values, value ?? '');
      // logger.d('userType: $userType');
      final eventList = EventList.fromJson(response);
      // if (userType == UserType.salesRep) {
      //   // Fix: EF-2478
      //   final filtered = eventList.data
      //       ?.where((o) => o.status != EventStatus.draft && o.status != EventStatus.cancelled)
      //       .toList();
      //   eventList = EventList(data: filtered, paging: eventList.paging);
      // }

      this.paging = eventList.paging;
      return Tuple2(
        eventList,
        MeasurementsList(
          data: [],
          paging: Paging(),
        ),
      );
    }
  }
}

class EventListWorkerEndwearer extends EventListWorker {
  Paging? paging;

  String? provider;

  EventListWorkerEndwearer(this.provider);

  @override
  Future<Tuple2<EventList, MeasurementsList>> fetchData({
    String? eventName,
    int page = 0,
    int size = kDefaultMeasurementsPerPage,
  }) async {
    var link = 'measurements?provider=$provider';
    if (eventName != null) {
      link = link + '&search=${eventName}';
    }
    final pageParam = page > 0 ? '&page=$page' : '';
    link = link + '$pageParam&page_size=$size&ordering=-event__status,event__name';

    logger.d('link: ${link}');
    final response = await _provider.get(link, useAuth: true);

    var list = MeasurementsList.fromJson(response);

    logger.d('list $list');
    List<Event> events = <Event>[];

    list.data?.forEach((element) {
      if (element.event != null) {
        events.add(element.event!);
      }
    });
    logger.d('events: ${events.length}');
    this.paging = Paging(count: events.length);
    return Tuple2(EventList(data: events, paging: paging), list);
  }
}

class EventListWorkerBloc {
  String? provider;
  UserType? userType;

  EventListWorker get worker {
    return _eventListWorker ?? EventListWorker();
  }

  EventListWorker? _eventListWorker;
  late StreamController _listController;

  late StreamSink<Response<Tuple2<EventList, MeasurementsList>>> chuckListSink;

  late Stream<Response<Tuple2<EventList, MeasurementsList>>> chuckListStream;

  EventListWorkerBloc(this.provider) {
    final ctrl = StreamController<Response<Tuple2<EventList, MeasurementsList>>>();
    _listController = ctrl;

    chuckListSink = ctrl.sink;
    chuckListStream = ctrl.stream;
  }

  void set(UserType usertype, [String? parsedAPIRole, String? userId]) {
    this.userType = usertype;
    if (this.userType == UserType.salesRep) {
      _eventListWorker = EventListWorker(role: parsedAPIRole, userId: userId);
    } else {
      _eventListWorker = EventListWorkerEndwearer(provider);
    }
  }

  call({String? eventName}) async {
    chuckListSink.add(Response.loading('Getting events list'));
    try {
      Tuple2<EventList, MeasurementsList>? list =
          await _eventListWorker?.fetchData(eventName: eventName);
      logger.d('${list?.item1.data?.length}');
      chuckListSink.add(Response.completed(list));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      logger.e(e);
    }
  }

  Future<Tuple2<EventList, MeasurementsList>?> asyncCall({
    int page = 0,
    int size = kDefaultMeasurementsPerPage,
    String? searchFilter,
  }) async {
    try {
      Tuple2<EventList, MeasurementsList>? list =
          await _eventListWorker?.fetchData(eventName: searchFilter, page: page, size: size);
      return list;
    } catch (e) {
      logger.e(e);
      return null;
    }
  }

  dispose() {
    _listController.close();
  }
}

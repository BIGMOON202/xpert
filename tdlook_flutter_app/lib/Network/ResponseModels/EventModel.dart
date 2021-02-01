import 'package:tdlook_flutter_app/Network/ResponseModels/Pagination.dart';
import 'dart:convert';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';

class EventList implements Paginated<Event> {
  List<Event> data;
  Paging paging;

  EventList({
    this.data,
    this.paging,
  });

  factory EventList.fromRawJson(String str) => EventList.fromJson(json.decode(str));

  factory EventList.fromJson(Map<String, dynamic> json) => EventList(
    data: List<Event>.from(json["results"].map((x) => Event.fromJson(x))),
    paging: Paging.fromJson(json),
  );

  Map<String, dynamic> toJson() => {
    "results": List<dynamic>.from(data.map((x) => x.toJson())),
    "paging": paging.toJson(),
  };
}


class Event {
  int id;
  String name;
  Agency agency;
  int agencyId;
  SalesRep salesRep;
  int salesRepId;
  String startDate;
  String endDate;
  EventStatus status;
  String createdAt;
  bool progress;
  int totalMeasuremensCount;
  int completeMeasuremensCount;

  Event(
      {this.id,
        this.name,
        this.agency,
        this.agencyId,
        this.salesRep,
        this.salesRepId,
        this.startDate,
        this.endDate,
        this.status,
        this.createdAt,
        this.progress,
        this.totalMeasuremensCount,
        this.completeMeasuremensCount});

  Event.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    agency =
    json['agency'] != null ? new Agency.fromJson(json['agency']) : null;
    agencyId = json['agency_id'];
    salesRep = json['sales_rep'] != null
        ? new SalesRep.fromJson(json['sales_rep'])
        : null;
    salesRepId = json['sales_rep_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    status = EnumToString.fromString(EventStatus.values, json['status']);
    createdAt = json['created_at'];
    progress = json['progress'];

    totalMeasuremensCount = json['total_measurements_count'] != null ? json['total_measurements_count'] : 0;
    completeMeasuremensCount = json['complete_measurements_count'] != null ? json['complete_measurements_count'] : 0;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.agency != null) {
      data['agency'] = this.agency.toJson();
    }
    if (this.agencyId != null) {
      data['agency_id'] = this.agencyId;
    }
    if (this.salesRep != null) {
      data['sales_rep'] = this.salesRep.toJson();
    }
    if (this.salesRepId != null) {
      data['sales_rep_id'] = this.salesRepId;
    }
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['status'] = EnumToString.convertToString(this.status);
    data['created_at'] = this.createdAt;
    data['progress'] = this.progress;
    return data;
  }
}

enum EventStatus {
  scheduled, in_progress, completed, draft, cancelled
}

extension EventStatusExtension on EventStatus {
  String displayName() {
    return EnumToString.convertToString(this).replaceAll('_', ' ').capitalize();
  }

  Color displayColor() {
    switch (this) {
      case EventStatus.scheduled: return Colors.white;
      case EventStatus.cancelled: return Colors.red;
      case EventStatus.completed: return HexColor.fromHex('4AA61D');
      case EventStatus.draft: return Colors.white;
      case EventStatus.in_progress: return HexColor.fromHex('E89751');

    }
  }

  bool shouldShowCountGraph() {
    switch(this) {
      case EventStatus.scheduled:
      case EventStatus.draft: return false;
      default: return true;

    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}


class Agency {
  int id;
  String name;
  String type;

  Agency({this.id, this.name, this.type});

  Agency.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    return data;
  }
}

class SalesRep {
  int id;
  String firstName;
  String lastName;
  String dealerFullName;

  SalesRep({this.id, this.firstName, this.lastName, this.dealerFullName});

  SalesRep.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    dealerFullName = json['dealer_full_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['dealer_full_name'] = this.dealerFullName;
    return data;
  }
}

class EndWearer {
  int id;
  String name;
  String email;
  String phone;
  bool isActive;
  int creator;
  int event;
  String createdAt;
  String updatedAt;

  EndWearer({this.id, this.name, this.email, this.phone, this.isActive, this.creator, this.event, this.createdAt, this.updatedAt});

  EndWearer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    isActive = json['is_active'];
    creator = json['creator'];
    event = json['event'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['is_active'] = this.isActive;
    data['creator'] = this.creator;
    data['event'] = this.event;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class MeasurementResults {
  int id;
  String uuid;
  bool isActive;
  bool isComplete;
  String completedAt;
  EndWearer endWearer;
  Event event;
  String gender;
  double height;
  double weight;
  double clavicle;
  Person person;
  String createdAt;
  String updatedAt;
  List<Messages> messages;

  MeasurementResults({this.id, this.uuid, this.isActive, this.isComplete, this.completedAt, this.endWearer, this.event, this.gender, this.height, this.weight, this.clavicle, this.person, this.createdAt, this.updatedAt, this.messages});

  MeasurementResults.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    isActive = json['is_active'];
    isComplete = json['is_complete'];
    completedAt = json['completed_at'];
    endWearer = json['end_wearer'] != null ? new EndWearer.fromJson(json['end_wearer']) : null;
    event = json['event'] != null ? new Event.fromJson(json['event']) : null;
    gender = json['gender'];
    height = json['height'] != null ? double.parse(json['height'].toString()) : 0.0 ;
    weight = json['weight'] != null ? double.parse(json['weight'].toString()) : 0.0 ;
    clavicle = json['clavicle'] != null ? double.parse(json['clavicle'].toString()) : 0.0 ;
    person = json['person'] != null ? new Person.fromJson(json['person']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['messages'] != null) {
      messages = new List<Messages>();
      json['messages'].forEach((v) { messages.add(new Messages.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['id'] = this.id;
    // data['uuid'] = this.uuid;
    data['is_active'] = this.isActive.toString();
    // data['is_complete'] = this.isComplete;
    // data['completed_at'] = this.completedAt;
    // if (this.endWearer != null) {
    //   data['end_wearer'] = this.endWearer.toJson();
    // }
    // if (this.event != null) {
    //   data['event'] = this.event.toJson();
    // }
    data['gender'] = this.gender;
    data['height'] = this.height.toInt().toString();
    data['weight'] = this.weight.toInt().toString();
    if (this.clavicle != null && this.clavicle > 0) {
      data['clavicle'] = this.clavicle.toString();
    }
    // if (this.person != null) {
    //   data['person'] = this.person.toJson();
    // }
    // data['created_at'] = this.createdAt;
    // data['updated_at'] = this.updatedAt;
    // if (this.messages != null) {
    //   data['messages'] = this.messages.map((v) => v.toJson()).toList();
    // }
    return data;
  }
}

extension MeasurementResultsExtension on MeasurementResults {
  Color statusColor() {
    return isComplete == true ? HexColor.fromHex('4AA61D') : HexColor.fromHex('E89751');
  }

  String statusName() {
    return isComplete == true ? 'Measured' : 'Not measured';
  }

  String statusIconName() {
    return isComplete == true ? 'ic_measured.png' : 'ic_not_measured.png';
  }
}

class Person {
  Person();

  Person.fromJson(Map<String, dynamic> json) {
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}

class Messages {
  int id;
  String type;
  String metric;
  String createdAt;

  Messages({this.id, this.type, this.metric, this.createdAt});

  Messages.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    metric = json['metric'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['metric'] = this.metric;
    data['created_at'] = this.createdAt;
    return data;
  }
}
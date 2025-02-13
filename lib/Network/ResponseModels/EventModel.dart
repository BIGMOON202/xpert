import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:tdlook_flutter_app/Extensions/Application.dart';
import 'package:tdlook_flutter_app/Extensions/Colors+Extension.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/Pagination.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';

class EventList implements Paginated<Event> {
  List<Event>? data;
  Paging? paging;
  int? count;

  EventList({
    this.data,
    this.paging,
    this.count,
  });

  factory EventList.fromRawJson(String str) => EventList.fromJson(json.decode(str));

  factory EventList.fromJson(Map<String, dynamic> json) => EventList(
        count: json["count"] as int,
        data: List<Event>.from(json["results"].map((x) => Event.fromJson(x))),
        paging: Paging.fromJson(json),
      );

  Map<String, dynamic> toJson() => {
        "results": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
        "paging": paging?.toJson(),
      };
}

class AnalizeResult {
  String? event;
  String? status;
  String? errorCode;
  List<Detail>? detail;
  Data? data;

  AnalizeResult({this.event, this.status, this.errorCode, this.detail, this.data});

  AnalizeResult.fromJson(Map<String, dynamic> json) {
    event = json['event'];
    status = json['status'];
    errorCode = json['error_code'];
    logger.d('result: $json, type: ${json.runtimeType}');
    logger
        .e('errorCode: $errorCode, detail: ${json['detail']}, type: ${json['detail'].runtimeType}');
    if (errorCode != null && errorCode == 'validation_error' && json['detail'] != null) {
      detail = <Detail>[];
      json['detail'].forEach((v) {
        detail?.add(new Detail.fromJson(v));
      });
    }
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['event'] = this.event;
    data['status'] = this.status;
    data['error_code'] = this.errorCode;
    if (this.detail != null) {
      data['detail'] = this.detail?.map((v) => v.toJson()).toList();
    }
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    return data;
  }
}

class Detail {
  ErrorProcessingType? type;
  String? status;
  String? taskId;
  String? message;

  Detail({
    this.type,
    this.status,
    this.taskId,
    this.message,
  });

  Detail.fromJson(Map<String, dynamic> json) {
    type = EnumToString.fromString(ErrorProcessingType.values, json['name']);
    status = json['status'];
    taskId = json['task_id'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['task_id'] = this.taskId;
    data['message'] = this.message;
    return data;
  }
}

enum ErrorProcessingType { front_skeleton_processing, side_skeleton_processing }

class Data {
  int? measurementId;

  Data({this.measurementId});

  Data.fromJson(Map<String, dynamic> json) {
    measurementId = json['measurement_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['measurement_id'] = this.measurementId;
    return data;
  }
}

class Event {
  int? id;
  String? name;
  Agency? agency;
  int? agencyId;
  SalesRep? salesRep;
  int? salesRepId;
  String? startDate;
  String? endDate;
  DateTime? startDateTime;
  DateTime? endDateTime;
  EventStatus? status;
  String? createdAt;
  bool? progress;
  int? totalMeasuremensCount;
  int? completeMeasuremensCount;
  List<dynamic>? productTypes;
  bool? manualOverlap;
  bool? outerCarrier;

  Event({
    this.id,
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
    this.completeMeasuremensCount,
    this.productTypes,
    this.manualOverlap,
    this.outerCarrier,
  });

  Event.fromJson(Map<String, dynamic> json) {
    logger.d('Event: $json');
    id = json['id'];
    name = json['name'];
    agency = json['agency'] != null ? new Agency.fromJson(json['agency']) : null;
    agencyId = json['agency_id'];
    salesRep = json['sales_rep'] != null ? new SalesRep.fromJson(json['sales_rep']) : null;
    salesRepId = json['sales_rep_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    startDateTime = startDate != null ? DateTime.parse(startDate!) : null;
    endDateTime = endDate != null ? DateTime.parse(endDate!) : null;
    status = EnumToString.fromString(EventStatus.values, json['status']);
    createdAt = json['created_at'];
    progress = json['progress'];

    totalMeasuremensCount =
        json['total_measurements_count'] != null ? json['total_measurements_count'] : 0;
    completeMeasuremensCount =
        json['complete_measurements_count'] != null ? json['complete_measurements_count'] : 0;
    productTypes = json['product_types'] != null ? json['product_types'] : [];
    logger.d('parsed overlap ${json['overlap']}');
    manualOverlap = ((json['overlap'] == null) ||
        (json['overlap'] == 'selected' || json['overlap'] == 'Selected'));
    outerCarrier = json['outer_carrier'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.agency != null) {
      data['agency'] = this.agency?.toJson();
    }
    if (this.agencyId != null) {
      data['agency_id'] = this.agencyId;
    }
    if (this.salesRep != null) {
      data['sales_rep'] = this.salesRep?.toJson();
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

extension EventExtension on Event {
  bool shouldAskForWaistLevel() {
    if (Application.isInDebugMode) {
      return true;
    }
    var pantsKey = EnumToString.convertToString(EventProduct.pants);
    if (this.productTypes?.contains(pantsKey) == true) {
      return true;
    }
    return false;
  }
}

enum EventProduct { long_sleeve_shirt, pants, outerwear }

enum EventStatus { scheduled, in_progress, completed, draft, cancelled }

extension EventStatusExtension on EventStatus {
  String displayName() {
    return EnumToString.convertToString(this).replaceAll('_', ' ').capitalize();
  }

  Color displayColor() {
    switch (this) {
      case EventStatus.scheduled:
        return Colors.white;
      case EventStatus.cancelled:
        return Colors.red;
      case EventStatus.completed:
        return HexColor.fromHex('4AA61D');
      case EventStatus.draft:
        return HexColor.fromHex('1E7AE4');
      case EventStatus.in_progress:
        return HexColor.fromHex('E89751');
    }
  }

  Color textColor() {
    switch (this) {
      case EventStatus.scheduled:
        return Colors.black;
      case EventStatus.cancelled:
        return Colors.red;
      case EventStatus.completed:
        return HexColor.fromHex('4AA61D');
      case EventStatus.draft:
        return HexColor.fromHex('1E7AE4');
      case EventStatus.in_progress:
        return HexColor.fromHex('E89751');
    }
  }

  bool shouldShowCountGraph() {
    switch (this) {
      case EventStatus.scheduled:
      case EventStatus.draft:
        return false;
      default:
        return true;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class Agency {
  int? id;
  String? name;
  String? type;

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
  int? id;
  String? firstName;
  String? lastName;
  String? dealerFullName;

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
  int? id;
  String? name;
  String? email;
  String? phone;
  bool? isActive;
  int? creator;
  int? event;
  String? createdAt;
  String? updatedAt;

  EndWearer(
      {this.id,
      this.name,
      this.email,
      this.phone,
      this.isActive,
      this.creator,
      this.event,
      this.createdAt,
      this.updatedAt});

  EndWearer.fromJson(Map<String, dynamic> json) {
    if (json is Map<String, dynamic>) {
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
  int? id;
  String? uuid;
  bool? isActive;
  bool? isComplete;
  bool? isCalculating;
  String? completedAt;
  DateTime? completedAtTime;
  bool? askForWaistLevel;
  bool? askForOverlap;
  String? selectedTopSize;
  String? selectedBottomSize;
  AnalizeResult? error;
  EndWearer? endWearer;
  Event? event;
  String? gender;
  double? height;
  double? weight;
  double? clavicle;
  String? waistLevel;
  String? fitType;
  bool? outerCarrier;
  String? overlap;
  Person? person;
  String? createdAt;
  String? updatedAt;
  String? badgeId;
  List<Messages>? messages;

  MeasurementResults({
    this.id,
    this.uuid,
    this.isActive,
    this.isComplete,
    this.completedAt,
    this.endWearer,
    this.event,
    this.gender,
    this.height,
    this.weight,
    this.clavicle,
    this.person,
    this.createdAt,
    this.updatedAt,
    this.messages,
    this.isCalculating,
    this.error,
    this.outerCarrier,
  });

  MeasurementResults.fromJson(Map<String, dynamic> json) {
    logger.d('MeasurementResults: $json');
    id = json['id'];
    uuid = json['uuid'];
    isActive = json['is_active'];
    isComplete = json['is_complete'];
    isCalculating = json['is_in_progress'];
    completedAt = json['completed_at'];
    if (completedAt != null) {
      completedAtTime = DateTime.parse(completedAt!);
    }

    if ((json['end_wearer'] != null) && (json['end_wearer'] is Map<String, dynamic>)) {
      endWearer = new EndWearer.fromJson(json['end_wearer']);
    }

    if ((json['event'] != null) && (json['event'] is Map<String, dynamic>)) {
      event = new Event.fromJson(json['event']);
    }

    gender = json['gender'];
    height = json['height'] != null ? double.parse(json['height'].toString()) : 0.0;
    weight = json['weight'] != null ? double.parse(json['weight'].toString()) : 0.0;
    clavicle = json['clavicle'] != null ? double.parse(json['clavicle'].toString()) : 0.0;
    person = json['person'] != null ? new Person.fromJson(json['person']) : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    badgeId = json['badge_id'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages?.add(new Messages.fromJson(v));
      });
    }

    logger.e('error: ${json['error']} // ${json['error'].runtimeType}');
    if ((json['error'] != null) && (json['error'] is Map<String, dynamic>)) {
      error = new AnalizeResult.fromJson(json['error']);
    }
    outerCarrier = json['outer_carrier'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['id'] = this.id;
    // data['uuid'] = this.uuid;
    // data['is_active'] = this.isActive.toString();
    // data['is_complete'] = this.isComplete;
    // data['completed_at'] = this.completedAt;
    // if (this.endWearer != null) {
    //   data['end_wearer'] = this.endWearer.toJson();
    // }
    // if (this.event != null) {
    //   data['event'] = this.event.toJson();
    // }
    if (this.waistLevel != null) {
      data['waist_level'] = this.waistLevel;
    }
    if (this.fitType != null) {
      data['preferred_fit'] = this.fitType;
    }
    if (this.overlap != null) {
      data['overlap'] = this.overlap;
    }
    if (this.selectedTopSize != null) {
      data['selected_top_size'] = this.selectedTopSize;
    }
    if (this.selectedBottomSize != null) {
      data['selected_bottom_size'] = this.selectedBottomSize;
    }
    if (this.outerCarrier != null) {
      data['outer_carrier'] = this.outerCarrier.toString();
    }
    data['gender'] = this.gender;
    data['height'] = this.height?.toInt().toString();
    data['weight'] = this.weight?.toInt().toString();
    if (this.clavicle != null && this.clavicle! > 0) {
      data['manual_clavicle'] = this.clavicle.toString();
    }
    if (this.badgeId != null && this.badgeId?.isEmpty == false) {
      data['badge_id'] = this.badgeId;
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
  FrontParams? frontParams;
  Person({this.frontParams});

  Person.fromJson(Map<String, dynamic> json) {
    frontParams =
        json['front_params'] != null ? new FrontParams.fromJson(json['front_params']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}

class FrontParams {
  double? rise;
  double? inseam;
  double? waist;
  double? sleeve;

  FrontParams({this.rise, this.inseam, this.waist});

  FrontParams.fromJson(Map<String, dynamic> json) {
    rise = json['rise'];
    inseam = json['inside_leg_height'];
    waist = json['waist'];
    waist = json['sleeve'];
  }
}

extension InchExtension on double {
  double get inImperial {
    return this / 2.54;
  }
}

class Messages {
  int? id;
  String? type;
  String? metric;
  String? createdAt;

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

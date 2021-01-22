import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/Pagination.dart';
import 'dart:convert';

class MeasurementsList implements Paginated<MeasurementResults> {
  List<MeasurementResults> data;
  Paging paging;

  MeasurementsList({
    this.data,
    this.paging,
  });

  factory MeasurementsList.fromRawJson(String str) => MeasurementsList.fromJson(json.decode(str));

  factory MeasurementsList.fromJson(Map<String, dynamic> json) => MeasurementsList(
    data: List<MeasurementResults>.from(json["results"].map((x) => MeasurementResults.fromJson(x))),
    paging: Paging.fromJson(json),
  );

  Map<String, dynamic> toJson() => {
    "results": List<dynamic>.from(data.map((x) => x.toJson())),
    "paging": paging.toJson(),
  };
}
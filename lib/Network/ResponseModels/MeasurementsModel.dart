import 'dart:convert';

import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/Pagination.dart';

class MeasurementsList implements Paginated<MeasurementResults> {
  List<MeasurementResults>? data;
  Paging? paging;

  MeasurementsList({
    this.data,
    this.paging,
  });

  factory MeasurementsList.fromRawJson(String str) => MeasurementsList.fromJson(json.decode(str));

  factory MeasurementsList.fromJson(Map<String, dynamic> json) => MeasurementsList(
        data: List<MeasurementResults>.from(
                json["results"].map((x) => MeasurementResults.fromJson(x)))
            .where((i) => i.isActive == true)
            .toList(),
        paging: Paging.fromJson(json),
      );

  Map<String, dynamic> toJson() => {
        "results": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
        "paging": paging?.toJson(),
      };
}

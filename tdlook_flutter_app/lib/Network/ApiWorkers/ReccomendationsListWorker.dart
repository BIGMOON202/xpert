import 'dart:async';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/EventModel.dart';
import 'package:tdlook_flutter_app/Network/ResponseModels/MeasurementsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendationsListWorker {

  String measurementId;
  RecommendationsListWorker(this.measurementId);

  NetworkAPI _provider = NetworkAPI();

  Future<List<RecommendationModel>> fetchData() async {

    final response = await _provider.get('measurements/${measurementId}/get_recommendations/',useAuth: true);

    print('olo: $response');
    var results = List<RecommendationModel>();
    results = (response as List)?.map((item) => RecommendationModel.fromJson(item))?.toList();
    return results;
  }
}

class RecommendationsListBLOC {

  String measurementId;

  RecommendationsListWorker _recommendationsListWorker;
  StreamController _listController;

  StreamSink<Response<List<RecommendationModel>>> chuckListSink;

  Stream<Response<List<RecommendationModel>>>  chuckListStream;

  RecommendationsListBLOC(this.measurementId) {

    print('Init block RecommendationsListBLOC');
    _listController = StreamController<Response<List<RecommendationModel>>>();

    chuckListSink = _listController.sink;
    chuckListStream = _listController.stream;

    _recommendationsListWorker = RecommendationsListWorker(measurementId);
  }

  call() async {
    print('call auth');

    chuckListSink.add(Response.loading('Getting measurements'));
    try {
      print('try block');
      List<RecommendationModel> measurementsList = await _recommendationsListWorker.fetchData();
      print('$measurementsList');
      chuckListSink.add(Response.completed(measurementsList));
    } catch (e) {
      chuckListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _listController?.close();
  }
}


class RecommendationModel {
  int measurement;
  String size;
  String sizeSecond;
  RawResponseData rawResponseData;
  Product product;

  RecommendationModel(
      {this.measurement,
        this.size,
        this.sizeSecond,
        this.rawResponseData,
        this.product});

  RecommendationModel.fromJson(Map<String, dynamic> json) {
    print(json);
    measurement = json['measurement'];
    size = json['size'];
    sizeSecond = json['size_second'];
    rawResponseData = json['raw_response_data'] != null
        ? new RawResponseData.fromJson(json['raw_response_data'])
        : null;
    product =
    json['product'] != null ? new Product.fromJson(json['product']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['measurement'] = this.measurement;
    data['size'] = this.size;
    data['size_second'] = this.sizeSecond;
    if (this.rawResponseData != null) {
      data['raw_response_data'] = this.rawResponseData.toJson();
    }
    if (this.product != null) {
      data['product'] = this.product.toJson();
    }
    return data;
  }
}

class RawResponseData {
  String errors;

  RawResponseData({this.errors});

  RawResponseData.fromJson(Map<String, dynamic> json) {
    errors = json['errors'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['errors'] = this.errors;
    return data;
  }
}

class Product {
  int id;
  String name;
  String brand;
  String category;
  String style;
  String gender;
  String status;
  String createdAt;

  Product(
      {this.id,
        this.name,
        this.brand,
        this.category,
        this.style,
        this.gender,
        this.status,
        this.createdAt});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    brand = json['brand'];
    category = json['category'];
    style = json['style'];
    gender = json['gender'];
    status = json['status'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['brand'] = this.brand;
    data['category'] = this.category;
    data['style'] = this.style;
    data['gender'] = this.gender;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    return data;
  }
}
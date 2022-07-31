import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/data/repositories/base/base_repository.dart';
import 'package:tdlook_flutter_app/data/repositories/end_wearer/end_wearer_repository.dart';
import 'package:tdlook_flutter_app/utilt/logger.dart';

@LazySingleton(as: EWRepository)
class EWRepositoryImpl extends BaseRepository implements EWRepository {
  final NetworkAPI _api = NetworkAPI();

  EWRepositoryImpl();

  @override
  Future<bool?> addToEvent(
    int id, {
    required String name,
    String? email,
    String? phone,
    required bool isActive,
  }) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final Map<String, dynamic> body = {};
      body['event'] = id;
      body['name'] = name;

      if (email?.isNotEmpty == true) {
        body['email'] = email;
      }
      if (phone?.isNotEmpty == true) {
        body['phone'] = phone;
      }
      body['is_active'] = isActive;
      logger.d('BODY: $body');

      final response = await _api.post(
        "end_wearers/",
        body: body,
        useAuth: true,
        headers: headers,
      );
      logger.d('RESPONSE1: $response');
      final int code = response.statusCode;

      return true;
    } catch (e) {
      handleError(e);
    }
  }
}

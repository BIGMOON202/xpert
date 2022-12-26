import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:tdlook_flutter_app/Extensions/String+Extension.dart';
import 'package:tdlook_flutter_app/Network/Network_API.dart';
import 'package:tdlook_flutter_app/data/enums/invite_type.dart';
import 'package:tdlook_flutter_app/data/models/responses/invite_ew_response.dart';
import 'package:tdlook_flutter_app/data/repositories/base/base_repository.dart';
import 'package:tdlook_flutter_app/data/repositories/end_wearer/end_wearer_repository.dart';
import 'package:tdlook_flutter_app/data/sources/base/base_remote_source.dart';
import 'package:tdlook_flutter_app/common/logger/logger.dart';

@LazySingleton(as: EWRepository)
class EWRepositoryImpl extends BaseRepository implements EWRepository {
  final NetworkAPI _api = NetworkAPI();

  EWRepositoryImpl();

  @override
  Future<bool?> invite(
    InviteType type, {
    required Id ewId,
    required Id eventId,
  }) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final JsonData body = {};
      body['end_wearer_ids'] = [ewId];

      String method = '';
      switch (type) {
        case InviteType.sms:
          method = 'send_sms';
          break;
        case InviteType.email:
          method = 'send_email';
          break;
      }

      final data = await _api.post(
        "events/$eventId/$method/",
        body: body,
        useAuth: true,
        isJsonBody: true,
        headers: headers,
      );

      logger.d('RESPONSE_DATA_1: $data');

      return data.toString().isNotEmpty;
    } catch (e) {
      handleError(e);
      return null;
    }
  }

  @override
  Future<InviteEwResponse?> addToEvent(
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
      final JsonData body = {};
      body['event'] = id;
      body['name'] = name;

      if (email?.isNotEmpty == true) {
        body['email'] = email;
      }
      if (phone?.isNotEmpty == true) {
        final digits = phone?.onlyDigits ?? '';
        body['phone'] = '+$digits';
      }
      body['is_active'] = isActive;

      final data = await _api.post(
        "end_wearers/",
        body: body,
        useAuth: true,
        isJsonBody: true,
        headers: headers,
      );
      final response = InviteEwResponse.fromJson(jsonDecode(data.toString()));
      return response;
    } catch (e) {
      handleError(e);
      return null;
    }
  }
}

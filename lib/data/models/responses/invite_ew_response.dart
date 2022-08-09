// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tdlook_flutter_app/data/sources/base/base_remote_source.dart';

part 'invite_ew_response.freezed.dart';
part 'invite_ew_response.g.dart';

/*
"id": 0,
"name": "string",
"email": "user@example.com",
"phone": "string",
"is_active": true,
"creator": 0,
"event": 0,
"created_at": "2019-08-24T14:15:22Z",
"updated_at": "2019-08-24T14:15:22Z"

*/

@freezed
class InviteEwResponse with _$InviteEwResponse {
  factory InviteEwResponse({
    required Id id,
    @JsonKey(name: 'creator') Id? creatorId,
    @JsonKey(name: 'event') Id? eventId,
    String? name,
    String? phone,
    String? email,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _InviteEwResponse;
  factory InviteEwResponse.fromJson(Map<String, dynamic> json) => _$InviteEwResponseFromJson(json);
}

extension InviteEwResponseExt on InviteEwResponse {}

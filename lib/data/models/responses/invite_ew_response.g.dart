// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_ew_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_InviteEwResponse _$$_InviteEwResponseFromJson(Map<String, dynamic> json) =>
    _$_InviteEwResponse(
      id: json['id'] as int,
      creatorId: json['creator'] as int?,
      eventId: json['event'] as int?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$_InviteEwResponseToJson(_$_InviteEwResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creator': instance.creatorId,
      'event': instance.eventId,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

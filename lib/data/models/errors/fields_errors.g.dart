// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fields_errors.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_FieldsErrors _$$_FieldsErrorsFromJson(Map<String, dynamic> json) =>
    _$_FieldsErrors(
      name: (json['name'] as List<dynamic>?)?.map((e) => e as String).toList(),
      email:
          (json['email'] as List<dynamic>?)?.map((e) => e as String).toList(),
      phone:
          (json['phone'] as List<dynamic>?)?.map((e) => e as String).toList(),
      event:
          (json['event'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$_FieldsErrorsToJson(_$_FieldsErrors instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'event': instance.event,
    };

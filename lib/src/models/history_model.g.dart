// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_HistoryModel _$$_HistoryModelFromJson(Map<String, dynamic> json) =>
    _$_HistoryModel(
      data: json['data'] as String,
      type: json['type'] as String?,
      starred: json['pinned'] as bool,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$_HistoryModelToJson(_$_HistoryModel instance) =>
    <String, dynamic>{
      'data': instance.data,
      'type': instance.type,
      'pinned': instance.starred,
      'created_at': instance.createdAt,
    };

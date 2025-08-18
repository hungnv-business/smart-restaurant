// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String?,
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      isActive: json['isActive'] as bool?,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
      extraProperties: json['extraProperties'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'email': instance.email,
      'name': instance.name,
      'surname': instance.surname,
      'phoneNumber': instance.phoneNumber,
      'isActive': instance.isActive,
      'roles': instance.roles,
      'extraProperties': instance.extraProperties,
    };

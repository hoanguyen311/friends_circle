// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
      nickName: json['nickName'] as String,
      photoUrl: json['photoUrl'] as String,
      id: json['id'] as String,
      aboutMe: json['aboutMe'] as String);
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'nickName': instance.nickName,
      'photoUrl': instance.photoUrl,
      'id': instance.id,
      'aboutMe': instance.aboutMe
    };

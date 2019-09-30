// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UnsplashImage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnsplashImage _$UnsplashImageFromJson(Map<String, dynamic> json) {
  return UnsplashImage(
      json['id'] as String,
      json['description'] as String,
      json['alt_description'] as String,
      json['color'] as String,
      json['width'] as int,
      json['height'] as int,
      json['urls'] == null
          ? null
          : UnsplashImageUrls.fromJson(json['urls'] as Map<String, dynamic>),
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>));
}

Map<String, dynamic> _$UnsplashImageToJson(UnsplashImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'alt_description': instance.alt_description,
      'color': instance.color,
      'width': instance.width,
      'height': instance.height,
      'urls': instance.urls,
      'user': instance.user
    };

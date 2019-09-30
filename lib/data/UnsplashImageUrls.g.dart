// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UnsplashImageUrls.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnsplashImageUrls _$UnsplashImageUrlsFromJson(Map<String, dynamic> json) {
  return UnsplashImageUrls(
      json['raw'] as String,
      json['full'] as String,
      json['regular'] as String,
      json['small'] as String,
      json['thumb'] as String);
}

Map<String, dynamic> _$UnsplashImageUrlsToJson(UnsplashImageUrls instance) =>
    <String, dynamic>{
      'raw': instance.raw,
      'full': instance.full,
      'regular': instance.regular,
      'small': instance.small,
      'thumb': instance.thumb
    };

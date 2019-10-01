import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_list_test/data/User.dart';
import 'package:flutter_list_test/data/UnsplashImageUrls.dart';
part 'UnsplashImage.g.dart';

@JsonSerializable()
class UnsplashImage {

  final String id;
  final String description;
  final String alt_description;
  final String color;
  final int width;
  final int height;
  final UnsplashImageUrls urls;
  final User user;
  final bool liked_by_user;

  UnsplashImage(this.id, this.description, this.alt_description, this.color, this.width, this.height, this.urls, this.user, this.liked_by_user);
  factory UnsplashImage.fromJson(Map<String, dynamic> json) => _$UnsplashImageFromJson(json);

  UnsplashImage copyWith({liked}) => new UnsplashImage(
      this.id,
      this.description,
      this.alt_description,
      this.color,
      this.width,
      this.height,
      this.urls,
      this.user,
      liked ?? this.liked_by_user);
}

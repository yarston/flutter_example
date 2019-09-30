import 'package:json_annotation/json_annotation.dart';
part 'UnsplashImageUrls.g.dart';

@JsonSerializable()
class UnsplashImageUrls {

  final String raw;
  final String full;
  final String regular;
  final String small;
  final String thumb;

  UnsplashImageUrls(this.raw, this.full, this.regular, this.small, this.thumb);
  factory UnsplashImageUrls.fromJson(Map<String, dynamic> json) => _$UnsplashImageUrlsFromJson(json);
}

import 'package:json_annotation/json_annotation.dart';
part 'User.g.dart';

@JsonSerializable()
class User {
  String username;
  User(this.username);
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

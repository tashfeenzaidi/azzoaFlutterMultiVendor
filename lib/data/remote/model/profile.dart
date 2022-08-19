import 'package:azzoa_grocery/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Profile {
  @JsonKey(required: true)
  int id;

  @JsonKey(defaultValue: kDefaultString)
  String username;

  @JsonKey(required: true)
  String name;

  @JsonKey(defaultValue: "https://www.w3schools.com/w3images/avatar2.png")
  String avatar;

  @JsonKey(defaultValue: kDefaultString)
  String email;

  @JsonKey(defaultValue: kDefaultString)
  String phone;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  @JsonKey(defaultValue: null)
  int status;

  @JsonKey(defaultValue: kDefaultInt)
  int pushNotification;

  @JsonKey(defaultValue: kDefaultInt)
  dynamic balance;

  Profile({
    this.id,
    this.username,
    this.name,
    this.avatar,
    this.email,
    this.phone,
    this.status,
    this.pushNotification,
    this.createdAt,
    this.balance
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

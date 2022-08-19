import 'package:azzoa_grocery/constants.dart';
import 'package:json_annotation/json_annotation.dart';

part 'banner.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PromoBanner {
  @JsonKey(required: true)
  int id;

  @JsonKey(required: true)
  String title;

  @JsonKey(defaultValue: null)
  String subtitle;

  @JsonKey(defaultValue: null)
  int shopId;

  @JsonKey(defaultValue: kDefaultString)
  String image;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  PromoBanner({
    this.id,
    this.title,
    this.image,
    this.createdAt,
  });

  factory PromoBanner.fromJson(Map<String, dynamic> json) =>
      _$PromoBannerFromJson(json);

  Map<String, dynamic> toJson() => _$PromoBannerToJson(this);
}

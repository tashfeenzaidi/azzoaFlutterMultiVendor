import 'package:azzoa_grocery/data/remote/model/banner.dart';
import 'package:json_annotation/json_annotation.dart';

part 'banner_list.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BannerList {
  @JsonKey(defaultValue: [])
  List<PromoBanner> jsonArray;

  BannerList({
    this.jsonArray,
  });

  factory BannerList.fromJson(Map<String, dynamic> json) =>
      _$BannerListFromJson(json);

  Map<String, dynamic> toJson() => _$BannerListToJson(this);
}

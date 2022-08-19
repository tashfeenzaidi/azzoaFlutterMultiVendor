import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/banner_list.dart';

class BannerListResponse {
  final int status;
  final BannerList data;

  BannerListResponse({
    this.status,
    this.data,
  });

  factory BannerListResponse.fromJson(Map<String, dynamic> json) {
    return BannerListResponse(
      status: json[kKeyStatus],
      data: BannerList.fromJson(json[kKeyData]),
    );
  }
}

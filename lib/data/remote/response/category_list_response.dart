import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/category_list.dart';

class CategoryListResponse {
  final int status;
  final CategoryList data;

  CategoryListResponse({
    this.status,
    this.data,
  });

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    return CategoryListResponse(
      status: json[kKeyStatus],
      data: CategoryList.fromJson(json[kKeyData]),
    );
  }
}

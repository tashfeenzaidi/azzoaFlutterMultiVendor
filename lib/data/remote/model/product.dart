import 'dart:convert';

import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/attribute.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Product {
  static String get tableName => 'product';

  @JsonKey(required: true)
  int id;

  @JsonKey(defaultValue: null)
  int parentId;

  @JsonKey(defaultValue: null)
  int categoryId;

  @JsonKey(defaultValue: null)
  int shopId;

  @JsonKey(required: true)
  String title;

  @JsonKey(defaultValue: kDefaultString)
  String slug;

  @JsonKey(defaultValue: kDefaultString)
  String excerpt;

  @JsonKey(defaultValue: kDefaultString)
  String content;

  @JsonKey(defaultValue: kDefaultString)
  String image;

  @JsonKey(defaultValue: null)
  int views;

  @JsonKey(defaultValue: null)
  double per;

  @JsonKey(defaultValue: kDefaultString)
  String unit;

  @JsonKey(defaultValue: null)
  double salePrice;

  @JsonKey(defaultValue: null)
  double generalPrice;

  @JsonKey(defaultValue: null)
  double tax;

  @JsonKey(defaultValue: kDefaultString)
  String sku;

  @JsonKey(defaultValue: null)
  int stock;

  @JsonKey(defaultValue: null)
  String deliveryTime;

  @JsonKey(defaultValue: null)
  int deliveryTimeType;

  @JsonKey(defaultValue: null)
  int isFreeShipping;

  @JsonKey(defaultValue: kDefaultString)
  String createdAt;

  @JsonKey(defaultValue: null)
  int status;

  @JsonKey(defaultValue: null)
  double priceOff;

  @JsonKey(defaultValue: kDefaultString)
  String type;

  @JsonKey(defaultValue: kDefaultDouble)
  double star;

  @JsonKey(defaultValue: kDefaultDouble)
  double averageRating;

  @JsonKey(defaultValue: [])
  List<Product> variations;

  @JsonKey(defaultValue: [])
  List<Attribute> attrs;

  Product({
    this.id,
    this.parentId,
    this.categoryId,
    this.shopId,
    this.title,
    this.slug,
    this.excerpt,
    this.content,
    this.image,
    this.views,
    this.per,
    this.unit,
    this.salePrice,
    this.generalPrice,
    this.tax,
    this.sku,
    this.stock,
    this.deliveryTime,
    this.deliveryTimeType,
    this.isFreeShipping,
    this.status,
    this.createdAt,
    this.priceOff,
    this.type,
    this.star,
    this.variations,
    this.attrs,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  String toJsonString() => json.encode(toJson());

  factory Product.fromDatabase(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'parent_id': parentId,
      'category_id': categoryId,
      'shop_id': shopId,
      'title': title,
      'slug': slug,
      'excerpt': excerpt,
      'content': content,
      'image': image,
      'views': views,
      'per': per,
      'unit': unit,
      'sale_price': salePrice,
      'general_price': generalPrice,
      'tax': tax,
      'sku': sku,
      'stock': stock,
      'delivery_time': deliveryTime,
      'delivery_time_type': deliveryTimeType,
      'is_free_shipping': isFreeShipping,
      'created_at': createdAt,
      'status': status,
      'price_off': priceOff,
      'type': type,
      'star': star,
    };
  }
}

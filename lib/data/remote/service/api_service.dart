import 'dart:collection';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:azzoa_grocery/base/exception/app_exception.dart';
import 'package:azzoa_grocery/base/exception/email_unverified_exception.dart';
import 'package:azzoa_grocery/base/exception/invalid_input_exception.dart';
import 'package:azzoa_grocery/base/exception/no_connection_exception.dart';
import 'package:azzoa_grocery/base/exception/phone_unverified_exception.dart';
import 'package:azzoa_grocery/base/exception/too_many_requests_exception.dart';
import 'package:azzoa_grocery/base/exception/unauthorised_exception.dart';
import 'package:azzoa_grocery/base/exception/unknown_exception.dart';
import 'package:azzoa_grocery/base/exception/with_error_exception.dart';
import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/local/service/database_service.dart';
import 'package:azzoa_grocery/data/remote/response/address_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/address_response.dart';
import 'package:azzoa_grocery/data/remote/response/attribute_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/banner_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/base_response.dart';
import 'package:azzoa_grocery/data/remote/response/cart_response.dart';
import 'package:azzoa_grocery/data/remote/response/category_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/config_response.dart';
import 'package:azzoa_grocery/data/remote/response/currency_response.dart';
import 'package:azzoa_grocery/data/remote/response/forgot_password_send_otp_response.dart';
import 'package:azzoa_grocery/data/remote/response/help_response.dart';
import 'package:azzoa_grocery/data/remote/response/language_response.dart';
import 'package:azzoa_grocery/data/remote/response/login_response.dart';
import 'package:azzoa_grocery/data/remote/response/notification_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/order_details_response.dart';
import 'package:azzoa_grocery/data/remote/response/order_summary_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/payment_method_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/plain_response.dart';
import 'package:azzoa_grocery/data/remote/response/product_non_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/product_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/profile_response.dart';
import 'package:azzoa_grocery/data/remote/response/registration_response.dart';
import 'package:azzoa_grocery/data/remote/response/reset_password_response.dart';
import 'package:azzoa_grocery/data/remote/response/review_paginated_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/shipping_method_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/shop_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/single_product_response.dart';
import 'package:azzoa_grocery/data/remote/response/single_shop_response.dart';
import 'package:azzoa_grocery/data/remote/response/transaction_list_response.dart';
import 'package:azzoa_grocery/data/remote/response/wish_list_response.dart';
import 'package:azzoa_grocery/localization/app_language.dart';
import 'package:azzoa_grocery/ui/auth/login/login.dart';
import 'package:azzoa_grocery/ui/auth/verify/email/verify_email.dart';
import 'package:azzoa_grocery/ui/auth/verify/phone/verify_phone.dart';
import 'package:azzoa_grocery/util/lib/shared_preference.dart';
import 'package:azzoa_grocery/util/lib/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class NetworkHelper {
  NetworkHelper._internal();

  static final NetworkHelper _instance = NetworkHelper._internal();

  static NetworkHelper on() {
    return _instance;
  }

  static bool isVerifyingEmail = false;
  static bool isVerifyingPhone = false;

  // ignore: missing_return
  Future<LanguageResponse> getLanguageList(
    BuildContext context,
  ) async {
    http.Response response;

    response = await _getRequest(
      context: context,
      url: kApiGetLanguageListUrl,
    );

    if (response.statusCode == 200) {
      return LanguageResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<CurrencyResponse> getCurrencyList(
    BuildContext context,
  ) async {
    http.Response response;

    response = await _getRequest(
      context: context,
      url: kApiGetCurrencyListUrl,
    );

    if (response.statusCode == 200) {
      return CurrencyResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<RegistrationResponse> register(
    BuildContext context,
    String name,
    String userName,
    String email,
    String phone,
    String password,
    String passwordConfirmation,
    String deviceToken,
  ) async {
    http.Response response;

    response = await _postRequest(
      context: context,
      url: kApiRegisterUrl,
      body: {
        '$kName': name,
        '$kUserName': userName,
        '$kEmail': email,
        '$kPhone': phone,
        '$kPassword': password,
        '$kPasswordConfirmation': passwordConfirmation,
        '$kKeyDeviceToken': deviceToken,
      },
    );

    if (response.statusCode == 200) {
      return RegistrationResponse.fromJson(convert.jsonDecode(response.body));
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<LoginResponse> login(
    BuildContext context,
    String email,
    String password,
    String deviceToken,
  ) async {
    http.Response response;

    if (await SharedPrefUtil.contains(kKeyAccessToken)) {
      await SharedPrefUtil.delete(kKeyAccessToken);
    }

    response = await _postRequest(
      context: context,
      url: kApiLoginUrl,
      body: {
        '$kUserName': email,
        '$kPassword': password,
        '$kKeyDeviceToken': deviceToken,
      },
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(convert.jsonDecode(response.body));
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<LoginResponse> loginViaSocialMedia(
    BuildContext context,
    String provider,
    String userId,
    String name,
    String email,
    String deviceToken,
  ) async {
    http.Response response;
    String url = kApiSocialLoginUrl;
    Map<String, String> body = Map();

    if (await SharedPrefUtil.contains(kKeyAccessToken)) {
      await SharedPrefUtil.delete(kKeyAccessToken);
    }

    body = _appendParamIntoBody(body, kProvider, provider);
    body = _appendParamIntoBody(body, kProviderUserId, userId);
    body = _appendParamIntoBody(body, kName, name);
    body = _appendParamIntoBody(body, kEmail, email);
    body = _appendParamIntoBody(body, kKeyDeviceToken, deviceToken);

    response = await _postRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(convert.jsonDecode(response.body));
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ForgotPasswordSendOtpResponse> sendForgotPasswordOtp(
    BuildContext context,
    String email,
  ) async {
    http.Response response;

    response = await _postRequest(
      context: context,
      url: kApiSendForgetPasswordOtpUrl,
      body: {
        kEmail: email,
      },
    );

    if (response.statusCode == 200) {
      return ForgotPasswordSendOtpResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ResetPasswordResponse> resetPassword(
    BuildContext context,
    String email,
    String otp,
    String newPassword,
    String confirmNewPassword,
  ) async {
    http.Response response;

    response = await _putRequest(
      context: context,
      url: kApiResetPasswordUrl,
      body: {
        kEmail: email,
        kOtp: otp,
        kPassword: newPassword,
        kPasswordConfirmation: confirmNewPassword,
      },
    );

    if (response.statusCode == 200) {
      return ResetPasswordResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<BaseResponse> sendVerificationEmail(
    BuildContext context,
  ) async {
    http.Response response;

    response = await _postRequest(
      context: context,
      url: kApiSendVerificationEmailUrl,
    );

    if (response.statusCode == 200) {
      return BaseResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<BaseResponse> verifyEmail(
    BuildContext context,
    String otp,
  ) async {
    http.Response response;

    response = await _postRequest(
      context: context,
      url: kApiVerifyEmailOtpUrl,
      body: {
        kOtp: otp,
      },
    );

    if (response.statusCode == 200) {
      return BaseResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<BaseResponse> sendVerificationSms(
    BuildContext context,
    String appSignature,
  ) async {
    http.Response response;
    Map<String, String> body = Map();

    body = _appendParamIntoBody(
      body,
      kAppSignature,
      appSignature,
    );

    response = await _postRequest(
      context: context,
      url: kApiSendVerificationSmsUrl,
      body: body,
    );

    if (response.statusCode == 200) {
      return BaseResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<BaseResponse> verifyPhone(
    BuildContext context,
    String otp,
  ) async {
    http.Response response;

    response = await _postRequest(
      context: context,
      url: kApiVerifyPhoneOtpUrl,
      body: {
        kOtp: otp,
      },
    );

    if (response.statusCode == 200) {
      return BaseResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<CategoryListResponse> getProductCategories(
    BuildContext context, {
    String keyword,
    String limit,
    String tag,
  }) async {
    http.Response response;
    String url = kApiGetCategoriesUrl;
    String postFix = kDefaultString;

    postFix = _appendParamIntoPostfix(postFix, kKeyword, keyword);
    postFix = _appendParamIntoPostfix(postFix, kLimit, limit);
    postFix = _appendParamIntoPostfix(postFix, kTag, tag);

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return CategoryListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<CategoryListResponse> getShopCategories(
    BuildContext context, {
    String keyword,
    String limit,
    String tag,
  }) async {
    http.Response response;
    String url = kApiGetShopCategoriesUrl;
    String postFix = kDefaultString;

    postFix = _appendParamIntoPostfix(postFix, kKeyword, keyword);
    postFix = _appendParamIntoPostfix(postFix, kLimit, limit);
    postFix = _appendParamIntoPostfix(postFix, kTag, tag);

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return CategoryListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ProductNonPaginatedListResponse> getNonPaginatedProducts(
    BuildContext context, {
    String shopId,
    String categoryId,
    String keyword,
    String attributes,
    String tag,
    String limit,
    String discount,
    String freeShipping,
    String shopOpen,
  }) async {
    http.Response response;
    String url = kApiGetProductsUrl;
    String postFix = kDefaultString;

    postFix = _appendParamIntoPostfix(postFix, kPaginate, 0.toString());
    postFix = _appendParamIntoPostfix(postFix, kOrderBy, "id");
    postFix = _appendParamIntoPostfix(postFix, kOrder, "DESC");

    postFix = _appendParamIntoPostfix(postFix, kShopId, shopId);
    postFix = _appendParamIntoPostfix(postFix, kCategoryId, categoryId);
    postFix = _appendParamIntoPostfix(postFix, kKeyword, keyword);
    postFix = _appendParamIntoPostfix(postFix, kTag, tag);
    postFix = _appendParamIntoPostfix(postFix, kLimit, limit);
    postFix = _appendParamIntoPostfix(postFix, kDiscount, discount);
    postFix = _appendParamIntoPostfix(postFix, kFreeShipping, freeShipping);
    postFix = _appendParamIntoPostfix(postFix, kShopOpen, shopOpen);

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return ProductNonPaginatedListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ProductPaginatedListResponse> getPaginatedProducts(
    BuildContext context,
    int page, {
    String shopId,
    String categoryId,
    String keyword,
    String attributes,
    String tag,
    String limit,
    String discount,
    String freeShipping,
    String orderBy,
    String shopOpen,
  }) async {
    http.Response response;
    String url = kApiGetProductsUrl;
    String postFix = kDefaultString;

    postFix = _appendParamIntoPostfix(postFix, kPaginate, 1.toString());
    postFix = _appendParamIntoPostfix(postFix, kOrderBy, orderBy ?? "id");
    postFix = _appendParamIntoPostfix(postFix, kOrder, "DESC");
    postFix = _appendParamIntoPostfix(postFix, kPage, page.toString());

    postFix = _appendParamIntoPostfix(postFix, kShopId, shopId);
    postFix = _appendParamIntoPostfix(postFix, kCategoryId, categoryId);
    postFix = _appendParamIntoPostfix(postFix, kKeyword, keyword);
    postFix = _appendParamIntoPostfix(postFix, kAttributes, attributes);
    postFix = _appendParamIntoPostfix(postFix, kTag, tag);
    postFix = _appendParamIntoPostfix(postFix, kLimit, limit);
    postFix = _appendParamIntoPostfix(postFix, kDiscount, discount);
    postFix = _appendParamIntoPostfix(postFix, kFreeShipping, freeShipping);
    postFix = _appendParamIntoPostfix(postFix, kShopOpen, shopOpen);

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return ProductPaginatedListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ShopListResponse> getShops(
    BuildContext context, {
    String keyword,
    String limit,
    String tag,
    String categoryId,
  }) async {
    http.Response response;
    String url = kApiGetShopsUrl;
    String postFix = kDefaultString;

    postFix = _appendParamIntoPostfix(postFix, kKeyword, keyword);
    postFix = _appendParamIntoPostfix(postFix, kLimit, limit);
    postFix = _appendParamIntoPostfix(postFix, kTag, tag);
    postFix = _appendParamIntoPostfix(postFix, kCategoryId, categoryId);

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return ShopListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ShopListResponse> getFollowedShops(BuildContext context) async {
    http.Response response;
    String url = kApiGetFollowedShopUrl;

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return ShopListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<SingleShopResponse> getSingleShop(
    BuildContext context,
    String shopId,
  ) async {
    http.Response response;
    String url = kApiGetSingleShopUrl;
    String postFix = kDefaultString;

    postFix = _appendPathIntoPostfix(postFix, shopId);

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return SingleShopResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<SingleProductResponse> getSingleProduct(
    BuildContext context,
    String productId,
  ) async {
    http.Response response;
    String url = kApiGetSingleProductUrl;
    String postFix = kDefaultString;

    postFix = _appendPathIntoPostfix(postFix, productId);

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return SingleProductResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<SingleProductResponse> getProductVariant(
    BuildContext context,
    String productId,
    Map<String, String> attributes,
  ) async {
    http.Response response;
    String url = kApiGetVariantUrl;
    String postParams = kDefaultString;
    String postPath = kDefaultString;

    postPath = _appendPathIntoPostfix(postPath, productId);
    attributes.forEach((key, value) {
      postParams = _appendParamIntoPostfix(postParams, key, value);
    });

    if (postPath.isNotEmpty) {
      url += postPath;
    }

    if (postParams.isNotEmpty) {
      url += postParams;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return SingleProductResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<CartResponse> getCart(
    BuildContext context,
  ) async {
    http.Response response;
    String url = kApiCartUrl;

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return CartResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<CartResponse> addToCart(
    BuildContext context,
    AppThemeAndLanguage themeAndLanguageNotifier,
    String productId, // parent id if available
    String quantity, {
    Map<String, String> attributes,
  }) async {
    http.Response response;
    String url = kApiCartUrl;
    Map<String, String> body = Map();

    body = _appendParamIntoBody(body, kProductId, productId);
    body = _appendParamIntoBody(body, kQuantity, quantity);

    if (attributes != null) {
      attributes.keys.forEach((key) {
        body = _appendParamIntoBody(body, 'attrs[$key]', attributes[key]);
      });
    }

    response = await _postRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      CartResponse cartResponse = CartResponse.fromJson(
        convert.jsonDecode(response.body),
      );

      if (cartResponse != null &&
          cartResponse.status != null &&
          cartResponse.status == 200 &&
          cartResponse.data != null &&
          cartResponse.data.jsonObject != null) {
        themeAndLanguageNotifier.setCartItemCount(
          cartResponse.data.jsonObject.items.length,
        );
      }

      return cartResponse;
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<CartResponse> updateCart(
    BuildContext context,
    String cartId,
    String quantity,
  ) async {
    http.Response response;
    String url = kApiCartUrl;
    String postFix = kDefaultString;
    Map<String, String> body = Map();

    postFix = _appendPathIntoPostfix(postFix, cartId);
    body = _appendParamIntoBody(body, kQuantity, quantity);

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _putRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      return CartResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<CartResponse> removeFromCart(
    BuildContext context,
    String itemId,
  ) async {
    http.Response response;
    String url = kApiCartUrl;
    String postFix = kDefaultString;

    postFix = _appendPathIntoPostfix(postFix, itemId);

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _deleteRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return CartResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<CartResponse> addCouponToCart(
    BuildContext context,
    String couponCode,
  ) async {
    http.Response response;
    String url = kApiAddCouponToCartUrl;
    Map<String, String> body = Map();

    body = _appendParamIntoBody(body, kCode, couponCode);

    response = await _postRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      return CartResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<CartResponse> removeCouponFromCart(
    BuildContext context,
  ) async {
    http.Response response;
    String url = kApiRemoveCouponFromCartUrl;

    response = await _deleteRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return CartResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<WishListResponse> getWishList(
    BuildContext context,
  ) async {
    http.Response response;
    String url = kApiWishListUrl;

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return WishListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<WishListResponse> addToWishList(
    BuildContext context,
    String productId, // parent id if available
    String quantity, {
    Map<String, String> attributes,
  }) async {
    http.Response response;
    String url = kApiWishListUrl;
    Map<String, String> body = Map();

    body = _appendParamIntoBody(body, kProductId, productId);
    body = _appendParamIntoBody(body, kQuantity, quantity);

    if (attributes != null) {
      attributes.keys.forEach((key) {
        body = _appendParamIntoBody(body, 'attrs[$key]', attributes[key]);
      });
    }

    response = await _postRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      return WishListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<WishListResponse> updateWishList(
    BuildContext context,
    String cartId,
    String quantity,
  ) async {
    http.Response response;
    String url = kApiWishListUrl;
    String postFix = kDefaultString;
    Map<String, String> body = Map();

    postFix = _appendPathIntoPostfix(postFix, cartId);
    body = _appendParamIntoBody(body, kQuantity, quantity);

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _putRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      return WishListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<WishListResponse> removeFromWishList(
    BuildContext context,
    String itemId,
  ) async {
    http.Response response;
    String url = kApiWishListUrl;
    String postFix = kDefaultString;

    postFix = _appendPathIntoPostfix(postFix, itemId);

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _deleteRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return WishListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ProfileResponse> getProfile(
    BuildContext context,
  ) async {
    http.Response response;
    String url = kApiProfileUrl;

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<BaseResponse> logOut(BuildContext context) async {
    http.Response response;
    String url = kApiLogOutUrl;

    response = await _postRequest(
      context: context,
      url: url,
      body: {},
    );

    if (response.statusCode == 200) {
      return BaseResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<HelpResponse> getHelp(BuildContext context) async {
    http.Response response;
    String url = kApiGetHelpUrl;

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return HelpResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<BannerListResponse> getBannerList(BuildContext context) async {
    http.Response response;
    String url = kApiBannerUrl;

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return BannerListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ProductPaginatedListResponse> getBannerProducts(
    BuildContext context,
    int page,
    String bannerId, {
    String limit = "20",
  }) async {
    http.Response response;
    String url = kApiBannerUrl;
    String postPath = kDefaultString;
    String postParams = kDefaultString;

    postPath = _appendPathIntoPostfix(postPath, bannerId);
    postParams = _appendParamIntoPostfix(postParams, kPaginate, limit);
    postParams = _appendParamIntoPostfix(postParams, kOrderBy, "id");
    postParams = _appendParamIntoPostfix(postParams, kOrder, "DESC");
    postParams = _appendParamIntoPostfix(postParams, kPage, page.toString());

    if (postPath.isNotEmpty) {
      url += postPath;
    }

    if (postParams.isNotEmpty) {
      url += postParams;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return ProductPaginatedListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ReviewPaginatedListResponse> getReviews(
    BuildContext context,
    int page,
    String reviewableId,
    String reviewableType, {
    String star,
    String limit = "20",
  }) async {
    http.Response response;
    String url = kApiReviewUrl;
    String postParams = kDefaultString;

    postParams =
        _appendParamIntoPostfix(postParams, kReviewableType, reviewableType);
    postParams =
        _appendParamIntoPostfix(postParams, kReviewableId, reviewableId);
    postParams = _appendParamIntoPostfix(postParams, kPaginate, "1");
    postParams = _appendParamIntoPostfix(postParams, kLimit, limit);
    postParams = _appendParamIntoPostfix(postParams, kStar, star);
    postParams = _appendParamIntoPostfix(postParams, kPage, page.toString());

    if (postParams.isNotEmpty) {
      url += postParams;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return ReviewPaginatedListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<PlainResponse> addReview(
    BuildContext context,
    String rating,
    String reviewableId,
    String reviewableType, {
    String content,
  }) async {
    http.Response response;
    String url = kApiReviewUrl;
    Map<String, String> body = Map();

    body = _appendParamIntoBody(body, kRating, rating);
    body = _appendParamIntoBody(body, kReviewableId, reviewableId);
    body = _appendParamIntoBody(body, kReviewableType, reviewableType);
    body = _appendParamIntoBody(body, kContent, content);

    response = await _postRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      return PlainResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<BaseResponse> setNotification(
    BuildContext context,
    bool isEnabled,
  ) async {
    http.Response response;
    String url = kApiNotificationUrl;
    Map<String, String> body = Map();

    body = _appendParamIntoBody(body, kPushNotification, isEnabled ? "1" : "0");

    response = await _putRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      return BaseResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<AddressPaginatedListResponse> getAddresses(
    BuildContext context,
    int page,
  ) async {
    http.Response response;
    String url = kApiAddressUrl;
    String postParams = kDefaultString;
    postParams = _appendParamIntoPostfix(postParams, kPage, page.toString());

    if (postParams.isNotEmpty) {
      url += postParams;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return AddressPaginatedListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<BaseResponse> deleteAddress(
    BuildContext context,
    int addressId,
  ) async {
    http.Response response;
    String url = kApiAddressUrl;
    String postPath = kDefaultString;

    postPath = _appendPathIntoPostfix(postPath, addressId.toString());

    if (postPath.isNotEmpty) {
      url += postPath;
    }

    response = await _deleteRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return BaseResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<AddressResponse> addAddress(
    BuildContext context,
    String type,
    String name,
    String email,
    String phone,
    String country,
    String state,
    String city,
    String streetAddress1,
    String latitude,
    String longitude, {
    String streetAddress2,
  }) async {
    http.Response response;
    String url = kApiAddressUrl;
    Map<String, String> body = Map();

    body = _appendParamIntoBody(body, kType, type);
    body = _appendParamIntoBody(body, kName, name);
    body = _appendParamIntoBody(body, kEmail, email);
    body = _appendParamIntoBody(body, kPhone, phone);
    body = _appendParamIntoBody(body, kCountry, country);
    body = _appendParamIntoBody(body, kState, state);
    body = _appendParamIntoBody(body, kCity, city);
    body = _appendParamIntoBody(body, kStreetAddress1, streetAddress1);
    body = _appendParamIntoBody(body, kStreetAddress2, streetAddress2);
    body = _appendParamIntoBody(body, kLatitude, latitude);
    body = _appendParamIntoBody(body, kLongitude, longitude);

    response = await _postRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      return AddressResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<AddressResponse> updateAddress(
    BuildContext context,
    String type,
    String name,
    String email,
    String phone,
    String country,
    String state,
    String city,
    String streetAddress1,
    String latitude,
    String longitude, {
    String streetAddress2,
    @required int addressId,
  }) async {
    http.Response response;
    String url = kApiAddressUrl;
    String postPath = kDefaultString;
    postPath = _appendPathIntoPostfix(postPath, addressId.toString());

    if (postPath.isNotEmpty) {
      url += postPath;
    }

    Map<String, String> body = Map();

    body = _appendParamIntoBody(body, kType, type);
    body = _appendParamIntoBody(body, kName, name);
    body = _appendParamIntoBody(body, kEmail, email);
    body = _appendParamIntoBody(body, kPhone, phone);
    body = _appendParamIntoBody(body, kCountry, country);
    body = _appendParamIntoBody(body, kState, state);
    body = _appendParamIntoBody(body, kCity, city);
    body = _appendParamIntoBody(body, kStreetAddress1, streetAddress1);
    body = _appendParamIntoBody(body, kStreetAddress2, streetAddress2);
    body = _appendParamIntoBody(body, kLatitude, latitude);
    body = _appendParamIntoBody(body, kLongitude, longitude);

    response = await _putRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      return AddressResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ProfileResponse> updateProfile(
    BuildContext context,
    String userName,
    String name,
    String email,
    String phone, {
    File image,
  }) async {
    http.Response response;
    String url = kApiProfileUrl;

    Map<String, String> body = Map();

    body = _appendParamIntoBody(body, kUserName, userName);
    body = _appendParamIntoBody(body, kName, name);
    body = _appendParamIntoBody(body, kEmail, email);
    body = _appendParamIntoBody(body, kPhone, phone);

    var imageStream;
    var imageLength;

    if (image != null) {
      imageStream = http.ByteStream(image.openRead().cast());
      imageLength = await image.length();
    }

    response = await _multiPartPostRequest(
      context: context,
      url: url,
      body: body,
      fileList: [
        if (image != null && imageStream != null && imageLength != null)
          http.MultipartFile(
            kAvatar,
            imageStream,
            imageLength,
            filename: basename(image.path),
          )
      ],
    );

    if (response.statusCode == 200) {
      return ProfileResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<BaseResponse> changePassword(
    BuildContext context,
    String oldPassword,
    String newPassword,
    String confirmNewPassword,
  ) async {
    http.Response response;
    String url = kApiPasswordUrl;

    Map<String, String> body = Map();

    body = _appendParamIntoBody(body, kOldPassword, oldPassword);
    body = _appendParamIntoBody(body, kPassword, newPassword);
    body =
        _appendParamIntoBody(body, kPasswordConfirmation, confirmNewPassword);

    response = await _postRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      return BaseResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ShippingMethodListResponse> getShippingMethods(
    BuildContext context,
  ) async {
    http.Response response;
    String url = kApiShippingMethodsUrl;

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return ShippingMethodListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<PaymentMethodListResponse> getPaymentMethods(
    BuildContext context,
  ) async {
    http.Response response;
    String url = kApiPaymentMethodsUrl;

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return PaymentMethodListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<BaseResponse> placeOrder(
    BuildContext context,
    int paymentMethodId,
    int shippingMethodId,
    int shippingAddressId,
    int billingAddressId,
  ) async {
    http.Response response;
    String url = kApiOrderUrl;

    Map<String, String> body = Map();

    body = _appendParamIntoBody(
      body,
      kPaymentMethod,
      paymentMethodId.toString(),
    );
    body = _appendParamIntoBody(
      body,
      kShippingMethod,
      shippingMethodId.toString(),
    );
    body = _appendParamIntoBody(
      body,
      kShippingAddress,
      shippingAddressId.toString(),
    );
    body = _appendParamIntoBody(
      body,
      kBillingAddress,
      billingAddressId.toString(),
    );

    response = await _postRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      return BaseResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<OrderSummaryPaginatedListResponse> getOrderHistory(
    BuildContext context,
    int page, {
    String orderId,
  }) async {
    http.Response response;
    String url = kApiOrderUrl;
    String postParams = kDefaultString;
    postParams = _appendParamIntoPostfix(postParams, kPage, page.toString());
    postParams = _appendParamIntoPostfix(postParams, kOrderId, orderId);

    if (postParams.isNotEmpty) {
      url += postParams;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return OrderSummaryPaginatedListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<OrderDetailsResponse> getOrderDetails(
    BuildContext context,
    int orderId,
  ) async {
    http.Response response;
    String url = kApiOrderUrl;
    String postFix = kDefaultString;

    postFix = _appendPathIntoPostfix(postFix, orderId.toString());

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      String currencyCode = await SharedPrefUtil.getString(kKeyCurrency);
      OrderDetailsResponse detailsResponse = OrderDetailsResponse.fromJson(
        convert.jsonDecode(response.body),
      );

      detailsResponse.data.jsonObject.currencyCode = currencyCode;
      return detailsResponse;
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ShopListResponse> getNearbyShops(
    BuildContext context,
    double latitude,
    double longitude, {
    String limit = "20",
  }) async {
    http.Response response;
    String url = kApiNearbyShopsUrl;
    String postFix = kDefaultString;

    postFix = _appendParamIntoPostfix(postFix, kLatitude, latitude.toString());
    postFix =
        _appendParamIntoPostfix(postFix, kLongitude, longitude.toString());
    postFix = _appendParamIntoPostfix(postFix, kLimit, limit);

    if (postFix.isNotEmpty) {
      url += postFix;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return ShopListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<ConfigResponse> getAppConfig(BuildContext context) async {
    http.Response response;
    String url = kApiGetConfigUrl;

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return ConfigResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<NotificationListResponse> getNotificationList(
    BuildContext context,
  ) async {
    http.Response response;
    String url = kApiGetNotificationUrl;

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return NotificationListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<PlainResponse> followShop(
    BuildContext context,
    String shopId,
  ) async {
    http.Response response;
    String url = kApiFollowShopUrl;
    String postPath = kDefaultString;

    postPath = _appendPathIntoPostfix(postPath, shopId);

    if (postPath.isNotEmpty) {
      url += postPath;
    }

    response = await _postRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return PlainResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<PlainResponse> unfollowShop(
    BuildContext context,
    String shopId,
  ) async {
    http.Response response;
    String url = kApiUnfollowShopUrl;
    String postPath = kDefaultString;

    postPath = _appendPathIntoPostfix(postPath, shopId);

    if (postPath.isNotEmpty) {
      url += postPath;
    }

    response = await _postRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return PlainResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<AttributeListResponse> getAttributeList(
    BuildContext context,
  ) async {
    http.Response response;
    String url = kApiGetAttributeUrl;

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return AttributeListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  Future<TransactionListResponse> getTransactionList(
      BuildContext context,
      ) async {
    http.Response response;
    String url = kApiGetTransactionList;
    String postPath = kDefaultString;
    String postParams = kDefaultString;

    postParams = _appendParamIntoPostfix(postParams, kPaginate, "15");
    postParams = _appendParamIntoPostfix(postParams, kOrderBy, "id");
    postParams = _appendParamIntoPostfix(postParams, kOrder, "DESC");
    postParams = _appendParamIntoPostfix(postParams, kPage, "1");

    if (postPath.isNotEmpty) {
      url += postPath;
    }

    if (postParams.isNotEmpty) {
      url += postParams;
    }

    response = await _getRequest(
      context: context,
      url: url,
    );

    if (response.statusCode == 200) {
      return TransactionListResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  // ignore: missing_return
  Future<BaseResponse> updateDeviceToken(
    BuildContext context,
    String deviceToken,
  ) async {
    http.Response response;
    String url = kApiTokenUrl;

    Map<String, String> body = Map();
    body = _appendParamIntoBody(body, kToken, deviceToken);

    response = await _putRequest(
      context: context,
      url: url,
      body: body,
    );

    if (response.statusCode == 200) {
      return BaseResponse.fromJson(
        convert.jsonDecode(response.body),
      );
    } else {
      await _handleOtherCases(response, context);
    }
  }

  String _appendPathIntoPostfix(String postFix, String value) {
    if (value != null) {
      postFix += ("/" + value);
    }

    return postFix;
  }

  String _appendParamIntoPostfix(String postFix, String key, String value) {
    if (value != null) {
      if (postFix.isEmpty) {
        postFix += "?";
      } else {
        postFix += "&";
      }

      postFix += (key + "=" + value.toString());
    }

    return postFix;
  }

  Map<String, String> _appendParamIntoBody(
    Map<String, String> body,
    String key,
    String value,
  ) {
    if (value != null) {
      body[key] = value;
    }

    return body;
  }

  Future<void> _handleOtherCases(
    http.Response response,
    BuildContext context,
  ) async {
    try {
      await _handleOtherStatusCodes(response);
      debugPrint(response.body);
    } on EmailUnverifiedException catch (e) {
      _showException(e);

      if (!isVerifyingEmail) {
        isVerifyingEmail = true;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyEmailPage(),
          ),
          (route) => false,
        );
      }
    } on PhoneUnverifiedException catch (e) {
      _showException(e);

      if (!isVerifyingPhone) {
        isVerifyingPhone = true;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyPhonePage(),
          ),
          (route) => false,
        );
      }
    } on UnauthorisedException catch (e) {
      _showException(e);

      String currencyCode = await SharedPrefUtil.getString(kKeyCurrency);
      String language = await SharedPrefUtil.getString(kKeyLanguage);

      await SharedPrefUtil.clear().then((value) async {
        await DatabaseService.on().clearDatabase();

        await SharedPrefUtil.writeString(
          kKeyCurrency,
          currencyCode,
        );

        await SharedPrefUtil.writeString(
          kKeyLanguage,
          language,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false,
        );
      });
    } on WithErrorException catch (e) {
      _showException(e);
    } on InvalidInputException catch (e) {
      _showException(e);
    } on UnknownException catch (e) {
      _showException(e);
    }
  }

  void _showException(AppException e) {
    if (e != null && e.toString().trim().isNotEmpty) {
      ToastUtil.show(e.toString());
    }
  }

  Future<void> _handleOtherStatusCodes(http.Response response) async {
    String errorMessage = kDefaultString;
    List<String> errorMessages = [];

    Map<String, dynamic> bodyObject = convert.jsonDecode(response.body);

    if (bodyObject.containsKey(kKeyData)) {
      Map<String, dynamic> dataObject = bodyObject[kKeyData];

      if (dataObject.containsKey(kKeyJsonObject)) {
        Map<String, dynamic> errorJsonObject = dataObject[kKeyJsonObject];

        errorJsonObject.forEach((key, value) {
          errorMessages.add(value);
        });
      }

      if (dataObject.containsKey(kKeyStringData)) {
        errorMessage = dataObject[kKeyStringData] as String;
      }
    }

    if (bodyObject.containsKey(kKeyMessage)) {
      errorMessage = bodyObject[kKeyMessage] as String;
    }

    if (errorMessages.isNotEmpty) {
      errorMessage = errorMessages.join(kNewLineString);
    }

    switch (response.statusCode) {
      case 400:
        throw PhoneUnverifiedException(errorMessage);
      case 401:
        throw UnauthorisedException(errorMessage);
      case 403:
        throw EmailUnverifiedException(errorMessage);
      case 417:
        throw WithErrorException(errorMessage);
      case 422:
        throw InvalidInputException(errorMessage);
      case 429:
        throw TooManyRequestsException(errorMessage);
      case 500:
      default:
        throw UnknownException(errorMessage);
    }
  }

  Future<Map<String, String>> _getHeaders(BuildContext context) async {
    HashMap<String, String> headers = HashMap();

    headers[HttpHeaders.acceptHeader] = kResponseOfJsonType;
    headers[kKeyHeaderLanguage] =
        Localizations.localeOf(context).languageCode.toLowerCase();

    if (await SharedPrefUtil.contains(kKeyCurrency)) {
      headers[kKeyHeaderCurrency] =
          await SharedPrefUtil.getString(kKeyCurrency);
    }

    if (await SharedPrefUtil.contains(kKeyAccessToken)) {
      headers[HttpHeaders.authorizationHeader] =
          await SharedPrefUtil.getString(kKeyAccessToken);
      debugPrint("token" + await SharedPrefUtil.getString(kKeyAccessToken));
    }

    return headers;
  }

  Future<http.Response> _getRequest({
    BuildContext context,
    String url,
  }) async {
    http.Response response;

    try {
      response = await http.get(
        url,
        headers: await _getHeaders(context),
      );
      debugPrint(url + response.body);
    } on SocketException {
      ToastUtil.show("Please check your internet connection");
      throw NoConnectionException();
    } catch (e) {
      throw e;
    }

    return response;
  }

  Future<http.Response> _postRequest({
    @required BuildContext context,
    @required String url,
    Map<String, String> body,
  }) async {
    http.Response response;

    try {
      response = await http.post(
        url,
        body: body,
        headers: await _getHeaders(context),
      );
      debugPrint(url + response.body);
    } on SocketException {
      ToastUtil.show("Please check your internet connection");
      throw NoConnectionException();
    } catch (e) {
      throw e;
    }

    return response;
  }

  Future<http.Response> _putRequest({
    BuildContext context,
    String url,
    Map<String, String> body,
  }) async {
    http.Response response;

    try {
      response = await http.put(
        url,
        body: body,
        headers: await _getHeaders(context),
      );
      debugPrint(url + response.body);
    } on SocketException {
      ToastUtil.show("Please check your internet connection");
      throw NoConnectionException();
    } catch (e) {
      throw e;
    }

    return response;
  }

  Future<http.Response> _deleteRequest({
    BuildContext context,
    String url,
  }) async {
    http.Response response;

    try {
      response = await http.delete(
        url,
        headers: await _getHeaders(context),
      );
      debugPrint(url + response.body);
    } on SocketException {
      ToastUtil.show("Please check your internet connection");
      throw NoConnectionException();
    } catch (e) {
      throw e;
    }

    return response;
  }

  Future<http.Response> _multiPartPostRequest({
    @required BuildContext context,
    @required String url,
    Map<String, String> body,
    List<http.MultipartFile> fileList,
  }) async {
    http.Response response;
    http.MultipartRequest request;

    try {
      request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers.addAll(await _getHeaders(context))
        ..fields.addAll(body)
        ..files.addAll(fileList);

      response = await http.Response.fromStream(await request.send());
      debugPrint(url + response.body);
    } on SocketException {
      ToastUtil.show("Please check your internet connection");
      throw NoConnectionException();
    } catch (e) {
      throw e;
    }

    return response;
  }
}

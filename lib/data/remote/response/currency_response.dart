import 'package:azzoa_grocery/constants.dart';
import 'package:azzoa_grocery/data/remote/model/currency.dart';

class CurrencyResponse {
  final int status;
  final List<Currency> data;

  CurrencyResponse({
    this.status,
    this.data,
  });

  factory CurrencyResponse.fromJson(Map<String, dynamic> json) {
    List<Currency> currencyList = [];

    if (json.containsKey(kKeyData)) {
      Map<String, dynamic> dataMap = json[kKeyData];

      if (dataMap.containsKey(kKeyJsonArray)) {
        for (var currency in dataMap[kKeyJsonArray]) {
          currencyList.add(
            Currency(
              currency[kKeyName],
              currency[kKeyCode],
            ),
          );
        }
      }
    }

    return CurrencyResponse(
      status: json[kKeyStatus],
      data: currencyList,
    );
  }
}

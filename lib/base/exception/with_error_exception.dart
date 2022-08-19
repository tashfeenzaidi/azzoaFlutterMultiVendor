import 'package:azzoa_grocery/base/exception/app_exception.dart';

class WithErrorException extends AppException {
  WithErrorException([message]) : super(message, "With Error: ");
}

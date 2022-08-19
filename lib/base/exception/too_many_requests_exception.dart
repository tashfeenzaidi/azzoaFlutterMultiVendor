import 'package:azzoa_grocery/base/exception/app_exception.dart';

class TooManyRequestsException extends AppException {
  TooManyRequestsException([String message]) : super(message, "Error: ");
}

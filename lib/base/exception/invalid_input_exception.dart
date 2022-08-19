import 'package:azzoa_grocery/base/exception/app_exception.dart';

class InvalidInputException extends AppException {
  InvalidInputException([String message]) : super(message, "Invalid Input: ");
}

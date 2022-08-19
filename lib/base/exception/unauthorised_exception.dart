import 'package:azzoa_grocery/base/exception/app_exception.dart';

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

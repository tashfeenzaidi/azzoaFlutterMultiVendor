class Language {
  String _name;
  String _code;

  Language(
    this._name,
    this._code,
  );

  String get code => _code;

  set code(String value) {
    _code = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }
}

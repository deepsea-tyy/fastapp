class Language {
  final String code;
  final String locale;
  final String language;
  final Map<String, String>? dictionary;

  const Language({
    required this.code,
    required this.locale,
    required this.language,
    this.dictionary,
  });
}

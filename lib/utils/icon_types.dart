/// Tipi di icona supportati dall'app
enum IconType {
  emoji('emoji'),
  asset('asset'),
  custom('custom');

  const IconType(this.value);
  final String value;

  static IconType fromString(String value) {
    return IconType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => IconType.asset, // Default fallback
    );
  }

  @override
  String toString() => value;
}
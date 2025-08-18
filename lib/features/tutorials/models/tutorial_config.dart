import 'tutorial_page.dart';

class TutorialConfig {
  final String sectionKey;
  final List<TutorialPage> pages;
  final bool isEnabled;
  final String title;
  final String? subtitle;

  const TutorialConfig({
    required this.sectionKey,
    required this.pages,
    required this.title,
    this.subtitle,
    this.isEnabled = true,
  });

  bool get hasMultiplePages => pages.length > 1;
  bool get isEmpty => pages.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorialConfig &&
          runtimeType == other.runtimeType &&
          sectionKey == other.sectionKey &&
          title == other.title &&
          subtitle == other.subtitle &&
          isEnabled == other.isEnabled;

  @override
  int get hashCode =>
      sectionKey.hashCode ^
      title.hashCode ^
      subtitle.hashCode ^
      isEnabled.hashCode;

  @override
  String toString() {
    return 'TutorialConfig{sectionKey: $sectionKey, title: $title, pages: ${pages.length}, isEnabled: $isEnabled}';
  }
}
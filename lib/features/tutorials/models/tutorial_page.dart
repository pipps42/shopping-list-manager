enum MediaType { image, gif, video }

class TutorialPage {
  final String title;
  final String description;
  final String? mediaAsset;
  final MediaType? mediaType;

  const TutorialPage({
    required this.title,
    required this.description,
    this.mediaAsset,
    this.mediaType,
  });

  bool get hasMedia => mediaAsset != null && mediaType != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TutorialPage &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          description == other.description &&
          mediaAsset == other.mediaAsset &&
          mediaType == other.mediaType;

  @override
  int get hashCode =>
      title.hashCode ^
      description.hashCode ^
      mediaAsset.hashCode ^
      mediaType.hashCode;

  @override
  String toString() {
    return 'TutorialPage{title: $title, description: $description, mediaAsset: $mediaAsset, mediaType: $mediaType}';
  }
}
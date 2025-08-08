import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'base_dialog.dart';

/// Dialog per la selezione di emoji
class EmojiPickerDialog extends StatelessWidget {
  final Function(String) onEmojiSelected;

  const EmojiPickerDialog({super.key, required this.onEmojiSelected});

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: 'Seleziona Emoji',
      titleIcon: Icons.emoji_emotions,
      hasColoredHeader: true,
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.8,
      content: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          onEmojiSelected(emoji.emoji);
          Navigator.of(context).pop();
        },
        config: Config(
          height: MediaQuery.of(context).size.height * 0.65,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax: 36.0,
            columns: 5,
            verticalSpacing: 2,
            horizontalSpacing: 2,
            gridPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
          ),
          skinToneConfig: const SkinToneConfig(),
          categoryViewConfig: const CategoryViewConfig(
            initCategory: Category.RECENT,
            backgroundColor: Colors.transparent,
          ),
          bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
          searchViewConfig: const SearchViewConfig(
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      actions: [], // Solo chiusura tramite selezione o back
    );
  }

  /// Factory method per mostrare il dialog
  static Future<String?> show(
    BuildContext context, {
    required Function(String) onEmojiSelected,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => EmojiPickerDialog(onEmojiSelected: onEmojiSelected),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:dance_club_comuna_8/presentation/widgets/image_selection.dart';

class MarkdownToolbar extends StatelessWidget {
  final TextEditingController contentController;

  const MarkdownToolbar({super.key, required this.contentController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildToolbarButton(
                'H1', () => _insertMarkdown('# ', '\n'), Icons.looks_one),
            _buildToolbarButton(
                'H2', () => _insertMarkdown('## ', '\n'), Icons.looks_two),
            _buildToolbarButton(
                'H3', () => _insertMarkdown('### ', '\n'), Icons.looks_3),
            _buildToolbarButton(
                'Bold', () => _insertMarkdown('**', '**'), Icons.format_bold),
            _buildToolbarButton(
                'Italic', () => _insertMarkdown('*', '*'), Icons.format_italic),
            _buildToolbarButton('Strike', () => _insertMarkdown('~~', '~~'),
                Icons.format_strikethrough),
            _buildToolbarButton(
                'Link', () => _insertMarkdown('[text](url)'), Icons.link),
            _buildToolbarButton(
                'Bullet List', () => _insertMarkdown('\n- ', '\n'), Icons.list),
            _buildToolbarButton(
                'Numbered List',
                () => _insertMarkdown('\n1. ', '\n'),
                Icons.format_list_numbered),
            _buildToolbarButton(
                'Quote', () => _insertMarkdown('> ', '\n'), Icons.format_quote),
            _buildToolbarButton(
                'Code', () => _insertMarkdown('`', '`'), Icons.code),
            _buildToolbarButton(
                'Image', () => _showImageSelectionDialog(context), Icons.image),
            _buildToolbarButton('Page Break', () => _insertMarkdown('\n\n'),
                Icons.arrow_downward),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(
      String label, VoidCallback onPressed, IconData icon) {
    return ActionChip(
      onPressed: onPressed,
      avatar: Icon(icon),
      label: Text(label),
    );
  }

  void _insertMarkdown(String markdownPrefix, [String markdownSuffix = '']) {
    final text = contentController.text;
    final selection = contentController.selection;

    if (selection.isValid && selection.start != selection.end) {
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.replaceRange(selection.start, selection.end,
          '$markdownPrefix$selectedText$markdownSuffix');

      contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: selection.start +
                markdownPrefix.length +
                selectedText.length +
                markdownSuffix.length),
      );
    } else {
      final newText = text.replaceRange(
          selection.start, selection.end, '$markdownPrefix$markdownSuffix');

      contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: selection.start + markdownPrefix.length),
      );
    }
  }

  Future<void> _showImageSelectionDialog(BuildContext context) async {
    final imageUrl = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const ImageSelectionDialog();
      },
    );
    if (imageUrl != null) {
      _insertMarkdown('![Put image description here]($imageUrl)');
    }
  }
}

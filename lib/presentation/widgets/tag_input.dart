import 'package:flutter/material.dart';

class TagInputWidget extends StatefulWidget {
  final ValueChanged<List<String>> onTagsChanged;
  final List<String> initialTags; // Etiquetas iniciales

  const TagInputWidget({
    super.key,
    required this.onTagsChanged,
    this.initialTags = const [], // Por defecto es una lista vacía
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = widget.initialTags; // Inicializar con etiquetas existentes
  }

  void _addTag(String tag) {
    setState(() {
      _tags.add(tag);
      widget.onTagsChanged(_tags);
    });
  }

  void _onSubmitted(String text) {
    if (text.trim().isNotEmpty) {
      _addTag(text.trim());
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _tags
              .map((tag) => Chip(
                    label: Text(tag),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                        widget.onTagsChanged(_tags);
                      });
                    },
                  ))
              .toList(),
        ),
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: 'Ingresa una etiqueta y presiona espacio',
          ),
          onChanged: (text) {
            if (text.endsWith(' ')) {
              _onSubmitted(text.trim());
            }
          },
          onSubmitted: _onSubmitted,
        ),
      ],
    );
  }
}

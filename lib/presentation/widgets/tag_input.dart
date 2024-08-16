import 'package:flutter/material.dart';

class TagInputWidget extends StatefulWidget {
  final ValueChanged<List<String>> onTagsChanged;
  final List<String> initialTags; // Etiquetas iniciales
  final String hintText;

  const TagInputWidget({
    super.key,
    required this.onTagsChanged,
    this.initialTags = const [],
    required this.hintText, // Por defecto es una lista vacía
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _tags;
  RegExp expYoutube = RegExp(
    r"^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/(watch\?v=|embed\/|v\/|.+\?v=)?([-\w]{11})(\S+)?$",
    caseSensitive: false,
    multiLine: false,
  );
  Color chipBackgroundColor = Colors.transparent;
  Color chipErrorBackgroundColor = Colors.red[100]!;

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
          children: _tags.map((tag) => buildChip(tag)).toList(),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  // the hint text from the constructor
                  hintText: widget.hintText,
                ),
                onChanged: (text) {
                  if (text.endsWith(' ')) {
                    _onSubmitted(text.trim());
                  }
                },
                onSubmitted: _onSubmitted,
              ),
            ),
            //hint button with a ? showing a tooltip saying that the tags should be separated by spaces and
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Ayuda'),
                      content: const Text(
                        'Las etiquetas deben ser separadas por espacios.\n\n'
                        'Las URLs deben ser de YouTube. Si no cumplen con este formato, '
                        'al agregarlas separadas por espacios, se mostrarán en rojo y '
                        'el video no se proyectará.\n\n'
                        'Además, las URLs tienen un botón para eliminar. '
                        'Recuerda que los videos deben estar en público para que puedan ser visualizados correctamente.',
                        style: TextStyle(fontSize: 16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cerrar'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Chip buildChip(String tag) {
    return Chip(
      label: Text(tag),
      backgroundColor: expYoutube.hasMatch(tag)
          ? chipBackgroundColor
          : chipErrorBackgroundColor,
      onDeleted: () {
        setState(() {
          _tags.remove(tag);
          widget.onTagsChanged(_tags);
        });
      },
    );
  }
}

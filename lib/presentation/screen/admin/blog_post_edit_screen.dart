import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_events.dart';
import 'package:dance_club_comuna_8/logic/models/blog_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class BlogPostEditScreen extends StatefulWidget {
  final BlogPost? post;

  const BlogPostEditScreen({super.key, this.post});

  @override
  State<BlogPostEditScreen> createState() => _BlogPostEditScreenState();
}

class _BlogPostEditScreenState extends State<BlogPostEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _imageUrlController;
  late TextEditingController _contentController;
  late DateTime _selectedDate;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _contentController =
        TextEditingController(text: widget.post?.content ?? '');
    _imageUrlController =
        TextEditingController(text: widget.post?.imageUrl ?? '');
    _selectedDate = widget.post?.date ?? DateTime.now();
    _contentController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _togglePreviewMode() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
  }

  void _insertMarkdown(String markdown) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final newText = text.replaceRange(selection.start, selection.end, markdown);
    _contentController.value = TextEditingValue(
      text: newText,
      selection:
          TextSelection.collapsed(offset: selection.start + markdown.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'Nuevo Post' : 'Editar Post'),
        actions: [
          IconButton(
            icon: Icon(_isPreviewMode ? Icons.edit : Icons.preview),
            onPressed: _togglePreviewMode,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: _isPreviewMode ? _buildPreview() : _buildEditor(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _savePost,
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToolbarButton('H1', () => _insertMarkdown('# ')),
            _buildToolbarButton('H2', () => _insertMarkdown('## ')),
            _buildToolbarButton('H3', () => _insertMarkdown('### ')),
            _buildToolbarButton('B', () => _insertMarkdown('**bold**')),
            _buildToolbarButton('I', () => _insertMarkdown('*italic*')),
            _buildToolbarButton(
                '~', () => _insertMarkdown('~~strikethrough~~')),
            _buildToolbarButton('Link', () => _insertMarkdown('[text](url)')),
            _buildToolbarButton('List', () => _insertMarkdown('- item\n')),
            _buildToolbarButton('Num', () => _insertMarkdown('1. item\n')),
            _buildToolbarButton('Quote', () => _insertMarkdown('> quote\n')),
            _buildToolbarButton('Code', () => _insertMarkdown('`code`')),
            _buildToolbarButton('Img', () => _showImageDialog()),
            _buildToolbarButton(
                'Salto de página', () => _insertMarkdown('\n\n')),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          minimumSize: const Size(40, 36),
        ),
        child: Text(label),
      ),
    );
  }

  void _showImageDialog() {
    // Aquí se implementaría la lógica para añadir imágenes
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Añadir imagen'),
          content: const Text(
              'La funcionalidad para añadir imágenes aún no está implementada.'),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _imageUrlController,
            decoration: const InputDecoration(
              labelText: 'URL de la imagen banner',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: 'Contenido',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: const Text('Cambiar fecha'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titleController.text,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 16),
          MarkdownBody(
            data: _contentController.text,
            selectable: true,
            styleSheet:
                MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: const TextStyle(fontSize: 16.0),
              h1: Theme.of(context).textTheme.headlineMedium,
              h2: Theme.of(context).textTheme.headlineSmall,
              h3: Theme.of(context).textTheme.titleLarge,
              h4: Theme.of(context).textTheme.titleMedium,
              h5: Theme.of(context).textTheme.titleSmall,
              h6: Theme.of(context).textTheme.labelLarge,
            ),
            onTapLink: (text, href, title) {
              if (href != null) {
                launchUrl(Uri.parse(href));
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _checkImageBytesUrl(String imageUrl) async {
    final regex = RegExp(r'^https?:\/\/.*\.(png|jpg|jpeg|gif)$');
    if (!regex.hasMatch(imageUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La URL de la imagen no es válida')),
      );
      return false;
    }

    // get the bytes of the image
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se pudo obtener la imagen, verifique la url')),
        );
        return false;
      }
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se pudo obtener la imagen, verifique la url')),
      );
      return false;
    }
  }

  Future<void> _savePost() async {
    final title = _titleController.text;
    final content = _contentController.text;
    final imageUrl = _imageUrlController.text;
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    if (imageUrl.isNotEmpty) {
      final checkImage = await _checkImageBytesUrl(imageUrl);
      if (!checkImage) {
        return;
      }
    }

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    if (widget.post == null) {
      // Añadir nuevo post
      context.read<PresentationsBloc>().add(AddPresentationEvent(
            title: title,
            content: content,
            date: _selectedDate,
            imageUrl: imageUrl,
          ));
    } else {
      // Actualizar post existente
      context.read<PresentationsBloc>().add(UpdatePresentationEvent(
            id: widget.post!.id,
            title: title,
            content: content,
            date: _selectedDate,
            imageUrl: imageUrl,
          ));
    }

    Navigator.of(context).pop();
  }
}

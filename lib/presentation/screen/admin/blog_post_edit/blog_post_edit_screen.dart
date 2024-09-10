import 'package:dance_club_comuna_8/presentation/screen/admin/blog_post_edit/blog_post_editor.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/blog_post_edit/blog_post_preview.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/blog_post_edit/image_validator.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/blog_post_edit/markdown_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_events.dart';
import 'package:dance_club_comuna_8/logic/models/blog_post.dart';

class BlogPostEditScreen extends StatefulWidget {
  final BlogPost? post;

  const BlogPostEditScreen({super.key, this.post});

  @override
  State<BlogPostEditScreen> createState() => _BlogPostEditScreenState();
}

class _BlogPostEditScreenState extends State<BlogPostEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _contentController;
  late DateTime _selectedDate;
  bool _isPreviewMode = false;
  List<String> videoUrls = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post?.title ?? '');
    _contentController =
        TextEditingController(text: widget.post?.content ?? '');
    _imageUrlController =
        TextEditingController(text: widget.post?.imageUrl ?? '');
    _selectedDate = widget.post?.date ?? DateTime.now();
    _contentController.addListener(() => setState(() {}));
    videoUrls = widget.post?.videoUrls ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _togglePreviewMode() => setState(() => _isPreviewMode = !_isPreviewMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'New Post' : 'Edit Post'),
        actions: [
          IconButton(
            icon: Icon(_isPreviewMode ? Icons.edit : Icons.preview),
            onPressed: _togglePreviewMode,
          ),
        ],
      ),
      body: Column(
        children: [
          MarkdownToolbar(contentController: _contentController),
          Expanded(
            child: _isPreviewMode
                ? BlogPostPreview(
                    title: _titleController.text,
                    content: _contentController.text,
                    date: _selectedDate,
                    videoUrls: videoUrls,
                  )
                : BlogPostEditor(
                    titleController: _titleController,
                    imageUrlController: _imageUrlController,
                    contentController: _contentController,
                    selectedDate: _selectedDate,
                    onVideoUrlsChanged: (tags) =>
                        setState(() => videoUrls = tags),
                    onDateChanged: (date) =>
                        setState(() => _selectedDate = date),
                    videoUrlsInitial: videoUrls,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _savePost,
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> _savePost() async {
    final title = _titleController.text;
    final content = _contentController.text;
    final imageUrl = _imageUrlController.text;

    if (!_validateInputs(title, content)) return;
    if (!await _validateImageUrl(imageUrl)) return;

    if (mounted) {
      final bloc = context.read<PresentationsBloc>();
      if (widget.post == null) {
        bloc.add(AddPresentationEvent(
            title: title,
            content: content,
            date: _selectedDate,
            imageUrl: imageUrl,
            videoUrls: videoUrls));
      } else {
        bloc.add(UpdatePresentationEvent(
            id: widget.post!.id,
            title: title,
            content: content,
            date: _selectedDate,
            imageUrl: imageUrl,
            videoUrls: videoUrls));
      }
      _showSnackBar("Post guardado con éxito");
      Navigator.of(context).pop();
    }
  }

  bool _validateInputs(String title, String content) {
    if (title.isEmpty || content.isEmpty) {
      _showSnackBar('Por favor complete todos los campos');
      return false;
    }
    return true;
  }

  Future<bool> _validateImageUrl(String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      final isValid = await ImageValidator.isValidImageUrl(imageUrl);
      if (!isValid && mounted) {
        _showSnackBar('URL de imagen no válida, intentelo de nuevo');
        return false;
      }
    }
    return true;
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

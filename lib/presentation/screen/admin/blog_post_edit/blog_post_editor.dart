import 'package:dance_club_comuna_8/presentation/widgets/image_selection.dart';
import 'package:dance_club_comuna_8/presentation/widgets/tag_input.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlogPostEditor extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController imageUrlController;
  final TextEditingController contentController;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<List<String>> onVideoUrlsChanged;
  final List<String> videoUrlsInitial;

  const BlogPostEditor({
    super.key,
    required this.titleController,
    required this.imageUrlController,
    required this.contentController,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onVideoUrlsChanged,
    required this.videoUrlsInitial,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = screenHeight - keyboardHeight;
    int maxLines = (availableHeight / 40).floor();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(titleController, 'Título'),
          const SizedBox(height: 16),
          _buildImageUrlField(context),
          const SizedBox(height: 16),
          _buildTextField(contentController, 'Contenido', maxLines: maxLines),
          const SizedBox(height: 16),
          TagInputWidget(
            onTagsChanged: onVideoUrlsChanged,
            initialTags: videoUrlsInitial,
            hintText: 'URLs de videos de youtube (opcional)',
          ),
          const SizedBox(height: 16),
          _buildDatePicker(context),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int? maxLines}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: maxLines ?? 1,
      keyboardType: maxLines == null ? TextInputType.multiline : null,
    );
  }

  Widget _buildImageUrlField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            controller: imageUrlController,
            decoration: const InputDecoration(
              labelText: 'URL de la imagen banner (opcional)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.image_search),
          onPressed: () => _showImageSelectionDialog(context),
          tooltip: 'Seleccionar imagen',
        ),
      ],
    );
  }

  Future<void> _showImageSelectionDialog(BuildContext context) async {
    final imageUrl = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return const ImageSelectionDialog();
      },
    );
    if (imageUrl != null) {
      imageUrlController.text = imageUrl;
    }
  }

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      children: [
        Text('Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}'),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => _selectDate(context),
          child: const Text('Cambiar fecha'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }
}

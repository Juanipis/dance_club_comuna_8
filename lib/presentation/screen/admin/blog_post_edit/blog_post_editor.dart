import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlogPostEditor extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController imageUrlController;
  final TextEditingController contentController;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const BlogPostEditor({
    super.key,
    required this.titleController,
    required this.imageUrlController,
    required this.contentController,
    required this.selectedDate,
    required this.onDateChanged,
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
          _buildTextField(
              imageUrlController, 'URL de la imagen banner (opcional)'),
          const SizedBox(height: 16),
          _buildTextField(contentController, 'Contenido', maxLines: maxLines),
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

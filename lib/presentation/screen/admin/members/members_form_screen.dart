import 'package:dance_club_comuna_8/presentation/widgets/image_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/member/member_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/member/member_events.dart';
import 'package:dance_club_comuna_8/logic/models/member.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class MemberFormScreen extends StatefulWidget {
  final Member? member;

  const MemberFormScreen({super.key, this.member});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _roleController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _aboutController;
  late DateTime _birthDate;

  // Define the listener as a separate method
  void _imageUrlListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _roleController = TextEditingController(text: widget.member?.role ?? '');
    _imageUrlController =
        TextEditingController(text: widget.member?.imageUrl ?? '');
    _aboutController = TextEditingController(text: widget.member?.about ?? '');
    _birthDate = widget.member?.birthDate ?? DateTime.now();

    // Add listener to update UI when image URL changes
    _imageUrlController.addListener(_imageUrlListener);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _imageUrlController
        .removeListener(_imageUrlListener); // Correctly remove the listener
    _imageUrlController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('es', null);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.member == null ? 'Añadir Miembro' : 'Editar Miembro',
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13.0),
          child: Form(
            key: _formKey,
            child: Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 16.0,
              children: [
                // Imagen Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageUrlController.text.isNotEmpty
                      ? NetworkImage(_imageUrlController.text)
                      : null, // No image, so backgroundImage is null
                  child: _imageUrlController.text.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white, // Adjust color as needed
                        )
                      : null, // Image is present, so no child widget
                ),

                const SizedBox(width: 24), // Espacio entre avatar e inputs
                // Formulario de datos
                ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: 400), // Ancho máximo para pantallas grandes
                  child: Column(
                    children: [
                      buildCustomTextField(
                        controller: _nameController,
                        label: 'Nombre',
                        leadingIcon: Icons.person,
                        maxLength: 50,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          if (value.length < 3) {
                            return 'El nombre debe tener al menos 3 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      buildCustomTextField(
                        controller: _roleController,
                        label: 'Rol',
                        leadingIcon: Icons.work,
                        maxLength: 30,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El rol es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildImagePicker(context, theme),
                      const SizedBox(height: 16),
                      buildCustomTextField(
                        controller: _aboutController,
                        label: 'Acerca de',
                        leadingIcon: Icons.info,
                        maxLength: 200,
                        maxLines: 3,
                        helperText: 'Una breve descripción',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La descripción es obligatoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildDatePicker(context, theme),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submitForm,
                        child: Text(
                          widget.member == null ? 'Añadir' : 'Actualizar',
                          style: textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: TextFormField(
            enabled: false,
            controller: _imageUrlController,
            decoration: InputDecoration(
              labelText: 'URL del avatar de perfil',
              prefixIcon: Icon(Icons.image, color: theme.colorScheme.primary),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ),
        ),
        const SizedBox(width: 16),
        imageSelectionButton(context, _imageUrlController),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cake),
        const SizedBox(width: 8),
        Text(
          'Fecha de cumpleaños: ${DateFormat("d 'de' MMMM", 'es_ES').format(_birthDate)}',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => selectDateBirth(context),
          icon: const Icon(Icons.calendar_today),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (widget.member == null) {
        context.read<MemberBloc>().add(AddMemberEvent(
              name: _nameController.text,
              role: _roleController.text,
              imageUrl: _imageUrlController.text,
              birthDate: _birthDate,
              about: _aboutController.text,
            ));
      } else {
        context.read<MemberBloc>().add(UpdateMemberEvent(
              id: widget.member!.id!,
              name: _nameController.text,
              role: _roleController.text,
              imageUrl: _imageUrlController.text,
              birthDate: _birthDate,
              about: _aboutController.text,
            ));
      }

      Navigator.of(context).pop();
    }
  }

  Future<void> selectDateBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }
}

Widget buildCustomTextField({
  required TextEditingController controller,
  required String label,
  bool isNumeric = false, // Permite solo números si es true
  IconData? leadingIcon, // Ícono opcional al principio del campo
  int? maxLines, // Número máximo de líneas, 1 por defecto
  String helperText = '', // Texto de ayuda opcional
  int? maxLength, // Longitud máxima del campo
  String? Function(String?)? validator, // Función de validación personalizada
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
      helperText: helperText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[200], // Fondo de color para visibilidad
    ),
    keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
    maxLines: maxLines ?? 1,
    maxLength: maxLength,
    buildCounter: (context,
            {required currentLength, required isFocused, int? maxLength}) =>
        maxLength != null
            ? Text('$currentLength de $maxLength',
                style: const TextStyle(color: Colors.grey))
            : null,
    validator: validator ??
        (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
  );
}

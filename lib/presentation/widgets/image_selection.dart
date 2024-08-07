import 'package:dance_club_comuna_8/logic/bloc/images/image_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_states.dart';
import 'package:flutter/material.dart';
import 'package:dance_club_comuna_8/logic/models/image_bucket.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageSelectionDialog extends StatefulWidget {
  const ImageSelectionDialog({super.key});

  @override
  _ImageSelectionDialogState createState() => _ImageSelectionDialogState();
}

class _ImageSelectionDialogState extends State<ImageSelectionDialog> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedImageUrl = '';
  bool _isUrlMode = true;

  @override
  void initState() {
    super.initState();
    context.read<ImageBloc>().add(const GetImagesPathsEvent(path: 'images'));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar imagen'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: true, label: Text('URL')),
                ButtonSegment<bool>(value: false, label: Text('Galería')),
              ],
              selected: {_isUrlMode},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isUrlMode = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_isUrlMode)
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen',
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedImageUrl = value;
                  });
                },
              )
            else
              BlocBuilder<ImageBloc, ImageState>(
                builder: (context, state) {
                  if (state is ImagesPathsLoadedState) {
                    return DropdownButton<String>(
                      value: _selectedImageUrl.isNotEmpty
                          ? _selectedImageUrl
                          : null,
                      hint: const Text('Selecciona una imagen'),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedImageUrl = newValue;
                          });
                        }
                      },
                      items: state.images
                          .map<DropdownMenuItem<String>>((ImageBucket image) {
                        return DropdownMenuItem<String>(
                          value: image.imagePath,
                          child: Text(image.imageName),
                        );
                      }).toList(),
                    );
                  } else if (state is ImageLoadingState) {
                    return const CircularProgressIndicator();
                  } else {
                    return const Text('Error al cargar las imágenes');
                  }
                },
              ),
            const SizedBox(height: 16),
            if (_selectedImageUrl.isNotEmpty)
              Image.network(
                _selectedImageUrl,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('No se pudo cargar la imagen');
                },
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _selectedImageUrl.isNotEmpty
              ? () => Navigator.of(context).pop(_selectedImageUrl)
              : null,
          child: const Text('Seleccionar'),
        ),
      ],
    );
  }
}

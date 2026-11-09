import 'package:dance_club_comuna_8/logic/bloc/images/image_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_states.dart';
import 'package:flutter/material.dart';
import 'package:dance_club_comuna_8/logic/models/image_bucket.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Widget imageSelectionButton(
    BuildContext context, TextEditingController imageUrlController) {
  return IconButton(
    icon: const Icon(Icons.image_search),
    onPressed: () => _showImageSelectionDialog(context, imageUrlController),
    tooltip: 'Seleccionar imagen',
  );
}

Future<void> _showImageSelectionDialog(
    BuildContext context, TextEditingController imageUrlController) async {
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

class ImageSelectionDialog extends StatefulWidget {
  const ImageSelectionDialog({super.key});

  @override
  State<ImageSelectionDialog> createState() => _ImageSelectionDialogState();
}

class _ImageSelectionDialogState extends State<ImageSelectionDialog> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedImageUrl = '';
  bool _isUrlMode = true;
  bool _isImageValid = false;

  @override
  void initState() {
    super.initState();
    context.read<ImageBloc>().add(const GetImagesPathsEvent(path: ''));
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _validateImage(String url) {
    setState(() {
      _selectedImageUrl = url;
      _isImageValid = false; // Reset validation
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedImageUrl = '';
      _isImageValid = false;
      _urlController.clear(); // Limpiar el TextEditingController
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar imagen'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(value: true, label: Text('URL')),
                    ButtonSegment<bool>(value: false, label: Text('Galería')),
                  ],
                  selected: {_isUrlMode},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _isUrlMode = newSelection.first;
                      _resetSelection(); // Resetear selección y limpiar campos
                    });
                  },
                  style: const ButtonStyle(),
                ),
              ),
              const SizedBox(height: 16),
              if (_isUrlMode)
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL de la imagen',
                  ),
                  onChanged: _validateImage,
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
                            _validateImage(newValue);
                          }
                        },
                        isExpanded: true,
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
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      // Image is fully loaded
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          _isImageValid = true;
                        });
                      });
                      return child;
                    }
                    // Image is still loading
                    return const CircularProgressIndicator();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _isImageValid = false;
                      });
                    });
                    return const Text('No se pudo cargar la imagen');
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isImageValid
              ? () => Navigator.of(context).pop(_selectedImageUrl)
              : null,
          child: const Text('Seleccionar'),
        ),
      ],
    );
  }
}

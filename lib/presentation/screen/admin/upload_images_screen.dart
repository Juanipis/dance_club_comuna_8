import 'package:dance_club_comuna_8/logic/bloc/images/image_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadImagesScreen extends StatefulWidget {
  const UploadImagesScreen({super.key});

  @override
  State<UploadImagesScreen> createState() => _UploadImagesScreenState();
}

class _UploadImagesScreenState extends State<UploadImagesScreen> {
  Logger logger = Logger();
  Uint8List? fileBytes;
  bool imageSelected = false;
  String fileName = '';
  Uint8List? imageBytes;

  Future<void> _launchURL(String path) async {
    final Uri url = Uri.parse(path);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _uploadImageWidget(BuildContext context) async {
    TextEditingController imageNameController = TextEditingController();
    String fileName = '';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Subir imagen'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text('Seleccione la imagen que desea subir'),
                    ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          imageBytes = await image.readAsBytes();
                          String? mimeType = image.mimeType;
                          if (mimeType == 'image/jpeg' ||
                              mimeType == 'image/png') {
                            setState(() {
                              fileBytes = imageBytes;
                              imageSelected = true;
                              fileName =
                                  'image_${DateTime.now().millisecondsSinceEpoch}';
                            });
                            logger.d('Image selected');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Por favor seleccione una imagen de tipo JPG o PNG.'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Seleccionar imagen'),
                    ),
                    if (imageSelected && fileBytes != null)
                      Image.memory(
                        fileBytes!,
                        width: 100,
                        height: 100,
                      ),
                    TextField(
                      controller: imageNameController..text = fileName,
                      decoration: const InputDecoration(
                          labelText: 'Nombre de la imagen',
                          hintText: 'Nombre de la imagen'),
                    ),
                    Text(
                        "Tamaño de la imagen: ${fileBytes?.length ?? 0} bytes"),
                    const Text(
                        "Se recomienda que la imagen no exceda los 500kb, dado que puede hacer que se incurra en costos adicionales, utilice un compresor de imágenes para reducir el tamaño de la imagen."),
                    const Text(
                        "La imagen se va a guardar en .jpg, no añada la extensión")
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: const Text('Subir'),
                  onPressed: () {
                    if (fileBytes != null) {
                      String imageName = imageNameController.text;

                      // Verificar y eliminar cualquier extensión de archivo
                      imageName = imageName.replaceAll(RegExp(r'\..*'), '');

                      // Verificar que el nombre no contenga caracteres especiales
                      final validCharacters = RegExp(r'^[a-zA-Z0-9_]+$');
                      if (!validCharacters.hasMatch(imageName)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'El nombre de la imagen no debe contener caracteres especiales.'),
                          ),
                        );
                        return;
                      }

                      BlocProvider.of<ImageBloc>(context)
                          .add(UploadImageUnit8ListEvent(
                        path: '',
                        imageName: '$imageName.jpg',
                        fileBytes: fileBytes!,
                      ));
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Seleccione una imagen'),
                        ),
                      );
                    }
                  },
                ),
                ElevatedButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ImageBloc>(context)
        .add(const GetImagesPathsEvent(path: ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar imágenes'),
      ),
      body: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          if (state is ImageLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ImagesPathsLoadedState) {
            return ListView.builder(
              itemCount: state.images.length,
              itemBuilder: (context, index) {
                final image = state.images[index];
                return ListTile(
                  title: Text(image.imageName),
                  subtitle: Text(image.imagePath),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          BlocProvider.of<ImageBloc>(context).add(
                              DeleteImageEvent(
                                  path: image.imagePath,
                                  imageName: image.imageName));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: image.imagePath));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('URL copiada al portapapeles')),
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          _launchURL(image.imagePath);
                        },
                        icon: const Icon(Icons.open_in_new),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is UploadingImageState) {
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Subiendo imagen'),
                  CircularProgressIndicator(),
                ],
              ),
            );
          } else if (state is ImageUploadedState ||
              state is ImageDeletedState) {
            BlocProvider.of<ImageBloc>(context)
                .add(const GetImagesPathsEvent(path: ''));
          } else if (state is UploadingImageState) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Cargando imágenes'),
                  CircularProgressIndicator(),
                ],
              ),
            );
          } else if (state is ImageDeletingState) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Eliminando imagen'),
                  CircularProgressIndicator(),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _uploadImageWidget(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

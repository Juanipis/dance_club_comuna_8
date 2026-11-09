import 'package:http/http.dart' as http;

class ImageValidator {
  static Future<bool> isValidImageUrl(String imageUrl) async {
    // Expresión regular mejorada para permitir parámetros después del signo de interrogación
    final regex = RegExp(r'^https?:\/\/.*\.(png|jpg|jpeg|gif|webp)(\?.*)?$');

    if (!regex.hasMatch(imageUrl)) {
      return false;
    }

    try {
      final response = await http.get(Uri.parse(imageUrl));
      // Verificar que el código de estado es 200 y que el tipo de contenido es una imagen
      if (response.statusCode == 200) {
        return _isImageContentType(response.headers['content-type']) ||
            _hasImageFileExtension(imageUrl);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Función para verificar si el tipo de contenido es una imagen
  static bool _isImageContentType(String? contentType) {
    if (contentType == null) return false;
    return contentType.startsWith('image/');
  }

  // Función para verificar si la URL tiene una extensión de archivo de imagen válida
  static bool _hasImageFileExtension(String url) {
    final extensions = ['png', 'jpg', 'jpeg', 'gif', 'webp'];
    final uri = Uri.parse(url);
    final path = uri.path;
    return extensions.any((ext) => path.endsWith(ext));
  }
}

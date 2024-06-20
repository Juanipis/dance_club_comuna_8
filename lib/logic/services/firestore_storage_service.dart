import 'dart:io';
import 'dart:typed_data';

import 'package:dance_club_comuna_8/logic/models/image_bucket.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';

class FirestoreStorageService {
  final Logger logger = Logger();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<ImageBucket> uploadImage(
      String path, String imagePath, String imageName) async {
    logger.d('Uploading image to storage');
    File file = File(imagePath);
    try {
      await _storage.ref(path).child(imageName).putFile(file);
      String downloadUrl = await _storage.ref(path).getDownloadURL();
      return ImageBucket(imagePath: downloadUrl, imageName: imageName);
    } catch (e) {
      logger.e('Error uploading image: $e');
      return ImageBucket(imagePath: '', imageName: '');
    }
  }

  Future<List<ImageBucket>> getImagesPaths(String path) async {
    logger.d('Getting images paths from storage');
    List<ImageBucket> images = [];
    try {
      ListResult result = await _storage.ref(path).list();
      for (Reference ref in result.items) {
        String downloadUrl = await ref.getDownloadURL();
        images.add(ImageBucket(imagePath: downloadUrl, imageName: ref.name));
      }
      return images;
    } catch (e) {
      logger.e('Error getting images paths: $e');
      return [];
    }
  }

  Future<ImageBucket> uploadImageAsBytes(
      String path, String imageName, Uint8List fileBytes) async {
    logger.d('Uploading image to storage');
    try {
      await _storage.ref(path).child(imageName).putData(fileBytes);
      String downloadUrl =
          await _storage.ref(path).child(imageName).getDownloadURL();
      return ImageBucket(imagePath: downloadUrl, imageName: imageName);
    } catch (e) {
      logger.e('Error uploading image: $e');
      return ImageBucket(imagePath: '', imageName: '');
    }
  }

  Future<void> deleteImage(String path, String imageName) async {
    logger.d('Deleting image from storage');
    try {
      await _storage.ref(path).child(imageName).delete();
    } catch (e) {
      logger.e('Error deleting image: $e');
    }
  }
}

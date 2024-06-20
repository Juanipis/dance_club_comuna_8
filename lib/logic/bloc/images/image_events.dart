import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class ImageEvent extends Equatable {
  const ImageEvent();
}

class UploadImageEvent extends ImageEvent {
  final String path;
  final String imagePath;
  final String imageName;

  const UploadImageEvent(
      {required this.path, required this.imagePath, required this.imageName});

  @override
  List<Object?> get props => [path, imagePath, imageName];
}

class UploadImageUnit8ListEvent extends ImageEvent {
  final String path;
  final String imageName;
  final Uint8List fileBytes;

  const UploadImageUnit8ListEvent(
      {required this.path, required this.imageName, required this.fileBytes});

  @override
  List<Object?> get props => [path, imageName, fileBytes];
}

class DeleteImageEvent extends ImageEvent {
  final String path;
  final String imageName;

  const DeleteImageEvent({required this.path, required this.imageName});

  @override
  List<Object?> get props => [path, imageName];
}

class GetImagesPathsEvent extends ImageEvent {
  final String path;

  const GetImagesPathsEvent({required this.path});

  @override
  List<Object?> get props => [path];
}

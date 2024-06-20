import 'package:dance_club_comuna_8/logic/models/image_bucket.dart';
import 'package:equatable/equatable.dart';

abstract class ImageState extends Equatable {}

class ImageInitialState extends ImageState {
  @override
  List<Object> get props => [];
}

class ImageLoadingState extends ImageState {
  @override
  List<Object> get props => [];
}

class ImageUploadedState extends ImageState {
  final ImageBucket image;

  ImageUploadedState({required this.image});

  @override
  List<Object> get props => [image];
}

class ImagesPathsLoadedState extends ImageState {
  final List<ImageBucket> images;

  ImagesPathsLoadedState(this.images);

  @override
  List<Object?> get props => [images];
}

class UploadingImageState extends ImageState {
  @override
  List<Object> get props => [];
}

class ImageDeletedState extends ImageState {
  @override
  List<Object> get props => [];
}

class ImageDeletingState extends ImageState {
  @override
  List<Object> get props => [];
}

class ImageErrorState extends ImageState {
  final String message;

  ImageErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

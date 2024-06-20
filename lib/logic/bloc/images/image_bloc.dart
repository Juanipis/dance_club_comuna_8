import 'package:dance_club_comuna_8/logic/bloc/images/image_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/images/image_states.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final FirestoreStorageService firestoreStorageService;

  ImageBloc({required this.firestoreStorageService})
      : super(ImageInitialState()) {
    on<UploadImageEvent>((event, emit) async {
      emit(UploadingImageState());
      final image = await firestoreStorageService.uploadImage(
          event.path, event.imagePath, event.imageName);
      if (image.imagePath.isNotEmpty) {
        emit(ImageUploadedState(image: image));
      } else {
        emit(ImageErrorState(message: 'Error uploading image'));
      }
    });

    on<GetImagesPathsEvent>((event, emit) async {
      emit(ImageLoadingState());
      final images = await firestoreStorageService.getImagesPaths(event.path);
      if (images.isNotEmpty) {
        emit(ImagesPathsLoadedState(images));
      } else {
        emit(ImageErrorState(message: 'Error getting images paths'));
      }
    });

    on<UploadImageUnit8ListEvent>((event, emit) async {
      emit(UploadingImageState());
      final image = await firestoreStorageService.uploadImageAsBytes(
          event.path, event.imageName, event.fileBytes);
      if (image.imagePath.isNotEmpty) {
        emit(ImageUploadedState(image: image));
      } else {
        emit(ImageErrorState(message: 'Error uploading image'));
      }
    });

    on<DeleteImageEvent>((event, emit) async {
      emit(ImageDeletingState());
      await firestoreStorageService.deleteImage(event.path, event.imageName);
      emit(ImageDeletedState());
    });
  }
}

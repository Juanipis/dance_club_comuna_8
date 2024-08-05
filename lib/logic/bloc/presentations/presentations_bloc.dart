import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_states.dart';
import 'package:dance_club_comuna_8/logic/models/blog_post.dart';
import 'package:dance_club_comuna_8/logic/services/firestore_presentations_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PresentationsBloc extends Bloc<PresentationsEvent, PresentationsState> {
  final FirestorePresentationsService firestorePresentationsService;
  List<BlogPost> cachedPosts = [];
  DocumentSnapshot? lastDocument;

  PresentationsBloc({required this.firestorePresentationsService})
      : super(PresentationsInitialState()) {
    on<GetPresentationsEvent>((event, emit) async {
      try {
        emit(PresentationsLoadingState());
        final posts = await firestorePresentationsService.getPosts(
          limit: 10,
          startAfter: lastDocument,
        );

        if (posts.isNotEmpty) {
          cachedPosts.addAll(posts);
          lastDocument = await FirebaseFirestore.instance
              .collection('presentations')
              .doc(posts.last.id)
              .get();
          emit(PresentationsLoadedState(List.from(cachedPosts)));
        } else {
          emit(PresentationsNoMorePostsState());
        }
      } catch (e) {
        emit(PresentationsErrorState(
            message: 'Error loading presentations: $e'));
      }
    });

    on<AddPresentationEvent>((event, emit) async {
      try {
        emit(PresentationsLoadingState());
        final post = await firestorePresentationsService.addBlogPost(
          event.title,
          event.content,
          event.date,
        );
        cachedPosts.insert(0, post);
        emit(PresentationsLoadedState(List.from(cachedPosts)));
      } catch (e) {
        emit(PresentationsErrorState(message: 'Error adding presentation: $e'));
      }
    });

    on<RefreshPresentationsEvent>((event, emit) async {
      cachedPosts.clear();
      lastDocument = null;
      add(GetPresentationsEvent());
    });
  }
}

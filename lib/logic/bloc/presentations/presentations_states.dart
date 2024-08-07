import 'package:dance_club_comuna_8/logic/models/blog_post.dart';
import 'package:equatable/equatable.dart';

abstract class PresentationsState extends Equatable {}

class PresentationsInitialState extends PresentationsState {
  @override
  List<Object> get props => [];
}

class PresentationsLoadingState extends PresentationsState {
  @override
  List<Object> get props => [];
}

class PresentationsLoadedState extends PresentationsState {
  final List<BlogPost> posts;
  final bool hasReachedMax;

  PresentationsLoadedState(this.posts, {this.hasReachedMax = false});

  @override
  List<Object?> get props => [posts];
}

class PresentationsErrorState extends PresentationsState {
  final String message;

  PresentationsErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class PresentationsNoMorePostsState extends PresentationsState {
  @override
  List<Object> get props => [];
}

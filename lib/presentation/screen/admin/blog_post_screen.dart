import 'package:dance_club_comuna_8/presentation/screen/admin/blog_post_edit/blog_post_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_states.dart';
import 'package:dance_club_comuna_8/logic/models/blog_post.dart';

class BlogPostScreen extends StatefulWidget {
  const BlogPostScreen({super.key});

  @override
  State<BlogPostScreen> createState() => _BlogPostScreenState();
}

class _BlogPostScreenState extends State<BlogPostScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<PresentationsBloc>().add(GetPresentationsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Administrador de posts"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<PresentationsBloc, PresentationsState>(
        builder: (context, state) {
          if (state is PresentationsInitialState) {
            context.read<PresentationsBloc>().add(GetPresentationsEvent());
            return const Center(child: CircularProgressIndicator());
          } else if (state is PresentationsLoadedState) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<PresentationsBloc>()
                    .add(RefreshPresentationsEvent());
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.posts.length + 1,
                itemBuilder: (context, index) {
                  if (index == state.posts.length) {
                    return _buildLoaderOrEndMessage(state);
                  }
                  return _buildPostListItem(state.posts[index]);
                },
              ),
            );
          } else if (state is PresentationsErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is PresentationsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PresentationDeletedState) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Post con ID ${state.id} eliminado'),
                  duration: const Duration(seconds: 3),
                ),
              );
            });
            return const SizedBox.shrink();
          } else {
            return const Center(child: Text('No hay posts disponibles'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoaderOrEndMessage(PresentationsLoadedState state) {
    if (state.hasReachedMax) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay más presentaciones'),
        ),
      );
    } else {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget _buildPostListItem(BlogPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(post.title),
        subtitle: Text(
            'ID: ${post.id}\nFecha: ${DateFormat('dd/MM/yyyy').format(post.date)}'),
        trailing: SizedBox(
          width: 80,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _navigateToEditScreen(context, post: post),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // launch a delete confirmation dialog
                  _deleteDialog(post);
                },
              ),
            ],
          ),
        ),
        onTap: () => _navigateToEditScreen(context, post: post),
      ),
    );
  }

  Future<dynamic> _deleteDialog(BlogPost post) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar post'),
        content: const Text('¿Estás seguro de que deseas eliminar este post?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<PresentationsBloc>()
                  .add(DeletePresentationEvent(id: post.id));
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, {BlogPost? post}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlogPostEditScreen(post: post),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<PresentationsBloc>().add(GetPresentationsEvent());
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
          if (state is PresentationsLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PresentationsLoadedState) {
            return ListView.builder(
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                return _buildPostListItem(state.posts[index]);
              },
            );
          } else if (state is PresentationsErrorState) {
            return Center(child: Text('Error: ${state.message}'));
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

  Widget _buildPostListItem(BlogPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(post.title),
        subtitle: Text(post.date.toString()),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _navigateToEditScreen(context, post: post),
        ),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, {BlogPost? post}) {
    // Aquí navegarías a una pantalla de edición/creación de posts
    // Por ahora, solo mostraremos un diálogo como placeholder
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(post == null ? 'Añadir nuevo post' : 'Editar post'),
          content: Text(post == null
              ? 'Aquí iría el formulario para añadir un nuevo post'
              : 'Aquí iría el formulario para editar el post: ${post.title}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

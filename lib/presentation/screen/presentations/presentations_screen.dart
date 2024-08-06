import 'package:dance_club_comuna_8/logic/models/blog_post.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_states.dart';
import 'package:dance_club_comuna_8/presentation/screen/presentations/blog_post_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class BuildPresentationsScreen extends StatefulWidget {
  const BuildPresentationsScreen({super.key});

  @override
  State<BuildPresentationsScreen> createState() =>
      _BuildPresentationsScreenState();
}

class _BuildPresentationsScreenState extends State<BuildPresentationsScreen> {
  final ScrollController _scrollController = ScrollController();
  Logger logger = Logger();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PresentationsBloc, PresentationsState>(
      builder: (context, state) {
        if (state is PresentationsInitialState) {
          context.read<PresentationsBloc>().add(GetPresentationsEvent());
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<PresentationsBloc>().add(RefreshPresentationsEvent());
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Presentaciones',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (state is PresentationsLoadedState)
                      ...state.posts.map(_buildPostCard),
                    _buildLoaderOrEndMessage(state),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoaderOrEndMessage(PresentationsState state) {
    if (state is PresentationsLoadedState) {
      return ElevatedButton(
          onPressed: () {
            context.read<PresentationsBloc>().add(GetPresentationsEvent());
          },
          child: const Text('Cargar más'));
    }
    if (state is PresentationsLoadingState) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PresentationsNoMorePostsState) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay más presentaciones'),
        ),
      );
    } else if (state is PresentationsErrorState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(state.message),
        ),
      );
    }

    return const Center(child: Text('No hay más presentaciones'));
  }

  Widget _buildPostCard(BlogPost post) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth =
            constraints.maxWidth > 500 ? 500 : constraints.maxWidth;

        return Card(
          margin: const EdgeInsets.all(15.0),
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines:
                      2, // Limita a 2 líneas para evitar que el título sea demasiado largo
                  overflow: TextOverflow
                      .ellipsis, // Añade "..." si el texto es demasiado largo
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Fecha: ${post.date.toString()}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 16.0),
                post.imageUrl != null && post.imageUrl!.isNotEmpty
                    ? Image.network(
                        post.imageUrl!,
                        width: cardWidth *
                            0.9, // Ajusta el ancho de la imagen de forma responsiva
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/placeholder.webp',
                        width: cardWidth *
                            0.9, // Ajusta el ancho de la imagen de forma responsiva
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                const SizedBox(height: 8.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      //create a BlogPostScreenView with the post
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              BlogPostScreenView(post: post)));
                    },
                    child: const Text('Ver más'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

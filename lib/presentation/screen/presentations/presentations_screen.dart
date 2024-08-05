import 'package:dance_club_comuna_8/logic/models/blog_post.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/presentations/presentations_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildPresentationsScreen extends StatefulWidget {
  const BuildPresentationsScreen({super.key});

  @override
  State<BuildPresentationsScreen> createState() =>
      _BuildPresentationsScreenState();
}

class _BuildPresentationsScreenState extends State<BuildPresentationsScreen> {
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                if (state is PresentationsLoadedState)
                  ...state.posts.map(_buildPostCard),
                _buildLoaderOrEndMessage(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoaderOrEndMessage(PresentationsState state) {
    if (state is PresentationsLoadingState) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is PresentationsNoMorePostsState) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hay más presentaciones'),
      ));
    } else if (state is PresentationsErrorState) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(state.message),
      ));
    }
    return const SizedBox.shrink();
  }

  Widget _buildPostCard(BlogPost post) {
    // Reemplazar secuencias que deberían representar saltos de línea o párrafos
    String formattedContent = post.content.replaceAll(r'\n', '\n');

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Fecha: ${post.date.toString()}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 16.0),
            MarkdownBody(
              data: formattedContent,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 14.0),
                h1: const TextStyle(fontSize: 20.0),
                h2: const TextStyle(fontSize: 18.0),
                h3: const TextStyle(fontSize: 16.0),
                h4: const TextStyle(fontSize: 14.0),
                h5: const TextStyle(fontSize: 12.0),
                h6: const TextStyle(fontSize: 10.0),
              ),
              onTapLink: (text, href, title) {
                if (href != null) {
                  launchUrl(Uri.parse(href));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

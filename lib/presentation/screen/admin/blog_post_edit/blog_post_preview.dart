import 'package:dance_club_comuna_8/presentation/widgets/carousel_videos_youtube.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogPostPreview extends StatelessWidget {
  final String title;
  final String content;
  final DateTime date;
  final List<String> videoUrls;

  const BlogPostPreview({
    super.key,
    required this.title,
    required this.content,
    required this.date,
    required this.videoUrls,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(50.0, 40.0, 50.0, 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Date: ${DateFormat('dd/MM/yyyy').format(date)}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 16),
          MarkdownBody(
            data: content,
            selectable: true,
            styleSheet:
                MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: const TextStyle(fontSize: 16.0),
              h1: Theme.of(context).textTheme.headlineMedium,
              h2: Theme.of(context).textTheme.headlineSmall,
              h3: Theme.of(context).textTheme.titleLarge,
              h4: Theme.of(context).textTheme.titleMedium,
              h5: Theme.of(context).textTheme.titleSmall,
              h6: Theme.of(context).textTheme.labelLarge,
            ),
            onTapLink: (text, href, title) {
              if (href != null) {
                launchUrl(Uri.parse(href));
              }
            },
          ),
          const SizedBox(height: 16),
          if (videoUrls.isNotEmpty) ...[
            Center(
              child: Text(
                'Videos',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 16),
            YouTubeCarousel(
              videoUrls: videoUrls,
              width: MediaQuery.of(context).size.width,
              height: 300,
            ),
          ],
        ],
      ),
    );
  }
}

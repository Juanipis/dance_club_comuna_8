import 'package:dance_club_comuna_8/logic/models/blog_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class BlogPostScreenView extends StatelessWidget {
  final BlogPost post;

  const BlogPostScreenView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: SingleChildScrollView(
        // pading left and right 50
        // padding top and bottom 40
        padding: const EdgeInsets.fromLTRB(50.0, 40.0, 50.0, 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: Theme.of(context).textTheme.displayMedium,
            ),
            Text(
              'Fecha: ${post.date.toString()}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 16.0),
            MarkdownBody(
              data: post.content,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 16.0, color: Colors.black),
                h1: const TextStyle(
                    fontSize: 26.0, fontWeight: FontWeight.bold),
                h2: const TextStyle(
                    fontSize: 24.0, fontWeight: FontWeight.bold),
                h3: const TextStyle(
                    fontSize: 22.0, fontWeight: FontWeight.bold),
                h4: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
                h5: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.bold),
                h6: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              onTapLink: (text, href, title) {
                if (href != null) {
                  launchUrl(Uri.parse(href));
                }
              },
              selectable: true,
            ),
          ],
        ),
      ),
    );
  }
}

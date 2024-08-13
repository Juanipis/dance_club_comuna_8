import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPost {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String? imageUrl;
  final List<String>? videoUrls;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl,
    required this.videoUrls,
  });

  BlogPost copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    String? imageUrl,
    List<String>? videoUrls,
  }) {
    return BlogPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrls: videoUrls ?? this.videoUrls,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'imageUrl': imageUrl,
      'videoUrls': videoUrls,
    };
  }

  factory BlogPost.fromJson(Map<String, dynamic> json, String id) {
    return BlogPost(
      id: id,
      title: json['title'] as String,
      content: json['content'] as String,
      date: (json['date'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'] as String?,
      videoUrls: (json['videoUrls'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
    );
  }
}

class BlogPost {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String? imageUrl;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl,
  });

  BlogPost copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    String? imageUrl,
  }) {
    return BlogPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'imageUrl': imageUrl,
    };
  }
}

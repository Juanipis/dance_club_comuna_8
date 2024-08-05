class BlogPost {
  final String id;
  final String title;
  final String content;
  final DateTime date;

  BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  BlogPost copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
  }) {
    return BlogPost(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String id;
  final String name;
  final String role;
  final String imageUrl;
  final DateTime birthDate;
  final String about;

  Member({
    required this.id,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.birthDate,
    required this.about,
  });

  Member copyWith({
    String? name,
    String? role,
    String? imageUrl,
    DateTime? birthDate,
    String? about,
  }) {
    return Member(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      imageUrl: imageUrl ?? this.imageUrl,
      birthDate: birthDate ?? this.birthDate,
      about: about ?? this.about,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'imageUrl': imageUrl,
      'birthDate': Timestamp.fromDate(birthDate),
      'about': about,
    };
  }

  factory Member.fromJson(Map<String, dynamic> json, String id) {
    return Member(
      id: id,
      name: json['name'] as String,
      role: json['role'] as String,
      imageUrl: json['imageUrl'] as String,
      birthDate: (json['birthDate'] as Timestamp).toDate(),
      about: json['about'] as String,
    );
  }
}

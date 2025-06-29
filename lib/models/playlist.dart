import 'package:selman/models/content.dart';

class Playlist {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final List<Content>? contents;

  Playlist({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.contents,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    // Logic to parse the list of content if it exists
    var contentList = <Content>[];
    if (json['contents'] != null) {
      json['contents'].forEach((v) {
        contentList.add(Content.fromJson(v));
      });
    }

    return Playlist(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      contents: contentList,
    );
  }
}

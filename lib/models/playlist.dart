class Playlist {
  final int id;
  final int userId;
  final String name;
  final String? description;

  Playlist({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

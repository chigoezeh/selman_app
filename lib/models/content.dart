import 'package:selman/models/category.dart';
import 'package:selman/models/minister.dart';
import 'package:selman/models/organization.dart';

class Content {
  final int id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String mediaType;
  final String mediaUrl;
  final int durationInSeconds;
  final Category? category;
  final Minister? minister;
  final Organization? organization;
  final bool isFavorited;

  Content({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    required this.mediaType,
    required this.mediaUrl,
    required this.durationInSeconds,
    this.category,
    this.minister,
    this.organization,
    this.isFavorited = false,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      mediaType: json['media_type'],
      mediaUrl: json['media_url'],
      durationInSeconds: json['duration_in_seconds'],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      minister:
          json['minister'] != null ? Minister.fromJson(json['minister']) : null,
      organization: json['organization'] != null
          ? Organization.fromJson(json['organization'])
          : null,
      isFavorited: json['is_favorited'] ?? false,
    );
  }
}

import 'package:selman/models/content.dart';

class HomeData {
  final List<Content> recentlyPlayed;
  final List<Content> newestSermons;
  final List<Content> trendingWorship;

  HomeData({
    required this.recentlyPlayed,
    required this.newestSermons,
    required this.trendingWorship,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      recentlyPlayed: (json['recentlyPlayed'] as List)
          .map((item) => Content.fromJson(item))
          .toList(),
      newestSermons: (json['newestSermons'] as List)
          .map((item) => Content.fromJson(item))
          .toList(),
      trendingWorship: (json['trendingWorship'] as List)
          .map((item) => Content.fromJson(item))
          .toList(),
    );
  }
}

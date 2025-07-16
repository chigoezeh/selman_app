import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selman/models/content.dart';
import 'package:selman/models/home_data.dart';
import 'package:selman/providers/auth_provider.dart';
import 'package:selman/screens/content_detail_screen.dart';
import 'package:selman/services/api_service.dart';
import 'package:selman/screens/profile_screen.dart';
import 'package:selman/screens/settings_screen.dart';
import 'package:selman/screens/about_screen.dart';

class ContentListScreen extends StatefulWidget {
  const ContentListScreen({super.key});

  @override
  State<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
  final ApiService _apiService = ApiService();
  Future<HomeData>? _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  void _fetchHomeData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _homeDataFuture = _apiService.fetchHomeData(authProvider.token);
    });
  }

  Future<void> _onRefresh() async {
    _fetchHomeData();
    return _homeDataFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selman"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()));
                  break;
                case 'settings':
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                  break;
                case 'about':
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutScreen()));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                    leading: Icon(Icons.person), title: Text('My Profile')),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                    leading: Icon(Icons.settings), title: Text('Settings')),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: ListTile(
                    leading: Icon(Icons.info_outline), title: Text('About Us')),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder<HomeData>(
          future: _homeDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final homeData = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (homeData.recentlyPlayed.isNotEmpty)
                      _buildContentSection(
                        title: 'Recently Played',
                        contentList: homeData.recentlyPlayed,
                      ),
                    _buildContentSection(
                      title: 'Newest Sermons',
                      contentList: homeData.newestSermons,
                    ),
                    _buildContentSection(
                      title: 'Trending Worship',
                      contentList: homeData.trendingWorship,
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No content available.'));
            }
          },
        ),
      ),
    );
  }

  // Helper widget to build a single section with a title and a horizontal list
  Widget _buildContentSection({
    required String title,
    required List<Content> contentList,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 240, // Height of the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: contentList.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 160, // Width of each card in the list
                child: _buildHorizontalContentCard(contentList[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // A smaller card designed for horizontal scrolling lists
  Widget _buildHorizontalContentCard(Content content) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentDetailScreen(content: content),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[800],
              child: content.thumbnailUrl != null
                  ? Image.network(content.thumbnailUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.play_circle_outline,
                      color: Colors.white, size: 50),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                content.title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

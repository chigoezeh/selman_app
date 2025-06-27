import 'package:flutter/material.dart';
import 'package:selman/models/content.dart';
import 'package:selman/services/api_service.dart';
import 'package:selman/widgets/content_card.dart';
import 'package:selman/screens/about_screen.dart';
import 'package:selman/screens/profile_screen.dart';
import 'package:selman/screens/settings_screen.dart';

class ContentListScreen extends StatefulWidget {
  const ContentListScreen({super.key});

  @override
  State<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
  // Create an instance of our ApiService
  final ApiService _apiService = ApiService();

  // A variable to hold the result of our API call
  Future<List<Content>>? _contentFuture;

  @override
  void initState() {
    super.initState();
    // Start the initial fetch
    _fetchContent();
  }

  // Create a dedicated method for fetching data
  void _fetchContent() {
    setState(() {
      _contentFuture = _apiService.fetchContent();
    });
  }

  // Create the method that the RefreshIndicator will call
  Future<void> _onRefresh() async {
    setState(() {
      _contentFuture = _apiService.fetchContent();
    });
    await _contentFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What\'s New'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              // This function is called when a menu item is selected
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
                  leading: Icon(Icons.person),
                  title: Text('My Profile'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'about',
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About Us'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh, // The function to call when pulled
        child: Center(
          child: FutureBuilder<List<Content>>(
            future: _contentFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final contentList = snapshot.data!;
                return ListView.builder(
                  itemCount: contentList.length,
                  itemBuilder: (context, index) {
                    final contentItem = contentList[index];
                    return ContentCard(content: contentItem);
                  },
                );
              } else {
                return const Text('No content found.');
              }
            },
          ),
        ),
      ),
    );
  }
}

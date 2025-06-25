import 'package:flutter/material.dart';
import 'package:selman/models/content.dart';
import 'package:selman/services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selman',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ContentListScreen(),
    );
  }
}

class ContentListScreen extends StatefulWidget {
  const ContentListScreen({super.key});

  @override
  State<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends State<ContentListScreen> {
  // Create an instance of our ApiService
  final ApiService _apiService = ApiService();

  // A variable to hold the result of our API call
  late Future<List<Content>> _contentFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching the content as soon as the screen is initialized
    _contentFuture = _apiService.fetchContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What\'s New'),
      ),
      body: Center(
        child: FutureBuilder<List<Content>>(
          future: _contentFuture, // The future we want to build the UI based on
          builder: (context, snapshot) {
            // Check the state of the Future
            if (snapshot.connectionState == ConnectionState.waiting) {
              // If we're still waiting for data, show a loading spinner
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // If there was an error, display it
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // If we have data, build the list view
              final contentList = snapshot.data!;
              return ListView.builder(
                itemCount: contentList.length,
                itemBuilder: (context, index) {
                  final contentItem = contentList[index];
                  return ListTile(
                    leading: const Icon(Icons.video_library),
                    title: Text(contentItem.title),
                    subtitle: Text(contentItem.minister?.name ?? 'N/A'),
                  );
                },
              );
            } else {
              // Default case
              return const Text('No content found.');
            }
          },
        ),
      ),
    );
  }
}

import 'package:provider/provider.dart';
import 'package:selman/providers/auth_provider.dart';
import 'package:selman/screens/main_app_shell.dart';
import 'package:flutter/material.dart';
import 'package:selman/models/content.dart';
import 'package:selman/services/api_service.dart';
import 'package:selman/widgets/content_card.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selman',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF282828), // Dark card color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.tealAccent,
        ),
      ),
      home: const MainAppShell(),
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

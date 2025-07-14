import 'dart:async';
import 'package:flutter/material.dart';
import 'package:selman/models/content.dart';
import 'package:selman/services/api_service.dart';
import 'package:selman/widgets/playlist_content_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final _searchController = TextEditingController();

  List<Content> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  // This method is called whenever the text in the search field changes.
  void _onSearchChanged(String query) {
    // If a debounce timer is already active, cancel it.
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new timer. The search will only run after 500ms of no typing.
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 3) {
        _performSearch(query);
      } else {
        // Clear results if the query is too short
        setState(() {
          _results = [];
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _apiService.searchContent(query);
      setState(() {
        _results = results;
      });
    } catch (e) {
      // Handle search error
      print('Search error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The search bar is the title of the AppBar
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          autofocus: true, // Automatically focus the search bar
          decoration: const InputDecoration(
            hintText: 'Search for content, ministers...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isEmpty) {
      return const Center(
        child: Text('Start typing to search.'),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Text('No results found for "${_searchController.text}".'),
      );
    }

    // We can reuse our compact tile to display search results!
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final contentItem = _results[index];
        return PlaylistContentTile(content: contentItem);
      },
    );
  }
}

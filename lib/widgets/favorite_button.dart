import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selman/models/content.dart';
import 'package:selman/providers/auth_provider.dart';

class FavoriteButton extends StatefulWidget {
  final Content content;

  const FavoriteButton({super.key, required this.content});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorited;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set the initial state from the data passed to the widget
    _isFavorited = widget.content.isFavorited;
  }

  void _toggleFavorite() async {
    if (_isLoading) return; // Prevent multiple taps while processing

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (_isFavorited) {
        // If it is favorited, call the unfavorite method
        await authProvider.unfavoriteContent(widget.content.id);
      } else {
        // If it is not favorited, call the favorite method
        await authProvider.favoriteContent(widget.content.id);
      }

      // If the API call is successful, update the button's state
      setState(() {
        _isFavorited = !_isFavorited;
      });
    } catch (e) {
      // Show an error message if something went wrong
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      // Always stop loading at the end
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If loading, show a small spinner
    if (_isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2.0),
      );
    }

    // Otherwise, show the correct icon button
    return IconButton(
      icon: Icon(
        _isFavorited ? Icons.favorite : Icons.favorite_border,
        color:
            _isFavorited ? Theme.of(context).colorScheme.primary : Colors.white,
        size: 28,
      ),
      onPressed: _toggleFavorite,
    );
  }
}

import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBar(title: Text('About Selman')),
      body: Center(
        child: Text('Information about the app.'),
      ),
    );
  }
}

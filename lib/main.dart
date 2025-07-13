import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selman/providers/auth_provider.dart';
import 'package:selman/screens/auth_wrapper.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:selman/services/audio_handler.dart';

// This is our single, app-wide instance of the Audio Handler.
late MyAudioHandler _audioHandler;

Future<void> main() async {
  // Ensure Flutter is ready.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the display info for the background service (notifications)
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.selman.app.channel.audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
  );

  // Create our single audio handler instance.
  _audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.selman.app.channel.audio',
      androidNotificationChannelName: 'Audio Playback',
      androidNotificationOngoing: true,
    ),
  );

  // Run the app.
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(_audioHandler),
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
        cardColor: const Color(0xFF282828),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.tealAccent,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

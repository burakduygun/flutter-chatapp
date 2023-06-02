import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:chatapp/screens/chat.dart';
import 'package:chatapp/screens/splash.dart';
import 'package:chatapp/screens/login_screen.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark().copyWith(
          primary: const Color.fromARGB(255, 40, 43, 48),
          secondary: const Color.fromARGB(255, 54, 52, 62),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 37, 37, 38),
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 45, 45, 48),
        ),
        textTheme: GoogleFonts.interTextTheme().apply(
          displayColor: Colors.white,
        ),
      ),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (snapshot.hasData) {
              return const ChatScreen();
            }

            return const LoginScreen();
          }),
    );
  }
}

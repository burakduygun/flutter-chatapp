import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatApp'),
      ),
      body: const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 0, 122, 204),
        ),
      ),
    );
  }
}

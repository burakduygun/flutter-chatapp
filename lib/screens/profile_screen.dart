import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});
  final user = FirebaseAuth.instance.currentUser!;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<DocumentSnapshot> getUserData() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();
    // print('user: ${widget.user.email}');
    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile '),
      ),
      body: FutureBuilder(
        future: getUserData(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 0, 122, 204),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final userData = snapshot.data!;

            return Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(userData['image_url']),
                  ),
                  const SizedBox(height: 45),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'username',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white60),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            userData['username'],
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.email, color: Colors.grey),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white60),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            userData['email'],
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

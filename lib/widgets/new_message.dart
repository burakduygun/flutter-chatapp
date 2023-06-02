import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:geolocator/geolocator.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    //we used it to make sure that the memory resources occupied by the controller are freed as they are no longer needed.
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    //send to Firebase
    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'userImage': userData.data()!['image_url'],
    });
  }

  Future<Position?> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return null;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    return position;
  }

  void _sendLocationMessage() async {
    final location = await _getUserLocation();
    if (location != null) {
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final latitude = location.latitude;
      final longitude = location.longitude;

      FirebaseFirestore.instance.collection('chat').add({
        'text': 'Location: ${location.latitude}, ${location.longitude}',
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData.data()!['username'],
        'userImage': userData.data()!['image_url'],
        'latitude': latitude,
        'longitude': longitude,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Material(
            shape: const CircleBorder(),
            color: const Color.fromARGB(255, 30, 30, 36),
            child: InkWell(
              onTap: _sendLocationMessage,
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 30, 30, 36),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      cursorColor: const Color.fromARGB(255, 0, 122, 204),
                      textCapitalization: TextCapitalization.sentences,
                      autocorrect: true,
                      enableSuggestions: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        border: InputBorder.none,
                        hintText: 'Send a message...',
                        hintStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          Material(
            color: const Color.fromARGB(255, 0, 122, 204),
            shape: const CircleBorder(),
            child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.send),
                onPressed: _submitMessage),
          )
        ],
      ),
    );
  }
}

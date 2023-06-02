import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chatapp/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _form = GlobalKey<FormState>();

  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _selectedImage;

  bool _isObscure = true;

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || _selectedImage == null) {
      // show error message ...
      return;
    }

    _form.currentState!.save();

    try {
      //this method from the Firebase SDK will send a HTTP request to Firebase
      var userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);

      //ref(), projemize ait olan Firebase cloud storage alanının referansını verir
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('${userCredentials.user!.uid}.jpg');

      //we can call putFile method to upload a file to this path
      await storageRef.putFile(_selectedImage!);
      //it will give a URL that can be used to view the image stored in Firebase. We need this getDownloadURL() to use the file later in our application

      final imageUrl = await storageRef.getDownloadURL();

      //with the set method, we tell the document which data should be stored
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user!.uid)
          .set({
        'username': _enteredUsername,
        'email': _enteredEmail,
        'image_url': imageUrl,
      });

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        // ...
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 0, 122, 204),
          content: Text(
            error.message ?? 'Authentication failed',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: [
          UserImagePicker(
            onPickImage: (pickedImage) {
              _selectedImage = pickedImage;
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextFormField(
              cursorColor: const Color.fromARGB(255, 0, 122, 204),
              obscureText: false,
              decoration: const InputDecoration(
                hintText: 'Username',
                hintStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 0, 122, 204)),
                ),
              ),
              enableSuggestions: false,
              validator: (value) {
                if (value == null || value.isEmpty || value.trim().length < 4) {
                  return 'Please enter at least 4 characters.';
                }
                return null;
              },
              onSaved: (value) {
                _enteredUsername = value!;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextFormField(
              cursorColor: const Color.fromARGB(255, 0, 122, 204),
              obscureText: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              decoration: const InputDecoration(
                hintText: 'Email Address',
                hintStyle: TextStyle(color: Colors.white),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 0, 122, 204)),
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty ||
                    !value.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              onSaved: (value) {
                _enteredEmail = value!;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextFormField(
              obscureText: _isObscure,
              cursorColor: const Color.fromARGB(255, 0, 122, 204),
              decoration: InputDecoration(
                hintText: 'Password',
                hintStyle: const TextStyle(color: Colors.white),
                focusedBorder: const UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 0, 122, 204)),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                  icon: _isObscure
                      ? const Icon(Icons.visibility_off, color: Colors.white)
                      : const Icon(Icons.visibility, color: Colors.white),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 6) {
                  return 'Password must be a least 6 characters long.';
                }
                return null;
              },
              onSaved: (value) {
                _enteredPassword = value!;
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: _submit,
            style: ButtonStyle(
              alignment: Alignment.center,
              minimumSize: MaterialStateProperty.all(
                Size(
                  double.infinity,
                  MediaQuery.of(context).size.height * 0.07,
                ),
              ),
              backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 0, 122, 204)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: const Text('Sign Up', style: TextStyle(fontSize: 17)),
          ),
        ],
      ),
    );
  }
}

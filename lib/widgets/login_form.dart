import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _form = GlobalKey<FormState>();

  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isAuthenticating = false;

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      // show error message ...
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      //log users in
      final userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail, password: _enteredPassword);
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
      setState(
        () {
          _isAuthenticating = false;
        },
      );
    }
  }

  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: TextFormField(
              obscureText: false,
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color.fromARGB(255, 0, 122, 204),
              decoration: const InputDecoration(
                labelText: 'Email Address',
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 0, 122, 204)),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
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
              style: const TextStyle(color: Colors.white),
              cursorColor: const Color.fromARGB(255, 0, 122, 204),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(
                  color: Colors.white,
                ),
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
                      ? const Icon(
                          Icons.visibility_off,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.visibility,
                          color: Colors.white,
                        ),
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
          if (_isAuthenticating)
            const CircularProgressIndicator(
                color: Color.fromARGB(255, 0, 122, 204)),
          const SizedBox(
            height: 15,
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
            child: const Text('Log In', style: TextStyle(fontSize: 17)),
          ),
        ],
      ),
    );
  }
}

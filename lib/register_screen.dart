/* 
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> registerUser(String name, String email, String password, BuildContext context) async {
  const String url = 'http://localhost:3000/api/auth/register'; // Replace with actual URL

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration successful")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Registration failed')));
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
  }
}

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chatter_bridge/utilities/routes.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:developer' show log;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _registerWithEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = await 
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(homePageRoute, (route) => false);
        log(user.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered successfully')),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await 
        credential,
      );
      final user = userCredential.user;

      // Save user data to Firestore
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
        }, SetOptions(merge: true)); // merge to avoid overwriting
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signed in with Google')));
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(homePageRoute, (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.amber[200],
      body: Column(
        children: [
          const SizedBox(height: 55),
          Image.asset('assets/images/hello3.png', width: 400),
          // const SizedBox(height: 4),
          Expanded(
            child: Container(
              width: size.width,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Hello!",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 62, 143),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          hintText: 'Email',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator:
                            (value) =>
                                value!.contains('@')
                                    ? null
                                    : 'Enter a valid email',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
            registerUser(nameController.text, emailController.text, passwordController.text, context);
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator:
                            (value) =>
                                value!.length >= 6
                                    ? null
                                    : 'Password must be at least 6 characters',
                      ),
                      const SizedBox(height: 20),

                      /* Row(
                        children: const [
                          Checkbox(value: false, onChanged: null),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: "I agree to the ",
                                children: [
                                  TextSpan(
                                    text: "terms and conditions",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ), */
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _registerWithEmail,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Color.fromARGB(
                                  255,
                                  0,
                                  62,
                                  143,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(loginPageRoute);
                            },
                            child: const Text(
                              "Sign in",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      //const SizedBox(height: 5),
                      const Text(
                        "or",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _signInWithGoogle,
                            icon: Image.asset(
                              'assets/images/google.png',
                              width: 50,
                            ),
                          ),
                          // Add more social icons here if needed
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
 */

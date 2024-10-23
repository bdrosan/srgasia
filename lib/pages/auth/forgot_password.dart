import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:srgasia/pages/auth/reset_password.dart';

Future sendEmail(String email) async {
  final response = await http.post(
    Uri.parse('https://snspdev02.srgasia.com.my/sca_api/forgotPassword'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'email': email.trim()}),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 response,
    // then parse the JSON.
    return true;
  } else {
    // If the server did not return a 200 response,
    // then throw an exception.
    throw Exception('Failed to create reset request.');
  }
}

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPassword();
}

class _ForgotPassword extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  Future? _sendEmail;
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    _sendEmail;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Forgot Password"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        labelText: 'Email',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email cannot be be empty.';
                        }
                        return null;
                      },
                      controller: emailController,
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    FilledButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              const Color.fromARGB(255, 25, 32, 43)),
                          fixedSize:
                              WidgetStateProperty.all(const Size(280, 60))),
                      onPressed: () async {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _sendEmail = sendEmail(emailController.text);
                          });
                        }
                      },
                      child: const Text('Validate',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    if (_sendEmail != null) buildFutureBuilder(),
                    if (_sendEmail != null)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ResetPassword(email: emailController.text)),
                          );
                        },
                        child: const Text('Reset Password'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  FutureBuilder buildFutureBuilder() {
    return FutureBuilder(
      future: _sendEmail,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const Text(
              "Success: An email was sent with a reset code to the given address.");
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}

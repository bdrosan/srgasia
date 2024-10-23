import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:srgasia/pages/auth/login.dart';

Future resetPassword(String email, String resetCode, String newPassword) async {
  final response = await http.post(
    Uri.parse('https://snspdev02.srgasia.com.my/sca_api/resetPassword'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email.trim(),
      'resetCode': resetCode.trim(),
      'newPassword': newPassword.trim(),
    }),
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

class ResetPassword extends StatefulWidget {
  final String email;
  const ResetPassword({super.key, required this.email});

  @override
  State<ResetPassword> createState() => _ResetPassword();
}

class _ResetPassword extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  Future? _resetPassword;
  TextEditingController emailController = TextEditingController();
  TextEditingController resetCodeController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Reset Password"),
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
                      keyboardType: TextInputType.emailAddress,
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
                    const SizedBox(height: 15),
                    TextFormField(
                      maxLines: 10,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.key),
                        labelText: 'Reset Code',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Reset code cannot be be empty.';
                        }
                        return null;
                      },
                      controller: resetCodeController,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.lock),
                        labelText: 'New Password',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be be empty.';
                        }
                        return null;
                      },
                      obscureText: true,
                      controller: newPasswordController,
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
                            _resetPassword = resetPassword(
                                emailController.text,
                                resetCodeController.text,
                                newPasswordController.text);
                          });
                        }
                      },
                      child: const Text('Reset Password',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    if (_resetPassword != null) buildFutureBuilder(),
                    const SizedBox(
                      height: 20,
                    ),
                    if (_resetPassword != null)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Login()),
                          );
                        },
                        child: const Text('Go to Login'),
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
      future: _resetPassword,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const Text("Password reset successful.");
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}

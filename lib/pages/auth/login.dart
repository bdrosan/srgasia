import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srgasia/pages/auth/forgot_password.dart';
import 'package:srgasia/pages/welcome.dart';

Future<LoginData> createLogin(String email, String password) async {
  final response = await http.post(
    Uri.parse('https://snspdev02.srgasia.com.my/sca_api/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email.trim(),
      'password': password.trim(),
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 response,
    // then parse the JSON.
    return LoginData.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 response,
    // then throw an exception.
    throw Exception('Failed to create Login.');
  }
}

class LoginData {
  final String accessToken;

  const LoginData({required this.accessToken});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'accessToken': String accessToken} => LoginData(
          accessToken: accessToken,
        ),
      _ => throw const FormatException('Failed to load LoginData.'),
    };
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _LoginState extends State<Login> {
  //create a unique form key for login form
  final _formKey = GlobalKey<FormState>();
  Future<LoginData>? _loginData;
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> _saveToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const Welcome(),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(
            'assets/images/login-bg.jpeg',
          ),
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 180,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello!',
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  Text('Let\'s get started.', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
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
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.lock),
                        labelText: 'Password',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be be empty.';
                        }
                        return null;
                      },
                      obscureText: true,
                      controller: passwordController,
                    ),
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
                        // If the form is valid, display a snackbar. In the real world,
                        // you'd often call a server or save the information in a database.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logging in..')),
                        );
                        setState(() {
                          _loginData = createLogin(
                              emailController.text, passwordController.text);
                        });
                      }
                    },
                    child: const Text('Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _loginData == null ? const Text('') : buildFutureBuilder(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPassword()),
                      );
                    },
                    child: const Text('Forgot Password'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder<LoginData> buildFutureBuilder() {
    return FutureBuilder<LoginData>(
      future: _loginData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _saveToken(snapshot.data!.accessToken);
          //return Text(snapshot.data!.accessToken);
          return const Text("Login Success");
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srgasia/pages/auth/login.dart';

class User {
  final String testtitle;

  const User({required this.testtitle});

  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'testtitle': String testtitle} => User(
          testtitle: testtitle,
        ),
      _ => throw const FormatException('Failed to load User.'),
    };
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String accessToken = "";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<User>? _getUser;
  Future? _getDashboardImage;
  @override
  initState() {
    super.initState();
    _getAccessToken();
  }

  Future<void> _getAccessToken() async {
    SharedPreferences prefs = await _prefs;
    setState(() {
      accessToken = prefs.getString('accessToken') ?? "";
    });
    if (accessToken == "") {
      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const Login(),
        ),
      );
    } else {
      setState(() {
        _getUser = getUser();
        _getDashboardImage = getDashboardImage();
      });
    }
  }

  Future<User> getUser() async {
    final response = await http.get(
      Uri.parse('https://snspdev02.srgasia.com.my/sca_api/api/testdatas/1'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 response,
      // then parse the JSON.
      return User.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized access, please login again');
    } else {
      // If the server did not return a 200 response,
      // then throw an exception.
      throw Exception('Failed to get data.');
    }
  }

  getDashboardImage() async {
    final response = await http.get(
      Uri.parse(
          'https://snspdev02.srgasia.com.my/sca_api/api/GetDashboardImg/Db2'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 response,
      // then parse the JSON.
      return Image.memory(response.bodyBytes);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized access, please login again');
    } else {
      // If the server did not return a 200 response,
      // then throw an exception.
      throw Exception('Failed to get data.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
            title: const Text("Dashboard"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                //Center(child: buildFutureBuilder()),
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: dashboardImage(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      SharedPreferences prefs = await _prefs;
                      prefs.remove('accessToken');
                      setState(() {
                        accessToken = "";
                      });
                      Navigator.pushReplacement<void, void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const Login(),
                        ),
                      );
                    },
                    child: const Text("Logout")),
              ],
            ),
          )),
    );
  }

  FutureBuilder<User> buildFutureBuilder() {
    return FutureBuilder<User>(
      future: _getUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text("Hello ${snapshot.data!.testtitle}");
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }

  FutureBuilder dashboardImage() {
    return FutureBuilder(
      future: _getDashboardImage,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}

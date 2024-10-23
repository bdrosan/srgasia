import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srgasia/pages/auth/login.dart';
import 'package:srgasia/pages/dashboard.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  String accessToken = "";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future? _getUser;
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
      });
    }
  }

  Future getUser() async {
    final response = await http.get(
      Uri.parse(
          'https://snspdev02.srgasia.com.my/sca_api/api/GetUserProfile/Pf'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 response,
      // then parse the JSON.
      return response.body;
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
            title: const Text(
              "SRG ASIA PACIFIC",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            flexibleSpace: const Image(
              image: AssetImage('assets/images/header.jpg'),
              fit: BoxFit.fill,
            ),
          ),
          body: Stack(children: <Widget>[
            Positioned.fill(
              child: Image.asset(
                "assets/images/footer.jpg",
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomLeft,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Row(
                      children: [
                        Text(
                          "Welcome",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Center(child: buildFutureBuilder()),
                  const SizedBox(height: 120),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              const Color.fromARGB(255, 18, 56, 116)),
                          fixedSize:
                              WidgetStateProperty.all(const Size(250, 60))),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Dashboard())),
                      child: const Text(
                        'Dashboard',
                        style: TextStyle(color: Colors.white),
                      )),
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
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 18.0),
                    child: Text(
                      '-- CLIENT ACCESS --',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ));
  }

  FutureBuilder buildFutureBuilder() {
    return FutureBuilder(
      future: _getUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == 'Maxis') {
            return Image.network(
                'https://www.srgasia.com.my/idash/images/maxis-logo.png');
          } else if (snapshot.data == 'Astro') {
            return Image.network(
                'https://www.srgasia.com.my/idash/images/astro-logo.png');
          } else {
            return Text(snapshot.data);
          }
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}

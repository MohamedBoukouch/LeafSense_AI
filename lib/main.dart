import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greendoctor/widgets/CustomAlert.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greendoctor/views/homeView.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoadingPage(),
    );
  }
}

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _isEmailStored = false;
  bool _isLoading = false;
  String? _ipAddress;

  @override
  void initState() {
    super.initState();
    _checkEmail();
  }

  Future<void> _getIPAddress() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.address.contains('.')) {
            setState(() {
              _ipAddress = addr.address;
            });
            return;
          }
        }
      }
    } catch (e) {
      print("Failed to get IP address: $e");
    }
  }

  Future<void> _checkEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    if (email != null) {
      setState(() {
        _isEmailStored = true;
      });
      _navigateToHome();
    } else {
      await _getIPAddress();
    }
  }

  Future<void> _sendEmail() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://ashnoune.000webhostapp.com/login.php'),
      body: {'email': _ipAddress ?? 'unknown'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', _ipAddress ?? 'unknown');
        _navigateToHome();
      } else {
        // Handle error if the status is not success
                  CustomAlert.show(
            context: context,
            type: AlertType.error,
            desc: 'Try Again',
            onPressed: () {
              Navigator.pop(context);
            }
          );
      }
    } else {
      // Handle error if the response code is not 200
      print('Server error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 5));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/logo.png"),
              Text(
                "LeafSense AI",
                style: TextStyle(fontFamily: 'Bitter', fontSize: 30, color: Colors.green),
              ),
              if (_isEmailStored)
                CircularProgressIndicator(color: Colors.orange),
              const Spacer(),
              if (!_isEmailStored)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 90.0, vertical: 20.0),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.orange)
                      : InkWell(
                          onTap: () async {
                            await _sendEmail();
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(219, 158, 158, 158).withOpacity(0.5),
                                  spreadRadius: 3,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "commencer",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Bitter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnotherPage extends StatefulWidget {
  const AnotherPage({super.key});

  @override
  _AnotherPageState createState() => _AnotherPageState();
}

class _AnotherPageState extends State<AnotherPage> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 5));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );
  }
}

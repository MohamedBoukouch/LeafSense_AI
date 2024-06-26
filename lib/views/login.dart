import 'package:flutter/material.dart';
import 'package:greendoctor/config/app_theme.dart';
import 'package:greendoctor/views/homeView.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendEmail() async {
    final response = await http.post(
      Uri.parse('https://ashnoune.000webhostapp.com/login.php'),
      body: {
        'email': _emailController.text,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        // Assuming user ID is returned in the response. If not, adjust accordingly.
        // final String userId = _emailController.text; // Replace this with actual user ID if available in response.
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', _emailController.text);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeView()),
        );
      } else {
        // Handle failure (e.g., show an error message)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email: ${responseData['email']}')),
        );
      }
    } else {
      // Handle error (e.g., show an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.only(right: 20, left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              TextFormField(
                enabled: true,
                controller: _emailController,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintStyle: const TextStyle(color: Color(0xFF555353), fontFamily: 'Bitter'),
                  labelStyle: const TextStyle(color: Colors.black),
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  disabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 3,
                      color: Color.fromARGB(132, 255, 153, 0),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 3,
                      color: Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      width: 2,
                      color: Colors.green,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _sendEmail,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green,
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
                      "Envoyer",
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
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Histourique extends StatefulWidget {
  final String porsontage;
  final String result;
  final String file;

  Histourique({
    super.key,
    required this.file,
    required this.porsontage,
    required this.result,
  });

  @override
  State<Histourique> createState() => _HistouriqueState();
}

class _HistouriqueState extends State<Histourique> {
  late Future<Map<String, dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchData(widget.result);
  }

  Future<Map<String, dynamic>> fetchData(String maladie) async {
    final response = await http.post(
      Uri.parse('https://ashnoune.000webhostapp.com/selectinfo.php'),
      body: {'maladie': maladie},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        return jsonResponse['data'][0];
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Histourique",
          style: TextStyle(
            fontFamily: 'Bitter',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: FutureBuilder<Map<String, dynamic>>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No data available'));
            } else {
              final data = snapshot.data!;
              return ListView(
                children: [
                  Image.network(
                    "https://ashnoune.000webhostapp.com/upload/${widget.file}",
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.result,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.orange,
                            fontFamily: 'Bitter',
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Text(
                        widget.porsontage,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.green,
                          fontFamily: 'Bitter',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    data['generalite'],
                    style: TextStyle(fontFamily: 'Bitter'),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Symptoms:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Bitter',
                      color: const Color.fromARGB(255, 241, 121, 112),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 30),
                  Text(
                    data['symptomes'],
                    style: TextStyle(fontFamily: 'Bitter'),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Protection:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Bitter',
                      color: Color.fromARGB(255, 144, 241, 147),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 30),
                  Text(
                    data['protection'],
                    style: TextStyle(fontFamily: 'Bitter'),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 30),
                  Text(
                    'N.B:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Bitter',
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Cette application ne doit pas être utilisée comme seul outil de diagnostic. Il est recommandé de l'utiliser en complément d'autres méthodes de diagnostic et avec l'aide d'un phytosanitaire.",
                    style: TextStyle(
                      fontFamily: 'Bitter',
                      color: Color.fromARGB(255, 231, 122, 122),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

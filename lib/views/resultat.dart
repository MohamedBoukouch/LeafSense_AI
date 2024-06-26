import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greendoctor/controller/controller.dart';
import 'package:greendoctor/widgets/CustomAlert.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

class Resultat extends StatefulWidget {
  final String path;
  final File file;

  Resultat({Key? key, required this.path, required this.file}) : super(key: key);

  @override
  State<Resultat> createState() => _ResultatState();
}

class _ResultatState extends State<Resultat> {
  late String result;
  late String percentage;
  bool isLoading = true;
  String error = '';
  late File _imageFile;
  Map<String, dynamic>? apiData;

  @override
  void initState() {
    super.initState();
    _imageFile = widget.file;
    // Call fetchResult when the widget is initialized
    fetchResult();
  }

  Future<void> fetchResult() async {
    Controller controller = Controller();
    try {
      // Fetch the eventId using the selected image file
      String eventId = await controller.getEventId("https://ashnoune.000webhostapp.com/upload/${widget.path}");
      // Fetch the result using the eventId
      String fetchedResult = await controller.getResultat(eventId);
      
      // Split result and percentage
      setState(() {
        result = fetchedResult.split(': ').first;
        percentage = fetchedResult.split(': ').last;
        sendResultToApi(fetchedResult);
      });

      // Fetch the additional data from the API using the result as the parameter
      await fetchData(result);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error fetching result: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchData(String maladie) async {
    final response = await http.post(
      Uri.parse('https://ashnoune.000webhostapp.com/selectinfo.php'),
      body: {'maladie': maladie},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        setState(() {
          apiData = jsonResponse['data'][0];
        });
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> sendResultToApi(String result) async {
    final url = Uri.parse('https://ashnoune.000webhostapp.com/updateResultat.php');
    final response = await http.post(
      url,
      body: {
        'resultat':  result,
        'imagepath': widget.path,
      },
    );

    if (response.statusCode == 200) {
      print('Result sent to API successfully');
    } else {
      print('Failed to send result to API: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Résultat",
          style: TextStyle(fontFamily: 'Bitter', fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    // Print the image path if needed
                    print(widget.path);
                    print(result);
                  },
                  child: Image.file(_imageFile),
                ),
                SizedBox(height: 20),
                // Render different states based on isLoading, error, apiData
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (error.isNotEmpty)
                  CustomAlert.show(
                    context: context,
                    type: AlertType.error,
                    desc: error,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                else if (apiData != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            result,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.orange,
                              fontFamily: 'Bitter',
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Spacer(),
                          Text(
                            percentage,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.green,
                              fontFamily: 'Bitter',
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        apiData!['generalite'],
                        style: TextStyle(fontFamily: 'Bitter'),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Symptômes",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Bitter',
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        apiData!['symptomes'],
                        style: TextStyle(fontFamily: 'Bitter'),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Protection",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Bitter',
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        apiData!['protection'],
                        style: TextStyle(fontFamily: 'Bitter'),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Note Biens:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Bitter',
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Cette application ne doit pas être utilisée comme seul outil de diagnostic. Il est recommandé de l'utiliser en complément d'autres méthodes de diagnostic et avec l'aide d'un phytosanitaire.",
                        style: TextStyle(
                          fontFamily: 'Bitter',
                          color: const Color.fromARGB(255, 231, 122, 122),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

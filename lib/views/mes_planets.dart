import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greendoctor/views/histourique.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyPlanete extends StatefulWidget {
  const MyPlanete({super.key});

  @override
  State<MyPlanete> createState() => _MyPlaneteState();
}

class _MyPlaneteState extends State<MyPlanete> {
  late Future<List<dynamic>> futureHistorique;

  @override
  void initState() {
    super.initState();
    futureHistorique = fetchHistorique();
  }

Future<List<dynamic>> fetchHistorique() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? idUser = prefs.getString('email'); // Assuming the email is used as the user ID

  final uri = Uri.parse('https://ashnoune.000webhostapp.com/fetchHistourique.php');
  final response = await http.post(
    uri,
    body: {'id_user': idUser ?? 'unknown'},
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == 'success') {
      return jsonResponse['data'];
    } else {
      throw Exception('Failed to load historique');
    }
  } else {
    throw Exception('Failed to load historique');
  }
}


  Future<void> deletePlanete(String id) async {
    final response = await http.post(
      Uri.parse('https://ashnoune.000webhostapp.com/deletePlanete.php'),
      body: {'id_planete': id},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        setState(() {
          futureHistorique = fetchHistorique(); // Refresh the list after deletion
        });
      } else {
        throw Exception('Failed to delete planete');
      }
    } else {
      throw Exception('Failed to delete planete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Mes Plantes', style: TextStyle(fontFamily: 'Bitter', fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureHistorique,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Image.asset("assets/empty_data.jpg", height: 200));
          } else {
            final historiqueList = snapshot.data!;
            return ListView.builder(
              itemCount: historiqueList.length,
              itemBuilder: (context, index) {
                final historique = historiqueList[index];
                final id = historique['id'].toString();
                final image = historique['image'];
                final resultat = historique['resultat'] == null ? "Null" : historique['resultat'].split(': ').first;
                final percentage = historique['resultat'] == null ? 'null' : historique['resultat'].split(': ').last;

                return Dismissible(
                  key: Key(id),
                  direction: DismissDirection.startToEnd,
                  background: Card(
                    color: Colors.red,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    deletePlanete(id);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 7),
                    color: Colors.grey[200],
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Histourique(
                              file: image,
                              porsontage: percentage,
                              result: resultat,
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(
                          resultat,
                          style: TextStyle(fontWeight: FontWeight.w200, fontFamily: 'Bitter'),
                        ),
                        leading: Text(
                          percentage,
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Bitter'),
                        ),
                        trailing: CircleAvatar(
                          backgroundImage: NetworkImage("https://ashnoune.000webhostapp.com/upload/$image"),
                          radius: 30, // You can adjust the radius as needed
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeudView extends StatelessWidget {
  const GeudView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Instruction",style: TextStyle(fontFamily: 'Bitter', fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(right: 20.0,left: 20,top: 20,bottom: 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Comment utiliser LeafSense AI",
                style: TextStyle(fontFamily: 'Bitter', fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Pour identifier une plante, prenez simplement une photo ou sélectionnez une photo de plante dans vos Photos et LeafSense AI l'identifiera",
                style: TextStyle(fontFamily: 'Bitter'),
              ),
              SizedBox(height: 8),
              Text(
                "Conseils pour prendre des photos :",
                style: TextStyle(fontFamily: 'Bitter', fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Une photo nette des plantes avec un angle et une distance appropriés aidera PictureThis à identifier les plantes avec plus de précision.",
                style: TextStyle(fontFamily: 'Bitter'),
              ),
              SizedBox(height: 20),
              Text(
                "1. Centrez la plante au milieu du cadre, évitez les images sombres ou floues",
                style: TextStyle(fontFamily: 'Bitter', fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Image.asset("assets/img1.jpeg"),
              SizedBox(height: 20),
              Text(
                "2. Si la plante est trop grande pour le cadre, assurez-vous d'inclure les feuilles ou la fleur de la plante.",
                style: TextStyle(fontFamily: 'Bitter', fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Image.asset("assets/img2.jpeg"),
              SizedBox(height: 20),
              Text(
                "3. Evitez de trop vous approcher, assurez-vous que la feuille ou la fleur soit nette et entière",
                style: TextStyle(fontFamily: 'Bitter', fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Image.asset("assets/img3.jpeg"),
              SizedBox(height: 20),
              Text(
                "4. Focalisez-vous sur la fleur si votre plante contient des fleurs.",
                style: TextStyle(fontFamily: 'Bitter', fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Image.asset("assets/img4.jpeg"),
              SizedBox(height: 20),
              Text(
                "5. Incluez seulement une espèce à la fois",
                style: TextStyle(fontFamily: 'Bitter', fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () async{
                          SharedPreferences prefs = await SharedPreferences.getInstance();

                  print(prefs.getString('user_id'));
                },
                child: Image.asset("assets/img5.jpeg")),
              SizedBox(height: 20),
              Text(
                "A partir de vos données de localisation, LeafSense AI peux vous donner un résultat d'identification plus précis.",
                style: TextStyle(fontFamily: 'Bitter'),
              ),
              SizedBox(height: 20),
              
            ],
          ),
        ),
      ),
    );
  }
}

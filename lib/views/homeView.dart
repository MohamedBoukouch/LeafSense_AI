import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greendoctor/views/geud.dart';
import 'package:greendoctor/widgets/circle_nav_bar.dart';
import 'package:greendoctor/views/mes_planets.dart';
import 'package:greendoctor/views/take_image.dart';
import 'package:image_picker/image_picker.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  int _tabIndex = 1;
  int get tabIndex => _tabIndex;
  set tabIndex(int v) {
    _tabIndex = v;
    setState(() {});
  }

  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  File? _imageFile;

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Navigate to TakePicture screen with selected image
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TakePicture(file: _imageFile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("leafSense AI",style: TextStyle(fontFamily: 'Fontspring'),)),
      extendBody: true,
      bottomNavigationBar: CircleNavBar(
        activeIcons: [
          Icon(Icons.home, color: Colors.orange),
          Icon(Icons.camera_alt, color: Colors.orange),
          Icon(Icons.eco, color: Colors.orange),
        ],
        inactiveIcons: const [
          Text("Accueil"),
          Text("Photo"),
          Text("Mes plantes"),
        ],
        color: Colors.white,
        height: 60,
        circleWidth: 60,
        activeIndex: tabIndex,
        onTap: (index) {
          tabIndex = index;
          pageController.jumpToPage(tabIndex);
        },
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        shadowColor: Colors.deepPurple,
        elevation: 10,
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (v) {
          tabIndex = v;
        },
        children: [
          GeudView(),

          ///////////////////////

          // AlertDialog to choose camera or gallery
          AlertDialog(
            shadowColor: Colors.orange,
            backgroundColor: const Color.fromARGB(255, 226, 224, 224),
            title: Text('Choisissez une option'),
            content: Text('Vous souhaitez prendre une nouvelle photo ou en sélectionner une dans votre galerie ?'),
            actions: [
              TextButton(
                onPressed: () {
                  _getImage(ImageSource.camera);
                },
                child: Text('Camera'),
              ),
              TextButton(
                onPressed: () {
                  _getImage(ImageSource.gallery);
                },
                child: Text('Gallery'),
              ),
            ],
          ),

          //////////////////////////

          MyPlanete(),
        ],
      ),
    );
  }
}

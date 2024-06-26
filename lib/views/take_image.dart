import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greendoctor/controller/controller.dart';
import 'package:greendoctor/views/resultat.dart';
import 'package:greendoctor/widgets/CustomAlert.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TakePicture extends StatefulWidget {
  final File? file;

  const TakePicture({Key? key, this.file}) : super(key: key);

  @override
  _TakePictureState createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {
  late File _imageFile;
  late String result;
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    if (widget.file != null) {
      _imageFile = widget.file!;
      fetchResult();
    } else {
      setState(() {
        isLoading = false;
        error = 'No image selected';
      });
    }
  }

  Future<void> fetchResult() async {
    Controller controller = Controller();
    try {
      // Fetch the eventId using the selected image file
      String eventId = await controller.getEventId("https://ashnoune.000webhostapp.com/public/images/1719017428.jpg");
      // Fetch the result using the eventId
      String fetchedResult = await controller.getResultat(eventId);
      setState(() {
        result = fetchedResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error fetching result: $e';
        isLoading = false;
      });
    }
  }

  Future<void> sendImageToDatabase() async {
       SharedPreferences prefs = await SharedPreferences.getInstance();
      
      
      // if (userId == null) {
      //   setState(() {
      //     error = 'User ID not found in SharedPreferences';
      //     isLoading = false;
      //   });
      //   return;
      // }
    setState(() {
      isLoading = true;
    });

    try {
      var stream = http.ByteStream(DelegatingStream.typed(_imageFile.openRead()));
      var length = await _imageFile.length();
      var uri = Uri.parse("https://ashnoune.000webhostapp.com/uploadimage.php");

      var request = http.MultipartRequest("POST", uri);
      var multipartFile = http.MultipartFile('image[]', stream, length, filename: path.basename(_imageFile.path));

      request.files.add(multipartFile);
      request.fields['user_id'] = "${prefs.getString('email')}";

      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        var responseData = json.decode(responseBody.body);
        if (responseData['status'] == 'success') {
          CustomAlert.show(
            context: context,
            type: AlertType.success,
            desc: 'Image uploaded successfully!',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Resultat(path: path.basename(_imageFile.path), file: _imageFile)),
              );
            }
          );
          setState(() {
            result = "Image successfully uploaded!";
            isLoading = false;
          });
        } else {
          setState(() {
            error = "Failed to upload image. Status: ${responseData['status']}";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = "Failed to upload image. Status code: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error uploading image: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Take Picture',
          style: TextStyle(fontFamily: 'Bitter', fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_imageFile != null)
                      Center(
                        child: Container(
                          height: 400,
                          width: 400,
                          child: InkWell(
                            onTap: () {
                              print(path.basename(_imageFile.path));
                            },
                            child: Image.file(
                              _imageFile,
                              height: 400,
                              width: 400,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    if (_imageFile == null)
                      Center(
                        child: Text('No image selected'),
                      ),
                    if (isLoading)
                      Center(
                        child: CircularProgressIndicator(), // Loading indicator
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 186, 181),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Bitter'),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: sendImageToDatabase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 184, 247, 187),
                      ),
                      child: Text(
                        'Envoyer',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Bitter'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

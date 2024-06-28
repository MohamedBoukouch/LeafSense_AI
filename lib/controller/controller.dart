import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Controller {

  Future<String> getResultat(String eventId) async {
    var url = Uri.parse("https://khadijaasehnoune12-orange-disease-classifier.hf.space/call/predict/$eventId");

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json', // Set content type to JSON
      },
    );

    if (response.statusCode == 200) {
      // Assuming the response is a text/event-stream
      List<String> lines = response.body.split('\n');
      for (String line in lines) {
        if (line.startsWith('data: ')) {
          String data = line.substring(6); // Remove 'data: ' prefix
          return jsonDecode(data)[0]; // Decode the JSON and return the first element
        }
      }
      throw Exception('Data not found in response');
    } else {
      throw Exception('Failed to fetch data');
    }
  }

    sendImage(File? _selectedImage,dynamic context) async {
    final uri = Uri.parse("https://ashnoune.000webhostapp.com/uploadimage.php");
    var request = http.MultipartRequest('POST', uri);
    // request.fields['user_id'] = "${sharedpref.getString("id")}";
    var pic =
        await http.MultipartFile.fromPath("image", _selectedImage!.path);
    request.files.add(pic);

    if (_selectedImage != null) {
      var pic =
          await http.MultipartFile.fromPath("image", _selectedImage!.path);
      request.files.add(pic);
    }
    try {
      var response = await request.send();
      if (response.statusCode == 200) {

        Navigator.pop(context);

        print("Image upload successful");
      } else {
        print("Error in uploading image. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error sending image request: $error");
    }

    Get.back();
  }
}

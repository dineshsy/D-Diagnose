import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:image/image.dart' as img;

class ImageTaker extends StatefulWidget {
  @override
  _ImageTakerState createState() => _ImageTakerState();
}

class _ImageTakerState extends State<ImageTaker> {
  var isLoaded = true;
  bool switchControl = false;
  File _image;
  int index = 0;
  var type = [ImageSource.camera, ImageSource.gallery];
  List post;
  String res;
  bool showRes = false;
  var recognitions;
  img.Image thumbnail;
  String result = '';

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: type[index]);
    setState(() {
      _image = image;
    });

    await imageUploadHelper(_image);
  }

  String url;

  Future imageUploadHelper(File image) async {
    if (image != null) {
      res = await Tflite.loadModel(
          model:
              "assets/tflite/output.tflite", //***** THIS TFLITE FILE GREATER THAN 100 MB UNABLE TO UPLOAD ON GITHUB *****
          labels: "assets/tflite/labels.txt",
          numThreads: 1 // defaults to 1
          );

      if (res == "success") {
        recognitions = await Tflite.runModelOnImage(
            path: _image.path, // required
            imageMean: 0.0, // defaults to 117.0
            imageStd: 255.0, // defaults to 1.0
            numResults: 2, // defaults to 5
            threshold: 0.2, // defaults to 0.1
            asynch: true // defaults to true
            );
      }
    }

    print(recognitions.toString());
    print('hi da deep');
    print(res);
  }

  void toggleSwitch(bool value) {
    if (switchControl == false) {
      setState(() {
        switchControl = true;
      });

      // Put your code here which you want to execute on Switch ON event.
      setState(() {
        index = 1;
      });
    } else {
      setState(() {
        switchControl = false;
      });
      setState(() {
        index = 0;
      });
      // Put your code here which you want to execute on Switch OFF event.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: _image == null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Please select an image.',
                        style: TextStyle(fontSize: 8),
                      ),
                    )
                  : Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 250,
                            width: 256,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                    image: FileImage(_image),
                                    fit: BoxFit.fill)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: RaisedButton(
                            onPressed: () {
                              if (recognitions.toString() != 'null') {
                                setState(() {
                                  int flag = 0;
                                  for (var rec in recognitions) {
                                    print((rec['confidence'] as double));
                                    if ((rec['confidence'] as double) > 0.4) {
                                      flag = 1;
                                      break;
                                    }
                                  }
                                  if (0 == flag) {
                                    result = 'Please try again';
                                  } else {
                                    result = recognitions.toString();
                                  }
                                  showRes = true;
                                });
                              }
                            },
                            child: Text(
                              "Results",
                              style:
                                  TextStyle(fontSize: 15, letterSpacing: 1.5),
                            ),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: BorderSide(color: Colors.blue)),
                          ),
                        ),
                        showRes
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 250,
                                  width: 256,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.cyan,
                                  ),
                                  child: result == 'Please try again'
                                      ? Center(child: Text('$result'))
                                      : resultBuilder(),
                                ),
                              )
                            : SizedBox(
                                width: 0,
                                height: 0,
                              )
                      ],
                    ),
            ),
          ),
         
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: <Widget>[
                Text(
                  "Toggle to choose image from gallery",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.0),
                ),
                Switch(
                  onChanged: toggleSwitch,
                  value: switchControl,
                  activeColor: Colors.blue,
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget resultBuilder() {
    String _result = '';
    for (var rec in recognitions) {
      double _double = ((rec['confidence'] * 1000));
      int _int = _double.toInt();
      _double = (_int) / 1000.0;

      _result += _double.toString() + '\t' + rec['label'] + '\n';
    }
    return Text(_result);
  }
}

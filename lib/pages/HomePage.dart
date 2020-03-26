import 'package:flutter/material.dart';
import 'package:plant_disease_prophecy/pages/ImageTaker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      centerTitle: true,
      title: Text('D Diagnose',style: TextStyle(letterSpacing: 2.0),),
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.red, Colors.blue])),
      ),
    ),
    body: ImageTaker(),
    );
  }
}

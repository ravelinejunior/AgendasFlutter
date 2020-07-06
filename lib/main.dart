import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: "Agenda",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.all(Radius.circular(100))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber),
              borderRadius: BorderRadius.all(Radius.circular(100))),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

import 'package:agenda_app/ui/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MaterialApp(
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      Locale("pt"),
    ],
    title: "Agenda",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        hintColor: Colors.grey,
        primaryColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(100))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(50))),
          hintStyle: TextStyle(color: Colors.grey),
        )),
    home: HomePage(),
  ));
}

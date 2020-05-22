import 'package:flutter/material.dart';
import 'package:tudu/pages/home_page.dart';

void main()  => runApp(TuduApp());

class TuduApp extends StatelessWidget {
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tudu',
      theme: ThemeData(
        primarySwatch: Colors.teal
      ),
      home: TuduHomePage(title: 'My Tudus'),
      debugShowCheckedModeBanner: false,
    );
  }
}

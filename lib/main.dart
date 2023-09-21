import 'package:flutter/material.dart';
import 'package:new_app/RecipeSplash.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Yummilicious",
        theme: ThemeData(primarySwatch: Colors.brown),
        home: RecipeSplash(),
        debugShowCheckedModeBanner: false);
  }
}

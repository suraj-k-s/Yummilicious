import 'dart:async';
import 'package:flutter/material.dart';
import 'package:new_app/RecipeLogin.dart';
import 'package:lottie/lottie.dart';

class RecipeSplash extends StatefulWidget {
  @override
  State<RecipeSplash> createState() => _RecipeSplashState();
}

class _RecipeSplashState extends State<RecipeSplash> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const RecipeLogin(
                )),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Lottie.asset('assets/recipe.json',
              width: 300, height: 180, fit: BoxFit.fill),
        ),
      ),
    );
  }
}

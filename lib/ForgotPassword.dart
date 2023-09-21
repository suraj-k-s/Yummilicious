import 'package:flutter/material.dart';
import 'package:new_app/ResetPassword.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: BoxDecoration(
            color: Colors.brown.shade100,
            image: const DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage("assets/recipe_background1.jpg"))),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                child: Text("Reset Password",
                    style: TextStyle(
                        color: Colors.brown.shade700,
                        fontWeight: FontWeight.w800,
                        fontSize: 28)),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(5),
                child: Text("Enter your registered email address",
                    style: TextStyle(
                        color: Colors.brown.shade700,
                        fontWeight: FontWeight.w400,
                        fontSize: 14)),
              ),
              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(5),
                child: const TextField(
                  decoration: InputDecoration(
                      hintText: "Email Address",
                      hintStyle: TextStyle(color: Colors.black, fontSize: 12)),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ResetPassword()));
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.brown.shade700),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ))),
                  child: const Text(
                    "Get OTP",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ),
      )),
    );
  }
}

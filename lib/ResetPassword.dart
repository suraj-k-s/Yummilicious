import 'package:flutter/material.dart';
import 'package:new_app/RecipeLogin.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _retypePasswordController = TextEditingController();
  TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                width: 250,
                height: 80,
                child: TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                        hintText: "Enter OTP",
                        hintStyle:
                            TextStyle(color: Colors.black, fontSize: 12)))),
            Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                width: 250,
                height: 80,
                child: TextField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                        hintText: "Enter New Password",
                        hintStyle:
                            TextStyle(color: Colors.black, fontSize: 12)))),
            Container(
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                width: 250,
                height: 80,
                child: TextField(
                    controller: _retypePasswordController,
                    decoration: const InputDecoration(
                        hintText: "Retype Password",
                        hintStyle:
                            TextStyle(color: Colors.black, fontSize: 12)))),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RecipeLogin()));
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.brown.shade700),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ))),
                child: const Text(
                  "Reset Password",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      )),
    );
  }
}

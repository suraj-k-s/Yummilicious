import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditPassword extends StatefulWidget {
  const EditPassword({super.key});

  @override
  State<EditPassword> createState() => _EditPasswordState();
}

class _EditPasswordState extends State<EditPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.brown.shade100,
              image: const DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: AssetImage("assets/login_page_background.jpg"))),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                      width: 200,
                      height: 50,
                      child: TextField(
                          decoration: InputDecoration(
                              hintText: "Enter Your Current Password",
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 12)))),
                  const SizedBox(
                      width: 200,
                      height: 50,
                      child: TextField(
                          decoration: InputDecoration(
                              hintText: "Enter New Password",
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 12)))),
                  const SizedBox(
                      width: 200,
                      height: 50,
                      child: TextField(
                          decoration: InputDecoration(
                              hintText: "Retype New Password",
                              hintStyle: TextStyle(
                                  color: Colors.grey, fontSize: 12)))),
                  const SizedBox(width: 200, height: 20),
                  ElevatedButton(
                      onPressed: () {
                        Fluttertoast.showToast(
                            msg: "Password Updated",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.brown.shade700),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ))),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white),
                      )
                    )
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }
}

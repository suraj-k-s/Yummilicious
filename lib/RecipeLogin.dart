import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_app/ForgotPassword.dart';
import 'package:new_app/RecipeHome.dart';
import 'package:new_app/RecipeSignUp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeLogin extends StatefulWidget {
  const RecipeLogin({super.key});

  @override
  State<RecipeLogin> createState() => _RecipeLogin();
}

class _RecipeLogin extends State<RecipeLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginUser() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      String userid = userCredential.user!.uid;
      // Obtain shared preferences.
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // Save an String value to 'action' key.
      await prefs.setString('uid', userid);
      // Login success, do something (e.g., navigate to a new page)
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const RecipeHome()));
    } catch (e) {
      // Login failed, display an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      //resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: AssetImage("assets/login_page_background.jpg"))),
              child: Center(
                child: SingleChildScrollView(
                  child: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Log In",
                            //textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.brown.shade700,
                                fontWeight: FontWeight.w800,
                                fontSize: 34)),
                        const SizedBox(
                          width: 300,
                          height: 100,
                        ),
                        Container(
                          width: 300,
                          height: 50,
                          padding: const EdgeInsets.only(left: 5),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              border: Border.all(
                                  color: Colors.black, style: BorderStyle.solid)),
                          child: SizedBox(
                            child: TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: "Enter your email",
                                  hintStyle:
                                      TextStyle(color: Colors.black, fontSize: 12)),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 300,
                          height: 10,
                        ),
                        Container(
                          width: 300,
                          height: 50,
                          padding: const EdgeInsets.only(left: 5),
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              border: Border.all(
                                  color: Colors.black, style: BorderStyle.solid)),
                          child: SizedBox(
                            child: TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: "Enter your password",
                                  hintStyle:
                                      TextStyle(color: Colors.black, fontSize: 12)),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 300,
                          height: 20,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              loginUser();
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
                              "Login",
                              style: TextStyle(color: Colors.white),
                            )),
                        const SizedBox(
                          width: 300,
                          height: 20,
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const RecipeSignUp()));
                            },
                            child: const Text(
                              "No Account? Create One Now",
                              style: TextStyle(color: Colors.black),
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const ForgotPassword()));
                            },
                            child: const Text(
                              "Forgot Password",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontStyle: FontStyle.normal),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

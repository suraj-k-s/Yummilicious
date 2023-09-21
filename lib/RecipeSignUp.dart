import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:new_app/ImagePicker.dart';
import 'package:new_app/RecipeLogin.dart';

class RecipeSignUp extends StatefulWidget {
  const RecipeSignUp({super.key});

  @override
  State<RecipeSignUp> createState() => _RecipeSignUpState();
}

class _RecipeSignUpState extends State<RecipeSignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutinfoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypepasswordController =
      TextEditingController();
  File? selectedImage;

  Future<void> registerUser() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (selectedImage != null) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_images/${userCredential.user!.uid}');
        await storageReference.putFile(selectedImage!);
        String imageUrl = await storageReference.getDownloadURL();

        // Save additional user details to Firestore, including the image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': userCredential.user!.email,
          'image_url': imageUrl,
          'name': _nameController.text,
          'about_info': _aboutinfoController.text,
          'phone': _phoneController.text,
        });
      } else {
        // Save additional user details to Firestore without the image URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': userCredential.user!.email,
          'name': _nameController.text,
          'about_info': _aboutinfoController.text,
          'phone': _phoneController.text,
        });
      }
      // ignore: use_build_context_synchronously
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const RecipeLogin()));

      // Registration success, do something (e.g., navigate to a new page)
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Registration Failed'),
              content: const Text("The password provided is too weak."),
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
      } else if (e.code == 'email-already-in-use') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Registration Failed'),
              content: const Text("The account already exists for that email."),
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
    } catch (e) {
      // Registration failed, display an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Registration Failed'),
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
        body: SafeArea(
      child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/login_page_background.jpg"))),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(children: [
                    selectedImage != null
                        ? Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(5),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(selectedImage!),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(5),
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage('assets/person.jpg'),
                            ),
                          ),
                    Positioned(
                      right: 15,
                      bottom: 15,
                      child: IconButton(
                          onPressed: () async {
                            final pickedImage = await pickImageC();
                            setState(() {
                              selectedImage = pickedImage;
                            });
                          },
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 30,
                          )),
                    ),
                  ]),
                  Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      width: 250,
                      height: 80,
                      child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                              hintText: "Enter Your Name",
                              hintStyle: TextStyle(
                                  color: Colors.black, fontSize: 12)))),
                  Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      width: 250,
                      height: 80,
                      child: TextField(
                          controller: _aboutinfoController,
                          decoration: const InputDecoration(
                              hintText: "Enter Your About Info",
                              hintStyle: TextStyle(
                                  color: Colors.black, fontSize: 12)))),
                  Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      width: 250,
                      height: 80,
                      child: TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                              hintText: "Enter Your Phone",
                              hintStyle: TextStyle(
                                  color: Colors.black, fontSize: 12)))),
                  Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      width: 250,
                      height: 80,
                      child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                              hintText: "Enter Your Email",
                              hintStyle: TextStyle(
                                  color: Colors.black, fontSize: 12)))),
                  Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      width: 250,
                      height: 80,
                      child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              hintText: "Enter Your Password",
                              hintStyle: TextStyle(
                                  color: Colors.black, fontSize: 12)))),
                  Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(5),
                      width: 250,
                      height: 80,
                      child: TextField(
                          controller: _retypepasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              hintText: "Retype Password",
                              hintStyle: TextStyle(
                                  color: Colors.black, fontSize: 12)))),
                  ElevatedButton(
                      onPressed: () {
                        if (_passwordController.text ==
                            _retypepasswordController.text) {
                          registerUser();
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Registration Failed'),
                                content: const Text("Passwords does not match"),
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
                        "Sign Up",
                        style: TextStyle(color: Colors.white),
                      ))
                ]),
          ),
        ),
      ),
    ));
  }
}

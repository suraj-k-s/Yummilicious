import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_app/EditPassword.dart';
import 'package:new_app/ImagePicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String loginUserId = "";
  String userName = "";
  String userAboutInfo = "";
  String userProfilePic = "";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? selectedProfileImage;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  void getUserDetails() async {
    // Get user's profile info
    final prefs = await SharedPreferences.getInstance();
    loginUserId = (prefs.getString('uid') ?? "");
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(loginUserId)
        .get();
    Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;
    _nameController.text = userData!['name'];
    _aboutController.text = userData['about_info'];
    _phoneController.text = userData['phone'];
    userProfilePic = userData['image_url'];
    _passwordController.text = 'qwerty';

    // Get the user's authentication details
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Retrieve the email and phone number from the user object
      _emailController.text = user.email!;
    }
    setState(() {});
  }

  Future<void> updateUserProfile() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          width: 500,
          decoration: const BoxDecoration(
              color: Color.fromARGB(255, 215, 200, 214),
              image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: AssetImage("assets/login_page_background.jpg"))),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 40.0),
                child: Column(children: [
                  Stack(children: [
                    selectedProfileImage == null
                        ? Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(5),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(userProfilePic),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(5),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(selectedProfileImage!),
                            ),
                          ),
                    Positioned(
                      right: 15,
                      bottom: 15,
                      child: IconButton(
                          onPressed: () async {
                            final pickedIamge = await pickImageC();
                            selectedProfileImage = pickedIamge;
                            setState(() {});
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
                      )),
                  Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      width: 250,
                      height: 80,
                      child: TextField(
                        controller: _aboutController,
                      )),
                  Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      width: 250,
                      height: 80,
                      child: TextField(
                        controller: _phoneController,
                      )),
                  Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      width: 250,
                      height: 80,
                      child: TextField(
                        controller: _emailController,
                      )),
                  Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      width: 250,
                      height: 80,
                      child: TextField(
                        onTap: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditPassword()))
                        },
                        readOnly: true,
                        decoration: const InputDecoration(
                            suffixIcon: Icon(
                          Icons.keyboard_arrow_right,
                          size: 30,
                        )),
                        obscureText: true,
                        controller: _passwordController,
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Fluttertoast.showToast(
                            msg: "Profile Updated",
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
                      )),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

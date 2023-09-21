import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/CreateRecipe.dart';
import 'package:new_app/EditProfile.dart';
import 'package:new_app/Favourites.dart';
import 'package:new_app/FollowersList.dart';
import 'package:new_app/FollowingList.dart';
import 'package:new_app/Notifications.dart';
import 'package:new_app/RecipeFriends.dart';
import 'package:new_app/RecipeHome.dart';
import 'package:new_app/RecipeLogin.dart';
import 'package:new_app/RecipeView.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String uid = "";
  String recipeId = "";
  String userName = "";
  String userAboutInfo = "";
  String userProfilePic = "";
  String recipeName = "";
  String recipeTime = "";
  String recipeImage = "";
  int followersCount = 0;
  int followingCount = 0;
  List<String> userRecipeNameList = [];
  List<String> userRecipeTimeList = [];
  List<String> userRecipeImageList = [];
  List<String> userRecipeIdList = [];
  Map<String, dynamic> recipeDetails = {};

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  void getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    uid = (prefs.getString('uid') ?? "");

    // get user details
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;
    userName = userData!['name'];
    userAboutInfo = userData['about_info'];
    userProfilePic = userData['image_url'];

    // get user's recipe details
    QuerySnapshot recipeQuerySnapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .where('user_id', isEqualTo: uid)
        .get();
    if (recipeQuerySnapshot != null) {
      for (QueryDocumentSnapshot recipeDocumentSnapshot
          in recipeQuerySnapshot.docs) {
        Map<String, dynamic> data =
            (recipeDocumentSnapshot.data() as Map<String, dynamic>);
        userRecipeNameList.add(data['recipe_name']);
        userRecipeTimeList.add(data['time']);
        userRecipeImageList.add(data['recipe_image']);
        userRecipeIdList.add(recipeDocumentSnapshot.id);
      }
    }

    // get user's followers count
    QuerySnapshot followersQuerySnapshot = await FirebaseFirestore.instance
        .collection('followlist')
        .where('following_id', isEqualTo: uid)
        .get();
    if (followersQuerySnapshot != null) {
      followersCount = followersQuerySnapshot.docs.length;
    }

    // get user's following count
    QuerySnapshot followingQuerySnapshot = await FirebaseFirestore.instance
        .collection('followlist')
        .where('follower_id', isEqualTo: uid)
        .get();
    if (followingQuerySnapshot != null) {
      followingCount = followingQuerySnapshot.docs.length;
    }

    setState(() {});
  }

  Future<void> getRecipeDetails(id) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance.collection('recipes').doc(id).get();
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RecipeView(
                recipeDetails: documentSnapshot,
              )),
    );
  }

  void showLogoutConfirmationDialogue(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Logout Confirmation"),
            content: const Text("Do you want to logout?"),
            actions: <Widget>[
              TextButton(
                child:
                    const Text('Cancel'), // Customize your cancel button text
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child:
                    const Text('Logout'), // Customize your logout button text
                onPressed: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  await preferences.clear();
                  // ignore: use_build_context_synchronously
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RecipeLogin()),
                      (route) => false); // Logout from the application
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.brown.shade100,
              image: const DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/recipe_background1.jpg"))),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(children: [
                  userProfilePic != null
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
                          child: const CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage('assets/person.jpg'),
                          ),
                        ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: Text(
                      userName,
                      style: const TextStyle(
                          fontSize: 26,
                          color: Colors.black,
                          fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: Text(
                      userAboutInfo,
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                          color: Colors.white, style: BorderStyle.solid)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: Column(children: [
                            Text(userRecipeNameList.length.toString(),
                                style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500)),
                            const Text("Recipes",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black))
                          ]),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FollowersList()));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: Column(children: [
                              Text(followersCount.toString(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              const Text("Followers",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black))
                            ]),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FollowingList()));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: Column(children: [
                              Text(followingCount.toString(),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                              const Text("Following",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black))
                            ]),
                          ),
                        )
                      ]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 140,
                      height: 50,
                      margin: const EdgeInsets.only(
                          left: 10, right: 5, top: 5, bottom: 5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          border: Border.all(
                              color: Colors.white, style: BorderStyle.solid)),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditProfile()));
                        },
                        child: const Text(
                          "Edit Profile",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                      width: 140,
                      height: 50,
                      margin: const EdgeInsets.only(
                          left: 5, right: 5, top: 5, bottom: 5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          border: Border.all(
                              color: Colors.white, style: BorderStyle.solid)),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CreateRecipe()));
                        },
                        child: const Text(
                          "Create Recipe",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(
                          left: 5, right: 10, top: 5, bottom: 5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          border: Border.all(
                              color: Colors.white, style: BorderStyle.solid)),
                      child: IconButton(
                        onPressed: () {
                          showLogoutConfirmationDialogue(context);
                        },
                        icon: const Icon(Icons.logout),
                      ),
                    ),
                  ],
                ),
                Flexible(
                    child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        shrinkWrap: true,
                        itemCount: userRecipeNameList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.9,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5),
                        itemBuilder: ((BuildContext context, index) {
                          return GridTile(
                            child: InkWell(
                                onTap: () =>
                                    {getRecipeDetails(userRecipeIdList[index])},
                                child: Stack(children: [
                                  Container(
                                      width: 180,
                                      height: 220,
                                      margin: const EdgeInsets.all(5),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50)),
                                        image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(
                                                userRecipeImageList[index])),
                                      )),
                                  Positioned(
                                      left: 15,
                                      bottom: 30,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.all(5),
                                              child: Text(
                                                  userRecipeNameList[index],
                                                  style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black)),
                                            ),
                                            Row(children: [
                                              Container(
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  child: const Icon(
                                                    Icons.access_time,
                                                    weight: 10,
                                                  )),
                                              Container(
                                                margin: const EdgeInsets.all(5),
                                                child: Text(
                                                    "${userRecipeTimeList[index]} mins",
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black)),
                                              )
                                            ])
                                          ]))
                                ])),
                          );
                        }))),
                Container(
                  color: Colors.white,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RecipeHome()));
                            },
                            icon: const Icon(Icons.home_outlined),
                          ),
                          const Text("Home",
                              style:
                                  TextStyle(fontSize: 10, color: Colors.black)),
                        ]),
                        Column(children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.person_3),
                          ),
                          const Text("My Profile",
                              style:
                                  TextStyle(fontSize: 10, color: Colors.black)),
                        ]),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const RecipeFriends()));
                              },
                              icon: const Icon(Icons.group_outlined),
                            ),
                            const Text("Friends",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black)),
                          ],
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Favourites()));
                              },
                              icon: const Icon(Icons.favorite_outline),
                            ),
                            const Text("Favourites",
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black)),
                          ],
                        ),
                        Column(children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const Notifications()));
                            },
                            icon: const Icon(Icons.notifications_outlined),
                          ),
                          const Text("Notifications",
                              style:
                                  TextStyle(fontSize: 10, color: Colors.black))
                        ])
                      ]),
                )
              ]),
        ),
      ),
    ));
  }
}

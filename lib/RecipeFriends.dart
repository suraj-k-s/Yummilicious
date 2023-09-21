import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/Favourites.dart';
import 'package:new_app/MyProfile.dart';
import 'package:new_app/Notifications.dart';
import 'package:new_app/RecipeHome.dart';
import 'package:new_app/RecipeView.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeFriends extends StatefulWidget {
  const RecipeFriends({super.key});

  @override
  State<RecipeFriends> createState() => _RecipeFriendsState();
}

class _RecipeFriendsState extends State<RecipeFriends> {
  String loginUserId = "";
  List<String> friendRecipeIdList = [];
  List<String> friendRecipeNameList = [];
  List<String> friendRecipeCalorieList = [];
  List<String> friendRecipeTimeList = [];
  List<String> friendRecipeImageList = [];
  List<String> followingUserIdList = [];

  @override
  void initState() {
    super.initState();
    getFriendRecipeList();
  }

  void getFriendRecipeList() async {
    final prefs = await SharedPreferences.getInstance();
    loginUserId = (prefs.getString('uid') ?? "");
    QuerySnapshot friendsQuerySnapshot = await FirebaseFirestore.instance
        .collection('followlist')
        .where('follower_id', isEqualTo: loginUserId)
        .get();
    if (friendsQuerySnapshot != null) {
      print("helloooooooo");
      for (QueryDocumentSnapshot followingUserDocumentSnapshot
          in friendsQuerySnapshot.docs) {
        Map<String, dynamic> followingUserData =
            (followingUserDocumentSnapshot.data() as Map<String, dynamic>);
        followingUserIdList.add(followingUserData['following_id']);
        QuerySnapshot followingUserRecipeQuerySnapshot = await FirebaseFirestore
            .instance
            .collection('recipes')
            .where('user_id', isEqualTo: followingUserData['following_id'])
            .get();
        for (QueryDocumentSnapshot followingUserRecipeDocumentSnapshot
            in followingUserRecipeQuerySnapshot.docs) {
          friendRecipeIdList.add(followingUserRecipeDocumentSnapshot.id);
          Map<String, dynamic>? followingUserRecipeData =
              followingUserRecipeDocumentSnapshot.data() as Map<String, dynamic>?;
          friendRecipeNameList.add(followingUserRecipeData!['recipe_name']);
          friendRecipeCalorieList.add(followingUserRecipeData['calories']);
          friendRecipeTimeList.add(followingUserRecipeData['time']);
          friendRecipeImageList.add(followingUserRecipeData['recipe_image']);
        }
      }
    }
    print(friendRecipeNameList.length);
    setState(() {});
  }

  Future<void> viewRecipeDetails(id) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.brown.shade100,
                    image: const DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage("assets/recipe_background.jpg"))),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 280,
                        margin: const EdgeInsets.all(15),
                        padding: const EdgeInsets.all(5),
                        child: const Text(
                          "Friends",
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(5.0),
                        child: const Text(
                          "See What's New from your friends",
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: friendRecipeNameList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      title: InkWell(
                                          onTap: () => {
                                                viewRecipeDetails(
                                                    friendRecipeIdList[index])
                                              },
                                          child: Container(
                                              padding: const EdgeInsets.all(5),
                                              margin: const EdgeInsets.only(
                                                  bottom: 10),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(50)),
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      style:
                                                          BorderStyle.solid)),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                      height: 100,
                                                      width: 100,
                                                      child: CircleAvatar(
                                                        backgroundImage:
                                                            NetworkImage(
                                                                friendRecipeImageList[
                                                                    index]),
                                                      ),
                                                    ),
                                                    Container(
                                                        width: 210,
                                                        margin: const EdgeInsets
                                                            .all(5),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        child: Column(
                                                            children: [
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(10),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .brown
                                                                        .shade100,
                                                                    borderRadius: const BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            20)),
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .brown
                                                                            .shade100,
                                                                        style: BorderStyle
                                                                            .solid)),
                                                                child: Text(
                                                                    friendRecipeNameList[
                                                                        index],
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black)),
                                                              ),
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceEvenly,
                                                                  children: [
                                                                    Container(
                                                                      margin:
                                                                          const EdgeInsets.all(
                                                                              5),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              10),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .brown
                                                                              .shade100,
                                                                          borderRadius: const BorderRadius.all(Radius.circular(
                                                                              20)),
                                                                          border: Border.all(
                                                                              color: Colors.brown.shade100,
                                                                              style: BorderStyle.solid)),
                                                                      child: Text(
                                                                          "${friendRecipeCalorieList[index]} Cal",
                                                                          style: const TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.black)),
                                                                    ),
                                                                    Container(
                                                                      margin:
                                                                          const EdgeInsets.all(
                                                                              5),
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              10),
                                                                      decoration: BoxDecoration(
                                                                          color: Colors
                                                                              .brown
                                                                              .shade100,
                                                                          borderRadius: const BorderRadius.all(Radius.circular(
                                                                              20)),
                                                                          border: Border.all(
                                                                              color: Colors.brown.shade100,
                                                                              style: BorderStyle.solid)),
                                                                      child: Text(
                                                                          "${friendRecipeTimeList[index]} mins",
                                                                          style: const TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.black)),
                                                                    )
                                                                  ])
                                                            ]))
                                                  ]))),
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
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.black)),
                              ]),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MyProfile()));
                                    },
                                    icon: const Icon(Icons.person_3_outlined),
                                  ),
                                  const Text("My Profile",
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.black)),
                                ],
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.group),
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
                                  icon:
                                      const Icon(Icons.notifications_outlined),
                                ),
                                const Text("Notifications",
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.black))
                              ])
                            ]),
                      )
                    ]))));
  }
}

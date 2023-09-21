import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/MyProfile.dart';
import 'package:new_app/RecipeView.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Favourites.dart';
import 'FollowingList.dart';
import 'Notifications.dart';
import 'RecipeFriends.dart';
import 'RecipeHome.dart';
import 'FollowersList.dart';

class UserProfile extends StatefulWidget {
  final String recipeOwnerId;
  const UserProfile({Key? key, required this.recipeOwnerId}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String loginUserProfileImage = "";
  String userName = "";
  String userAboutInfo = "";
  String userProfilePic = "";
  String recipeName = "";
  String recipeTime = "";
  String recipeImage = "";
  String loginUserId = "";
  bool following = false;
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
    // get login user id
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      loginUserId = prefs.getString('uid')!;
      loginUserProfileImage = prefs.getString('loginUserProfileImage')!;
    });

    //get the details of user whose profile is visited
    DocumentSnapshot visitedUserDocumentSnapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(widget.recipeOwnerId)
        .get();
    Map<String, dynamic>? userData =
        visitedUserDocumentSnapshot.data() as Map<String, dynamic>?;
    setState(() {
      userName = userData!['name'];
      userAboutInfo = userData['about_info'];
      userProfilePic = userData['image_url'];
    });

    // check if login user follows the user whose profile is visited
    CollectionReference followlist =
        FirebaseFirestore.instance.collection('followlist');
    QuerySnapshot followQuerySnapshot = await followlist
        .where('follower_id', isEqualTo: loginUserId)
        .where('following_id', isEqualTo: widget.recipeOwnerId)
        .get();
    if (followQuerySnapshot.docs.isNotEmpty) {
      setState(() {
        following = true;
      });
    }

    // get recipe list of user whose profile is visited
    QuerySnapshot recipeQuerySnapshot = await FirebaseFirestore.instance
        .collection('recipes')
        .where('user_id', isEqualTo: widget.recipeOwnerId)
        .get();
    if (recipeQuerySnapshot != null) {
      for (QueryDocumentSnapshot documentSnapshot in recipeQuerySnapshot.docs) {
        Map<String, dynamic> data =
            (documentSnapshot.data() as Map<String, dynamic>);

        setState(() {
          userRecipeNameList.add(data['recipe_name']);
          userRecipeTimeList.add(data['time']);
          userRecipeImageList.add(data['recipe_image']);
          userRecipeIdList.add(documentSnapshot.id);
        });
      }
    }

    // get visited user's followers count
    QuerySnapshot followersQuerySnapshot = await FirebaseFirestore.instance
        .collection('followlist')
        .where('following_id', isEqualTo: widget.recipeOwnerId)
        .get();
    if (followersQuerySnapshot != null) {
      followersCount = followersQuerySnapshot.docs.length;
    }

    // get visited user's following count
    QuerySnapshot followingQuerySnapshot = await FirebaseFirestore.instance
        .collection('followlist')
        .where('follower_id', isEqualTo: widget.recipeOwnerId)
        .get();
    if (followingQuerySnapshot != null) {
      followingCount = followingQuerySnapshot.docs.length;
    }

    setState(() {});
  }

  void addToFollowList() async {
    setState(() {
      following = true;
    });
    // ignore: unused_local_variable
    final followingUser =
        await FirebaseFirestore.instance.collection('followlist').add({
      'follower_id': loginUserId,
      'following_id': widget.recipeOwnerId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final followingNotification =
        await FirebaseFirestore.instance.collection('notifications').add({
      'reference_id': followingUser.id,
      'notification_image': loginUserProfileImage,
      'notification_content': "started following you",
      'notification_type': "Following",
      'timestamp': FieldValue.serverTimestamp(),
    });
    setState(() {
      followersCount= followersCount+1;
    });
  }

  void removeFromFollowList() async {
    setState(() {
      following = false;
    });
    // ignore: unused_local_variable
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('followlist')
        .where('follower_id', isEqualTo: loginUserId)
        .where('following_id', isEqualTo: widget.recipeOwnerId)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot followUser = querySnapshot.docs.first;
      await followUser.reference.delete();
    }
    setState(() {
      followersCount= followersCount-1;
    });
  }

  Future<void> getRecipeDetails(id) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance.collection('recipes').doc(id).get();
    recipeDetails = documentSnapshot.data()!;

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
                Container(
                    width: 500,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(10),
                    child: ElevatedButton(
                        child: Text(
                          following ? "Unfollow" : "Follow",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        onPressed: () {
                          following
                              ? removeFromFollowList()
                              : addToFollowList();
                        })),
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
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const MyProfile()));
                            },
                            icon: const Icon(Icons.person_3_outlined),
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

// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_app/Favourites.dart';
import 'package:new_app/MyProfile.dart';
import 'package:new_app/RecipeFriends.dart';
import 'package:new_app/RecipeHome.dart';
import 'package:new_app/RecipeView.dart';
import 'package:new_app/UserProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<String> userNotificationNameList = [];
  List<String> userNotificationContentList = [];
  List<Timestamp> userNotificationTimeList = [];
  List<String> userNotificationImageList = [];
  List<String> userNotificationReferenceIdList = [];
  List<String> userNotificationTypeList = [];
  String loginUserId = "";
  String checkUserId = "";
  String notificationType = "";
  String notificationReferenceId = "";
  String userNotificationName = "";

  @override
  void initState() {
    super.initState();
    getUserNotifications();
  }

  Future<void> viewFollowersDetails(id) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance.collection('followlist').doc(id).get();

    if (documentSnapshot.exists) {
      Map<String, dynamic>? data = documentSnapshot.data();
      String fieldValue = data!['follower_id'];
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserProfile(
                  recipeOwnerId: fieldValue,
                )),
      );
    }
  }

  Future<void> viewFavouriteDetails(id) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance.collection('favourites').doc(id).get();
    if (documentSnapshot.exists) {
      Map<String, dynamic>? data = documentSnapshot.data();
      String fieldValue = data!['recipe_id'];
      DocumentSnapshot<Map<String, dynamic>> documentSnapshotRecipe =
          await FirebaseFirestore.instance
              .collection('recipes')
              .doc(fieldValue)
              .get();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RecipeView(
                  recipeDetails: documentSnapshotRecipe,
                )),
      );
    }
  }

  Future<void> viewRecipeDetails(id) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance.collection('recipes').doc(id).get();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RecipeView(
                recipeDetails: documentSnapshot,
              )),
    );
  }

  String formatDateTime(DateTime dateTime) {
    String daySuffix = _getDaySuffix(dateTime.day);
    String formattedDate =
        DateFormat("d'$daySuffix' MMMM yyyy  HH:mm a").format(dateTime);
    return formattedDate;
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Future<String> getUserName(
      String notification_type, String notification_referenceid) async {
    if (notification_type == 'Following') {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('followlist')
              .doc(notification_referenceid)
              .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic>? data = documentSnapshot.data();
        String fieldValue = data!['follower_id'];
        DocumentSnapshot<Map<String, dynamic>> documentSnapshotRecipe =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(fieldValue)
                .get();

        Map<String, dynamic>? dataname = documentSnapshotRecipe.data();
        userNotificationName = dataname!['name'];
      }
    } else if (notification_type == 'favourite') {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('favourites')
              .doc(notification_referenceid)
              .get();
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data = documentSnapshot.data();
        String fieldValue = data!['user_id'];
        DocumentSnapshot<Map<String, dynamic>> documentSnapshotRecipe =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(fieldValue)
                .get();
        Map<String, dynamic>? dataname = documentSnapshotRecipe.data();
        userNotificationName = dataname!['name'];
      }
    } else if (notification_type == 'recipe') {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('recipes')
              .doc(notification_referenceid)
              .get();
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data1 = documentSnapshot.data();
        String fieldValue = data1!['user_id'];
        DocumentSnapshot<Map<String, dynamic>> documentSnapshotRecipe =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(fieldValue)
                .get();
        Map<String, dynamic>? dataname = documentSnapshotRecipe.data();
        userNotificationName = dataname!['name'];
      }
    }
    return userNotificationName;
  }

  void getUserNotifications() async {
    // userNotificationNameList.clear();
    // userNotificationContentList.clear();
    // userNotificationTimeList.clear();
    // userNotificationImageList.clear();
    // userNotificationReferenceIdList.clear();
    // userNotificationTypeList.clear();

    final prefs = await SharedPreferences.getInstance();
    loginUserId = prefs.getString('uid')!;
    QuerySnapshot notificationQuerySnapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .get();

    if (notificationQuerySnapshot != null) {
      for (QueryDocumentSnapshot notificationDocumentSnapshot
          in notificationQuerySnapshot.docs) {
        Map<String, dynamic> data =
            (notificationDocumentSnapshot.data() as Map<String, dynamic>);
        notificationReferenceId = data['reference_id'];
        notificationType = data['notification_type'];
        if (notificationType == 'Following') {
          DocumentSnapshot<Map<String, dynamic>>
              followingNotificationDocumentSnapshot = await FirebaseFirestore
                  .instance
                  .collection('followlist')
                  .doc(notificationReferenceId)
                  .get();
          if (followingNotificationDocumentSnapshot.exists) {
            Map<String, dynamic> followingData =
                (followingNotificationDocumentSnapshot.data()
                    as Map<String, dynamic>);
            checkUserId = followingData['following_id'];
          }
        } else if (notificationType == 'favourite') {
          DocumentSnapshot<Map<String, dynamic>>
              favouriteNotificationDocumentSnapshot = await FirebaseFirestore
                  .instance
                  .collection('favourites')
                  .doc(notificationReferenceId)
                  .get();
          if (favouriteNotificationDocumentSnapshot.exists) {
            Map<String, dynamic> favouriteData =
                (favouriteNotificationDocumentSnapshot.data()
                    as Map<String, dynamic>);
            DocumentSnapshot<Map<String, dynamic>>
                favouriteRecipeNotificationDocumentSnapshot =
                await FirebaseFirestore.instance
                    .collection('recipes')
                    .doc(favouriteData['recipe_id'])
                    .get();
            if (favouriteRecipeNotificationDocumentSnapshot.exists) {
              Map<String, dynamic> favoriteData =
                  (favouriteRecipeNotificationDocumentSnapshot.data()
                      as Map<String, dynamic>);
              checkUserId = favoriteData['user_id'];
            }
          }
        } else if (notificationType == 'recipe') {
          DocumentSnapshot<Map<String, dynamic>>
              recipeNotificationDocumentSnapshot = await FirebaseFirestore
                  .instance
                  .collection('recipes')
                  .doc(notificationReferenceId)
                  .get();
          if (recipeNotificationDocumentSnapshot.exists) {
            Map<String, dynamic> recipeData =
                (recipeNotificationDocumentSnapshot.data()
                    as Map<String, dynamic>);
            CollectionReference collection =
                FirebaseFirestore.instance.collection('followlist');
            QuerySnapshot recipieUploadQuery = await collection
                .where('follower_id', isEqualTo: loginUserId)
                .where('following_id', isEqualTo: recipeData['user_id'])
                .get();
            if (recipieUploadQuery.docs.isNotEmpty) {
              QueryDocumentSnapshot documentSnapshot =
                  recipieUploadQuery.docs[0];
              Map<String, dynamic> data =
                  (documentSnapshot.data() as Map<String, dynamic>);
              checkUserId = data['follower_id'];
            }
          }
        }

        if (checkUserId == loginUserId) {
          userNotificationContentList.add(data['notification_content']);
          userNotificationTimeList.add(data['timestamp']);
          userNotificationImageList.add(data['notification_image']);
          userNotificationReferenceIdList.add(data['reference_id']);
          userNotificationTypeList.add(data['notification_type']);
          String userName = await getUserName(
              data['notification_type'], data['reference_id']);

          userNotificationNameList.add(userName);

          // Retrieve the user name based on the notification type
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
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
                "Notifications",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Flexible(
                child: SingleChildScrollView(
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userNotificationImageList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Timestamp notificationTimestamp =
                        userNotificationTimeList[index];
                    DateTime notificationDateTime =
                        notificationTimestamp.toDate();
                    String notificationDate =
                        formatDateTime(notificationDateTime);
                    return ListTile(
                      onTap: () {
                        String notificationType =
                            userNotificationTypeList[index];

                        if (notificationType == 'Following') {
                          viewFollowersDetails(
                              userNotificationReferenceIdList[index]);
                        } else if (notificationType == 'favourite') {
                          viewFavouriteDetails(
                              userNotificationReferenceIdList[index]);
                        } else if (notificationType == 'recipe') {
                          // Redirect to recipe view page
                          viewRecipeDetails(
                              userNotificationReferenceIdList[index]);
                        }
                      },
                      title: Container(
                          //width: 500,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              border: Border.all(
                                  color: Colors.white,
                                  style: BorderStyle.solid)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 45,
                                  width: 45,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        userNotificationImageList[index]),
                                  ),
                                ),
                                Column(children: [
                                  Container(
                                    margin: const EdgeInsets.all(5),
                                    width: 300,
                                    child: Text(
                                        "${userNotificationNameList[index]} ${userNotificationContentList[index]}",
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.black)),
                                  ),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    margin: const EdgeInsets.only(
                                        left: 15, top: 5, bottom: 5, right: 5),
                                    child: Text(notificationDate,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700)),
                                  )
                                ])
                              ])),
                    );
                  }),
            )),
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
                                  builder: (context) => const RecipeHome()));
                        },
                        icon: const Icon(Icons.home_outlined),
                      ),
                      const Text("Home",
                          style: TextStyle(fontSize: 10, color: Colors.black)),
                    ]),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyProfile()));
                          },
                          icon: const Icon(Icons.person_3_outlined),
                        ),
                        const Text("My Profile",
                            style:
                                TextStyle(fontSize: 10, color: Colors.black)),
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
                                        const RecipeFriends()));
                          },
                          icon: const Icon(Icons.group_outlined),
                        ),
                        const Text("Friends",
                            style:
                                TextStyle(fontSize: 10, color: Colors.black)),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Favourites()));
                          },
                          icon: const Icon(Icons.favorite_outline),
                        ),
                        const Text("Favourites",
                            style:
                                TextStyle(fontSize: 10, color: Colors.black)),
                      ],
                    ),
                    Column(children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications),
                      ),
                      const Text("Notifications",
                          style: TextStyle(fontSize: 10, color: Colors.black))
                    ])
                  ]),
            )
          ],
        ),
      )),
    );
  }
}

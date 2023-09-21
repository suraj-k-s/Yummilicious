import 'package:flutter/material.dart';
import 'package:new_app/Favourites.dart';
import 'package:new_app/MyProfile.dart';
import 'package:new_app/Notifications.dart';
import 'package:new_app/RecipeFriends.dart';
import 'package:new_app/RecipeView.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform, exit;

class RecipeHome extends StatefulWidget {
  const RecipeHome({super.key});

  @override
  State<RecipeHome> createState() => _RecipeHomeState();
}

class _RecipeHomeState extends State<RecipeHome> {
  String uid = "";
  String recipeId = "";
  List<dynamic>? data = [];
  String userName = "";
  String userProfilePic = "";
  List<String> recipeNameList = [];
  List<String> recipeTimeList = [];
  List<String> recipeImageList = [];
  List<String> recipeCalorieList = [];
  List<String> userRecipeIdList = [];
  String categoryFilterValue = "All Recipes";
  Map<String, dynamic> recipeDetails = {};

  final categoryList = [
    'All Recipes',
    'Breakfast',
    'Lunch',
    'Salad',
    'Starter',
    'Shakes',
    'Juices',
    'Desserts',
    'Hot Beverages',
    'Cakes',
    'Smoothies'
  ];

  @override
  void initState() {
    super.initState();
    getUserDetails();
    fetchAndDisplayRecipes();
  }

  void checkCategoryFilter(String categoryFilter) {
    categoryFilterValue = categoryFilter;
    fetchAndDisplayRecipes();
    setState(() {});
  }

  void fetchAndDisplayRecipes() async {
    recipeNameList.clear();
    recipeTimeList.clear();
    recipeCalorieList.clear();
    recipeImageList.clear();
    userRecipeIdList.clear();

    // Create a reference to the collection
    CollectionReference collection =
        FirebaseFirestore.instance.collection('recipes');
    QuerySnapshot querySnapshot;
    if (categoryFilterValue == "All Recipes") {
      querySnapshot =
          await collection.orderBy('timestamp', descending: true).get();
    } else {
      querySnapshot = await collection
          .where('recipe_category', isEqualTo: categoryFilterValue)
          .orderBy('timestamp', descending: true)
          .get();
    }
    if (querySnapshot != null) {
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> data =
            (documentSnapshot.data() as Map<String, dynamic>);
        // Access the recipe data
        recipeNameList.add(data['recipe_name']);
        recipeTimeList.add(data['time']);
        recipeCalorieList.add(data['calories']);
        recipeImageList.add(data['recipe_image']);
        userRecipeIdList.add(documentSnapshot.id);
      }
    }
    setState(() {});
  }

  void getUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = (prefs.getString('uid') ?? "");
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;
 
    setState(() {
      userName = userData!['name'];
      userProfilePic = userData['image_url'];
    });
     await prefs.setString('loginUserProfileImage', userProfilePic);
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
    return WillPopScope(
        onWillPop: () async {
          if (Platform.isIOS) {
            try {
              exit(0);
            } catch (e) {
              SystemNavigator
                  .pop(); // for IOS, not true this, you can make comment this :)
            }
          } else {
            try {
              SystemNavigator.pop(); // sometimes it cant exit app
            } catch (e) {
              exit(0); // so i am giving crash to app ... sad :(
            }
          }
          return false;
        },
        child: Scaffold(
            body: SafeArea(
                child: Container(
          decoration: BoxDecoration(
              color: Colors.brown.shade100,
              image: const DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/recipe_background1.jpg"))),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 280,
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          "Hello $userName",
                          style: const TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      // ignore: unnecessary_null_comparison
                      userProfilePic != null
                          ? Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(5),
                              child: SizedBox(
                                height: 80,
                                width: 80,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(userProfilePic),
                                ),
                              ))
                          : Container(
                              margin: const EdgeInsets.all(10),
                              padding: const EdgeInsets.all(5),
                              child: const SizedBox(
                                height: 80,
                                width: 80,
                                child: CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/person.jpg'),
                                ),
                              ))
                    ]),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                      border: Border.all(
                          color: Colors.white, style: BorderStyle.solid)),
                  child: const TextField(
                    decoration: InputDecoration(
                        icon: Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: "Search",
                        hintStyle:
                            TextStyle(color: Colors.black, fontSize: 18)),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(5.0),
                  child: const Text(
                    "Categories",
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  height: 45,
                  margin: const EdgeInsets.all(10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          checkCategoryFilter(categoryList[index]);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                            border: Border.all(
                              color: Colors.white,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Text(
                            categoryList[index],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(5.0),
                  child: const Text(
                    "What would you like to cook today ?",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Flexible(
                    child: SingleChildScrollView(
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: recipeNameList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: InkWell(
                                    onTap: () => {
                                          viewRecipeDetails(
                                              userRecipeIdList[index])
                                        },
                                    child: Container(
                                        padding: const EdgeInsets.all(5),
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50)),
                                            border: Border.all(
                                                color: Colors.white,
                                                style: BorderStyle.solid)),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              SizedBox(
                                                height: 100,
                                                width: 100,
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      recipeImageList[index]),
                                                ),
                                              ),
                                              Container(
                                                  width: 210,
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  child: Column(children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .brown.shade100,
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          20)),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .brown
                                                                  .shade100,
                                                              style: BorderStyle
                                                                  .solid)),
                                                      child: Text(
                                                          recipeNameList[index],
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16,
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
                                                                const EdgeInsets
                                                                    .all(5),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .brown
                                                                    .shade100,
                                                                borderRadius:
                                                                    const BorderRadius
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
                                                                "${recipeCalorieList[index]} Cal",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black)),
                                                          ),
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
                                                                borderRadius:
                                                                    const BorderRadius
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
                                                                "${recipeTimeList[index]} mins",
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black)),
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
                            onPressed: () {},
                            icon: const Icon(Icons.home),
                          ),
                          const Text("Home",
                              style:
                                  TextStyle(fontSize: 10, color: Colors.black)),
                        ]),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
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
                              onPressed: () {
                                Navigator.push(
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
                                Navigator.push(
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
                              Navigator.push(
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
        ))));
  }
}

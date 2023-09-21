import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/MyProfile.dart';
import 'package:new_app/Notifications.dart';
import 'package:new_app/RecipeFriends.dart';
import 'package:new_app/RecipeHome.dart';
import 'package:new_app/RecipeView.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  String loginUserId = "";
  List<String> favouriteRecipeIdList = [];
  List<String> favouriteRecipeNameList = [];
  List<String> favouriteRecipeCalorieList = [];
  List<String> favouriteRecipeTimeList = [];
  List<String> favouriteRecipeImageList = [];

  @override
  void initState() {
    super.initState();
    getfavouriteList();
  }

  Future<void> getfavouriteList() async {
    final prefs = await SharedPreferences.getInstance();
    loginUserId = (prefs.getString('uid') ?? "");
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('favourites')
        .where('user_id', isEqualTo: loginUserId)
        .get();
    if (querySnapshot != null) {
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        Map<String, dynamic> favouriteData =
            (documentSnapshot.data() as Map<String, dynamic>);
        favouriteRecipeIdList.add(favouriteData['recipe_id']);
        DocumentSnapshot favouriteRecipeQuerySnapshot = await FirebaseFirestore
            .instance
            .collection('recipes')
            .doc(favouriteData['recipe_id'])
            .get();
        Map<String, dynamic>? favouriteRecipeData =
            favouriteRecipeQuerySnapshot.data() as Map<String, dynamic>?;
        favouriteRecipeNameList.add(favouriteRecipeData!['recipe_name']);
        favouriteRecipeCalorieList.add(favouriteRecipeData['calories']);
        favouriteRecipeTimeList.add(favouriteRecipeData['time']);
        favouriteRecipeImageList.add(favouriteRecipeData['recipe_image']);
      }
    }
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
                          "My Favourites",
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
                                  itemCount: favouriteRecipeNameList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      title: InkWell(
                                          onTap: () => {
                                                viewRecipeDetails(
                                                    favouriteRecipeIdList[
                                                        index])
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
                                                                favouriteRecipeImageList[
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
                                                                    favouriteRecipeNameList[
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
                                                                          "${favouriteRecipeCalorieList[index]} Cal",
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
                                                                          "${favouriteRecipeTimeList[index]} mins",
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
                              Column(children: [
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
                                    onPressed: () {},
                                    icon: const Icon(Icons.favorite),
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

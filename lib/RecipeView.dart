import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:new_app/EditRecipe.dart';
import 'package:new_app/MyProfile.dart';
import 'package:new_app/UserProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeView extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? recipeDetails;
  const RecipeView({Key? key, required this.recipeDetails}) : super(key: key);

  @override
  State<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  String userImage = "";
  String recipeIdentifier = "";
  String recipeName = "";
  String recipeAbout = "";
  String recipeCategory = "";
  String recipeCalories = "";
  String recipeTime = "";
  String recipeServings = "";
  String recipeImage = "";
  String recipeOwnerId = "";
  String loginUserId = "";
  bool favourite = false;
  List<dynamic> recipePreparationSteps = [];
  List<dynamic> recipeIngredients = [];
  Map<String, dynamic>? recipeDetailsNew;

  @override
  void initState() {
    super.initState();
    recipeDetailsNew = widget.recipeDetails?.data();
    recipeIdentifier = widget.recipeDetails!.id;
    recipeOwnerId = recipeDetailsNew!['user_id'];
    recipeName = recipeDetailsNew!['recipe_name'];
    recipeAbout = recipeDetailsNew!['recipe_about'];
    recipeCategory = recipeDetailsNew!['recipe_category'];
    recipeCalories = recipeDetailsNew!['calories'];
    recipeTime = recipeDetailsNew!['time'];
    recipeServings = recipeDetailsNew!['servings'];
    recipeIngredients = recipeDetailsNew!['recipe_ingredients'];
    recipePreparationSteps = recipeDetailsNew!['recipe_preparation_steps'];
    recipeImage = recipeDetailsNew!['recipe_image'];
    getRecipeDetails();
  }

  void getRecipeDetails() async {
    final prefs = await SharedPreferences.getInstance();
    loginUserId = prefs.getString('uid')!;
    setState(() async {
      if (loginUserId == recipeOwnerId) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(loginUserId)
            .get();
        Map<String, dynamic>? userData =
            snapshot.data() as Map<String, dynamic>?;
        userImage = userData!['image_url'];
        setState(() {});
      } else {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(recipeOwnerId)
            .get();
        Map<String, dynamic>? userData =
            snapshot.data() as Map<String, dynamic>?;
        userImage = userData!['image_url'];
        setState(() {});
      }
      CollectionReference favouritecollection =
          FirebaseFirestore.instance.collection('favourites');
      QuerySnapshot querySnapshot = await favouritecollection
          .where('recipe_id', isEqualTo: recipeIdentifier)
          .where('user_id', isEqualTo: loginUserId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        favourite = true;
        setState(() {});
      }
    });
  }

  void removeFromFavourites() async {
    setState(() {
      favourite = false;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('favourites')
        .where('user_id', isEqualTo: loginUserId)
        .where('recipe_id', isEqualTo: recipeIdentifier)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      String documentId = querySnapshot.docs[0].id;
      QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
          .collection('notifications')
          .where('reference_id', isEqualTo: documentId)
          .get();

      DocumentSnapshot favouriteDocument1 = querySnapshot1.docs.first;
      await favouriteDocument1.reference.delete();
      DocumentSnapshot favouriteDocument = querySnapshot.docs.first;
      await favouriteDocument.reference.delete();
    }
  }

  void addToFavourites() async {
    setState(() {
      favourite = true;
    });
    // ignore: unused_local_variable
    final favouriteRecipes =
        await FirebaseFirestore.instance.collection('favourites').add({
      'user_id': loginUserId,
      'recipe_id': recipeIdentifier,
      'timestamp': FieldValue.serverTimestamp()
    });

    // ignore: unused_local_variable
    final favouriteNotification =
        await FirebaseFirestore.instance.collection('notifications').add({
      'reference_id': favouriteRecipes.id,
      'notification_image': recipeImage,
      'notification_content': "liked your recipe",
      'notification_type': "favourite",
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.brown.shade100,
                image: const DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("assets/recipe_background.jpg"))),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 290,
                          margin: const EdgeInsets.only(
                              left: 10, right: 10, top: 5, bottom: 5),
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            recipeName,
                            style: const TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            loginUserId == recipeOwnerId
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const MyProfile()))
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => UserProfile(
                                              recipeOwnerId: recipeOwnerId,
                                            )));
                          },
                          child: Container(
                              margin: const EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              padding: const EdgeInsets.all(5),
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(userImage),
                                ),
                              )),
                        )
                      ],
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 290,
                          margin: const EdgeInsets.only(
                              left: 10, right: 10, top: 5, bottom: 5),
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            recipeAbout,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        loginUserId == recipeOwnerId
                            ? Container(
                                margin: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                padding: const EdgeInsets.all(5),
                                child: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditRecipe(
                                              recipeDetails: widget.recipeDetails,
                                              )),
                                    );
                                  },
                                ))
                            : Container(
                                margin: const EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                padding: const EdgeInsets.all(5),
                                child: IconButton(
                                  icon: Icon(favourite
                                      ? Icons.favorite
                                      : Icons.favorite_outline),
                                  onPressed: () {
                                    favourite
                                        ? removeFromFavourites()
                                        : addToFavourites();
                                  },
                                ))
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 140,
                                  margin: const EdgeInsets.only(
                                      right: 10, top: 10, bottom: 10),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(40)),
                                      border: Border.all(
                                          color: Colors.white,
                                          style: BorderStyle.solid)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        margin: const EdgeInsets.all(5),
                                        padding: const EdgeInsets.all(5),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.brown.shade100,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50)),
                                            border: Border.all(
                                                color: Colors.brown.shade100,
                                                style: BorderStyle.solid)),
                                        child: Text(
                                          recipeCalories,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const Text(
                                        "Calories",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 140,
                                  margin: const EdgeInsets.only(
                                      right: 10, top: 10, bottom: 10),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(40)),
                                      border: Border.all(
                                          color: Colors.white,
                                          style: BorderStyle.solid)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        margin: const EdgeInsets.all(5),
                                        padding: const EdgeInsets.all(5),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.brown.shade100,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50)),
                                            border: Border.all(
                                                color: Colors.brown.shade100,
                                                style: BorderStyle.solid)),
                                        child: Text(
                                          recipeTime,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const Text(
                                        "Minutes",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 140,
                                  margin: const EdgeInsets.only(
                                      right: 10, top: 10, bottom: 10),
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(40)),
                                      border: Border.all(
                                          color: Colors.white,
                                          style: BorderStyle.solid)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        margin: const EdgeInsets.all(5),
                                        padding: const EdgeInsets.all(5),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.brown.shade100,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50)),
                                            border: Border.all(
                                                color: Colors.brown.shade100,
                                                style: BorderStyle.solid)),
                                        child: Text(
                                          recipeServings,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const Text(
                                        "Servings",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.all(5),
                              height: 190,
                              width: 190,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(recipeImage),
                              ),
                            ),
                          ],
                        )),
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        "Ingredients",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(40)),
                          border: Border.all(
                              color: Colors.white, style: BorderStyle.solid)),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recipeIngredients.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${index + 1}. ",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                  Flexible(
                                    child: Text(
                                      "${recipeIngredients[index]['ingredient_name']} ",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      recipeIngredients[index]
                                          ['ingredient_quantity'],
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ]),
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(5),
                      child: const Text(
                        "Preparation",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(40)),
                          border: Border.all(
                              color: Colors.white, style: BorderStyle.solid)),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recipePreparationSteps.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${index + 1}. ",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                  Flexible(
                                    child: Text(
                                      recipePreparationSteps[index]
                                          ['preparation_steps'],
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                ]),
                          );
                        },
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:new_app/ImagePicker.dart';
import 'package:new_app/MyProfile.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateRecipe extends StatefulWidget {
  const CreateRecipe({super.key});

  @override
  State<CreateRecipe> createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
  String uid = "";

  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _recipeAboutController = TextEditingController();

  String categoryDropdownvalue = 'Breakfast';
  final categoryList = [
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

  List<Map<String, dynamic>> ingredientsList = [];
  List<Map<String, dynamic>> preparationStepsList = [];

  List<TextEditingController> ingredientNameArray = [];
  List<TextEditingController> ingredientQuantityArray = [];
  List<TextEditingController> preparationStepsArray = [];

  final TextEditingController _recipeCalorieController =
      TextEditingController();
  final TextEditingController _recipeTimeController = TextEditingController();
  final TextEditingController _recipeServingsController =
      TextEditingController();

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _getUser();
    setState(() {
      preparationStepsArray.add(TextEditingController());
      ingredientNameArray.add(TextEditingController());
      ingredientQuantityArray.add(TextEditingController());
    });
  }

  void _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = (prefs.getString('uid') ?? "");
    });
  }

  Future<void> createRecipe() async {
    for (int ingredientCount = 0;
        ingredientCount < ingredientNameArray.length;
        ingredientCount++) {
      ingredientsList.add({
        'ingredient_name': ingredientNameArray[ingredientCount].text,
        'ingredient_quantity': ingredientQuantityArray[ingredientCount].text
      });
    }

    for (int preparationStepCount = 0;
        preparationStepCount < preparationStepsArray.length;
        preparationStepCount++) {
      preparationStepsList.add({
        'preparation_steps': preparationStepsArray[preparationStepCount].text
      });
    }

    final recipeImageId = const Uuid().v1();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('recipe_images/$recipeImageId');
    await storageReference.putFile(selectedImage!);
    String recipeImageUrl = await storageReference.getDownloadURL();

    final recipeDocRef =
        await FirebaseFirestore.instance.collection('recipes').add({
      'user_id': uid,
      'recipe_name': _recipeNameController.text,
      'recipe_about': _recipeAboutController.text,
      'recipe_category': categoryDropdownvalue,
      'recipe_ingredients': ingredientsList,
      'recipe_preparation_steps': preparationStepsList,
      'calories': _recipeCalorieController.text,
      'time': _recipeTimeController.text,
      'servings': _recipeServingsController.text,
      'recipe_image': recipeImageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    final createRecipeNotification =
        await FirebaseFirestore.instance.collection('notifications').add({
      'reference_id': recipeDocRef.id,
      'notification_image': recipeImageUrl,
      'notification_content': "uploaded a new recipe",
      'notification_type': "recipe",
      'timestamp': FieldValue.serverTimestamp(),
    });

    ingredientsList.clear();
    preparationStepsList.clear();

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Recipe Created"),
    ));

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const MyProfile()));
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
                image: AssetImage("assets/recipe_background1.jpg"))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 280,
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(5),
              child: const Text(
                "Create Recipe",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(children: [
                  Container(
                    width: 500,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    child: const Text("Recipe Name",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                  ),
                  Container(
                    width: 500,
                    margin: const EdgeInsets.only(
                        left: 15, right: 15, top: 5, bottom: 5),
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                        border: Border.all(
                            color: Colors.white, style: BorderStyle.solid)),
                    child: TextField(
                      controller: _recipeNameController,
                      decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Enter recipe name",
                          hintStyle: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16)),
                    ),
                  ),
                  Container(
                    width: 500,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    child: const Text("About",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                  ),
                  Container(
                    width: 500,
                    margin: const EdgeInsets.only(
                        left: 15, right: 15, top: 5, bottom: 5),
                    padding: const EdgeInsets.only(
                        left: 15, right: 15, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50)),
                        border: Border.all(
                            color: Colors.white, style: BorderStyle.solid)),
                    child: TextField(
                      controller: _recipeAboutController,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Enter a short description",
                          hintStyle: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16)),
                    ),
                  ),
                  Container(
                    width: 500,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    child: const Text("Category",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                  ),
                  Container(
                      width: 500,
                      margin: const EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                          border: Border.all(
                              color: Colors.white, style: BorderStyle.solid)),
                      child: DropdownButton(
                          value: categoryDropdownvalue,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                          underline: Container(
                            color: Colors.white,
                          ),
                          items: categoryList.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              categoryDropdownvalue = newValue!;
                            });
                          })),
                  Row(children: [
                    Container(
                      width: 220,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      child: const Text("Ingredients",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              ingredientNameArray.add(TextEditingController());
                              ingredientQuantityArray
                                  .add(TextEditingController());
                            });
                          },
                          child: const Text(
                            "+ Add Ingredient",
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          )),
                    ),
                  ]),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ingredientNameArray.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Row(children: [
                            Container(
                              width: 230,
                              margin: const EdgeInsets.only(
                                  left: 5, right: 5, top: 5, bottom: 5),
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50)),
                                  border: Border.all(
                                      color: Colors.white,
                                      style: BorderStyle.solid)),
                              child: TextField(
                                controller: ingredientNameArray[index],
                                decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText: "Ingredient ${index + 1}",
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16)),
                              ),
                            ),
                            Container(
                              width: 100,
                              margin: const EdgeInsets.only(
                                  left: 5, right: 5, top: 5, bottom: 5),
                              padding: const EdgeInsets.only(
                                  left: 15, right: 15, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50)),
                                  border: Border.all(
                                      color: Colors.white,
                                      style: BorderStyle.solid)),
                              child: TextField(
                                controller: ingredientQuantityArray[index],
                                decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText: "Quantity",
                                    hintStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16)),
                              ),
                            ),
                            Container(
                              width: 20,
                              child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      ingredientNameArray.removeAt(index);
                                      ingredientQuantityArray.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.remove_circle_rounded),
                                  color: Colors.black87),
                            )
                          ]),
                        );
                      }),
                  Row(children: [
                    Container(
                      width: 250,
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      child: const Text("Preparation Steps",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w500)),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              preparationStepsArray
                                  .add(TextEditingController());
                            });
                          },
                          child: const Text(
                            "+ Add Step",
                            style: TextStyle(color: Colors.black, fontSize: 14),
                          )),
                    ),
                  ]),
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: preparationStepsArray.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Row(
                            children: [
                              Container(
                                width: 340,
                                margin: const EdgeInsets.only(
                                    left: 5, right: 5, top: 5, bottom: 5),
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 5, bottom: 5),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(50)),
                                    border: Border.all(
                                        color: Colors.white,
                                        style: BorderStyle.solid)),
                                child: TextField(
                                  controller: preparationStepsArray[index],
                                  decoration: InputDecoration(
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      hintText: "Step ${index + 1}",
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16)),
                                ),
                              ),
                              Container(
                                width: 20,
                                child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        preparationStepsArray.removeAt(index);
                                      });
                                    },
                                    icon:
                                        const Icon(Icons.remove_circle_rounded),
                                    color: Colors.black87),
                              )
                            ],
                          ),
                        );
                      }),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 115,
                              margin: const EdgeInsets.only(
                                  left: 10, right: 5, top: 10, bottom: 5),
                              padding: const EdgeInsets.only(
                                  left: 10, right: 5, top: 10, bottom: 5),
                              child: const Text("Calories",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ),
                            Container(
                              width: 115,
                              margin: const EdgeInsets.only(
                                  left: 10, right: 5, top: 10, bottom: 5),
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(100)),
                                  border: Border.all(
                                      color: Colors.white,
                                      style: BorderStyle.solid)),
                              child: TextField(
                                controller: _recipeCalorieController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    label: const Center(
                                        child: Text("KCal",
                                            textAlign: TextAlign.center)),
                                    labelStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width: 115,
                              margin: const EdgeInsets.only(
                                  left: 5, right: 5, top: 10, bottom: 5),
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 10, bottom: 5),
                              child: const Text("Time",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ),
                            Container(
                              width: 115,
                              margin: const EdgeInsets.only(
                                  left: 5, right: 5, top: 10, bottom: 5),
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(100)),
                                  border: Border.all(
                                      color: Colors.white,
                                      style: BorderStyle.solid)),
                              child: TextField(
                                controller: _recipeTimeController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    label: const Center(
                                        child: Text("Minutes",
                                            textAlign: TextAlign.center)),
                                    labelStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width: 115,
                              margin: const EdgeInsets.only(
                                  left: 5, right: 10, top: 10, bottom: 5),
                              padding: const EdgeInsets.only(
                                  left: 5, right: 10, top: 10, bottom: 5),
                              child: const Text("Servings",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                            ),
                            Container(
                              width: 115,
                              margin: const EdgeInsets.only(
                                  left: 5, right: 10, top: 10, bottom: 5),
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(100)),
                                  border: Border.all(
                                      color: Colors.white,
                                      style: BorderStyle.solid)),
                              child: TextField(
                                controller: _recipeServingsController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    label: const Center(
                                        child: Text("Count",
                                            textAlign: TextAlign.center)),
                                    labelStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ]),
                  Container(
                    width: 500,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    child: const Text("Upload Photo",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500)),
                  ),
                  selectedImage != null
                      ? Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(
                                  color: Colors.white,
                                  style: BorderStyle.solid)),
                          child: Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                          ))
                      : Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(
                                  color: Colors.white,
                                  style: BorderStyle.solid)),
                          child: IconButton(
                            onPressed: () async {
                              final pickedImage = await pickImageC();
                              setState(() {
                                selectedImage = pickedImage;
                              });
                            },
                            icon: const Icon(Icons.add),
                            color: Colors.brown.shade900,
                            iconSize: 35,
                          )),
                  const SizedBox(
                    width: 300,
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                        onPressed: () {
                          createRecipe();
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.brown.shade600),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ))),
                        child: const Text(
                          "Create Recipe",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        )),
                  ),
                ]),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

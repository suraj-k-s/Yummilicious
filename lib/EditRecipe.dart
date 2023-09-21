import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:new_app/ImagePicker.dart';
import 'package:new_app/MyProfile.dart';
import 'package:uuid/uuid.dart';

class EditRecipe extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>>? recipeDetails;
  const EditRecipe({Key? key, required this.recipeDetails}) : super(key: key);

  @override
  State<EditRecipe> createState() => _EditRecipeState();
}

class _EditRecipeState extends State<EditRecipe> {
  //String userImage = "";
  //String recipeName = "";
  //String recipeAbout = "";
  //String recipeCategory = "";
  //String recipeCalories = "";
  //String recipeTime = "";
  //String recipeServings = "";
  String recipeIdentifier = "";
  String recipeImage = "";
  String recipeOwnerId = "";
  String loginUserId = "";
  String categoryDropdownvalue = "";
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
  List<dynamic> recipePreparationSteps = [];
  List<dynamic> recipeIngredients = [];
  List<dynamic> recipeIngredientsUpdatedList = [];
  List<dynamic> recipePreparationStepsUpdatedList = [];
  Map<String, dynamic>? recipeDetailsNew;

  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _recipeAboutController = TextEditingController();
  final TextEditingController _recipeCalorieController =
      TextEditingController();
  final TextEditingController _recipeTimeController = TextEditingController();
  final TextEditingController _recipeServingsController =
      TextEditingController();
  List<TextEditingController> ingredientNameArray = [];
  List<TextEditingController> ingredientQuantityArray = [];
  List<TextEditingController> preparationStepsArray = [];

  File? selectedImage;

  @override
  void initState() {
    super.initState();
    recipeDetailsNew = widget.recipeDetails?.data();
    recipeIdentifier = widget.recipeDetails!.id;
    recipeOwnerId = recipeDetailsNew!['user_id'];
    _recipeNameController.text = recipeDetailsNew!['recipe_name'];
    _recipeAboutController.text = recipeDetailsNew!['recipe_about'];
    categoryDropdownvalue = recipeDetailsNew!['recipe_category'];
    _recipeCalorieController.text = recipeDetailsNew!['calories'];
    _recipeTimeController.text = recipeDetailsNew!['time'];
    _recipeServingsController.text = recipeDetailsNew!['servings'];
    recipeIngredients = recipeDetailsNew!['recipe_ingredients'];
    ingredientNameArray = recipeIngredients
        .map(
            (e) => TextEditingController(text: e["ingredient_name"].toString()))
        .toList();
    ingredientQuantityArray = recipeIngredients
        .map((e) =>
            TextEditingController(text: e["ingredient_quantity"].toString()))
        .toList();
    recipePreparationSteps = recipeDetailsNew!['recipe_preparation_steps'];

    preparationStepsArray = recipePreparationSteps
        .map((e) =>
            TextEditingController(text: e["preparation_steps"].toString()))
        .toList();
    recipeImage = recipeDetailsNew!['recipe_image'];
  }

  Future<void> deleteFile(String recipeImage) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Uri uri = Uri.parse(recipeImage);
    final String id = uri.pathSegments.last;
    final Reference existingUrlReference = storage.ref().child(id);
    try {
      await existingUrlReference.delete();
      print('File deleted successfully.');
    } catch (error) {
      if (error is FirebaseException && error.code == 'object-not-found') {
        print('Error deleting file: File not found.');
      } else {
        print('Error deleting file: $error');
      }
    }
  }

  Future<void> updateRecipe() async {
    for (int ingredientCount = 0;
        ingredientCount < ingredientNameArray.length;
        ingredientCount++) {
      recipeIngredientsUpdatedList.add({
        'ingredient_name': ingredientNameArray[ingredientCount].text,
        'ingredient_quantity': ingredientQuantityArray[ingredientCount].text
      });
    }

    for (int preparationStepCount = 0;
        preparationStepCount < preparationStepsArray.length;
        preparationStepCount++) {
      recipePreparationStepsUpdatedList.add({
        'preparation_steps': preparationStepsArray[preparationStepCount].text
      });
    }
    String recipeImageUrl = "";
    if (selectedImage != null) {
      await deleteFile(recipeImage);
      final recipeImageId = const Uuid().v1();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('recipe_images/$recipeImageId');
      await storageReference.putFile(selectedImage!);
      recipeImageUrl = await storageReference.getDownloadURL();
    } else {
      recipeImageUrl = recipeImage;
    }
    final String recipeId = widget.recipeDetails!.id;
    try {
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(recipeId)
          .update({
        'recipe_name': _recipeNameController.text,
        'recipe_about': _recipeAboutController.text,
        'recipe_category': categoryDropdownvalue,
        'recipe_ingredients': recipeIngredientsUpdatedList,
        'recipe_preparation_steps': recipePreparationStepsUpdatedList,
        'calories': _recipeCalorieController.text,
        'time': _recipeTimeController.text,
        'servings': _recipeServingsController.text,
        'recipe_image': recipeImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      print('Error updating document: $error');
    }
    recipeIngredientsUpdatedList.clear();
    recipePreparationStepsUpdatedList.clear();

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Recipe Updated"),
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
                        "Edit Recipe",
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
                                    color: Colors.white,
                                    style: BorderStyle.solid)),
                            child: TextField(
                              controller: _recipeNameController,
                              decoration: InputDecoration(
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: "Enter recipe name",
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16)),
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
                                    color: Colors.white,
                                    style: BorderStyle.solid)),
                            child: TextField(
                              controller: _recipeAboutController,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: "Enter a short description",
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16)),
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
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50)),
                                  border: Border.all(
                                      color: Colors.white,
                                      style: BorderStyle.solid)),
                              child: DropdownButton(
                                  value: categoryDropdownvalue,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(30)),
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
                                      ingredientNameArray
                                          .add(TextEditingController());
                                      ingredientQuantityArray
                                          .add(TextEditingController());
                                    });
                                  },
                                  child: const Text(
                                    "+ Add Ingredient",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
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
                                          left: 15,
                                          right: 15,
                                          top: 5,
                                          bottom: 5),
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
                                          left: 15,
                                          right: 15,
                                          top: 5,
                                          bottom: 5),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(50)),
                                          border: Border.all(
                                              color: Colors.white,
                                              style: BorderStyle.solid)),
                                      child: TextField(
                                        controller:
                                            ingredientQuantityArray[index],
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
                                              ingredientNameArray
                                                  .removeAt(index);
                                              ingredientQuantityArray
                                                  .removeAt(index);
                                            });
                                          },
                                          icon: const Icon(
                                              Icons.remove_circle_rounded),
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
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 14),
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
                                            left: 5,
                                            right: 5,
                                            top: 5,
                                            bottom: 5),
                                        padding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 5,
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(50)),
                                            border: Border.all(
                                                color: Colors.white,
                                                style: BorderStyle.solid)),
                                        child: TextField(
                                          controller:
                                              preparationStepsArray[index],
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
                                                preparationStepsArray
                                                    .removeAt(index);
                                              });
                                            },
                                            icon: const Icon(
                                                Icons.remove_circle_rounded),
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
                                          left: 10,
                                          right: 5,
                                          top: 10,
                                          bottom: 5),
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 5,
                                          top: 10,
                                          bottom: 5),
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
                                          left: 10,
                                          right: 5,
                                          top: 10,
                                          bottom: 5),
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
                                                    textAlign:
                                                        TextAlign.center)),
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
                                          left: 5,
                                          right: 5,
                                          top: 10,
                                          bottom: 5),
                                      padding: const EdgeInsets.only(
                                          left: 5,
                                          right: 5,
                                          top: 10,
                                          bottom: 5),
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
                                          left: 5,
                                          right: 5,
                                          top: 10,
                                          bottom: 5),
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
                                                    textAlign:
                                                        TextAlign.center)),
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
                                          left: 5,
                                          right: 10,
                                          top: 10,
                                          bottom: 5),
                                      padding: const EdgeInsets.only(
                                          left: 5,
                                          right: 10,
                                          top: 10,
                                          bottom: 5),
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
                                          left: 5,
                                          right: 10,
                                          top: 10,
                                          bottom: 5),
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
                                                    textAlign:
                                                        TextAlign.center)),
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
                          selectedImage == null
                              ? Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      border: Border.all(
                                          color: Colors.white,
                                          style: BorderStyle.solid)),
                                  child: InkWell(
                                      onTap: () async {
                                        final pickedImage = await pickImageC();
                                        setState(() {
                                          selectedImage = pickedImage;
                                        });
                                      },
                                      child: Image(
                                        image: NetworkImage(recipeImage),
                                      )))
                              : Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      border: Border.all(
                                          color: Colors.white,
                                          style: BorderStyle.solid)),
                                  child:
                                      Image(image: FileImage(selectedImage!))),
                          const SizedBox(
                            width: 300,
                            height: 50,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton(
                                onPressed: () {
                                  updateRecipe();
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.brown.shade600),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ))),
                                child: const Text(
                                  "Update Recipe",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                )),
                          ),
                        ]),
                      ),
                    ),
                  ]))),
    );
  }
}

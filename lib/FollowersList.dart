import 'package:flutter/material.dart';

class FollowersList extends StatefulWidget {
  const FollowersList({super.key});

  @override
  State<FollowersList> createState() => _FollowersListState();
}

class _FollowersListState extends State<FollowersList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage("assets/recipe_background.jpg"))),
        child: Column(
          children: [
            Container(
              width: 400,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(5),
              child: const Text(
                "Followers",
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                            color: Colors.white,
                            style: BorderStyle.solid)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            height: 40,
                            width: 40,
                            child: CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/green_salad.jpg'),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(10),
                            //width: 300,
                            child: const Text(
                                "Pooja Korah",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black)),
                          ),
                          ElevatedButton(
                            onPressed: (){},
                            child: const Text("Remove"),
                          )
                      ])
                    ),
                    Container(
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(
                            color: Colors.white,
                            style: BorderStyle.solid)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            height: 40,
                            width: 40,
                            child: CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/green_salad.jpg'),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(10),
                            //width: 300,
                            child: const Text(
                                "Pooja Korah",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black)),
                          ),
                          ElevatedButton(
                            onPressed: (){},
                            child: const Text("Remove"),
                          )
                      ])
                    ),
                  ]),
              ))
          ],
        ),
      )),
    );
  }
}
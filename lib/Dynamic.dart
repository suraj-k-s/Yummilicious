import 'package:flutter/material.dart';

class Dynamic extends StatefulWidget {
  @override
  DynamicState createState() => DynamicState();
}

class DynamicState extends State<Dynamic> {
  List<TextEditingController> controllers = [];
  List<FocusNode> focusNodes = [];

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void removeController(int index) {
    setState(() {
      controllers.removeAt(index);
      focusNodes.removeAt(index);
    });
  }

  void addController() {
    setState(() {
      final newController = TextEditingController();
      final newFocusNode = FocusNode();
      controllers.add(newController);
      focusNodes.add(newFocusNode);
      Future.delayed(Duration.zero, () {
        FocusScope.of(context).requestFocus(newFocusNode);
        if (newFocusNode.hasFocus) {
          FocusScope.of(context).requestFocus(newFocusNode);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dynamic TextFields'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: (){
              addController();
            },
            child: const Text('Add Controller'),
          ),
          // ElevatedButton(
          //   child: const Text('Remove Last Controller'),
          //   onPressed: () {
          //     setState(() {
          //       if (controllers.isNotEmpty) {
          //         controllers.removeLast();
          //         focusNodes.removeLast();
          //       }
          //     });
          //   },
          // ),
          // ElevatedButton(
          //   child: const Text('Print Controller Texts'),
          //   onPressed: () {
          //     for (var controller in controllers) {
          //       print(controller.text);
          //     }
          //   },
          // ),
          Expanded(
            child: FocusScope(
              child: ListView.builder(
                itemCount: controllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          showCursor: true,
                          controller: controllers[index],
                          focusNode: focusNodes[index],
                          autofocus: index == controllers.length - 1,
                          decoration: const InputDecoration(
                            labelText: 'Enter Text',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () {
                          removeController(index);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

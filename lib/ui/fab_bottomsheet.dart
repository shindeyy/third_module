import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class BottomSheetContent extends StatelessWidget {
  const BottomSheetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9, // Initial height ratio
      minChildSize: 0.1, // Minimum height ratio
      maxChildSize: 1.0, // Maximum height ratio
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Fluttertoast.showToast(
                        msg: "This is a Toast with Title",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    },
                    child: const Text('Show Toast Button'),
                  ),
                  ...List.generate(25, (index) {
                    return ListTile(
                      title: Text('Item $index'),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
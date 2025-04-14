import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/constant.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({super.key});

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool isFavourite = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(children: [
      SizedBox(
        width: screenWidth,
        height: 400,
        child: Image.asset(
          "assets/images/photo_1_2025-02-05_02-18-53.jpg",
          fit: BoxFit.cover,
        ),
      ),
      Positioned(
        left: 350,
        top: 40,
        child: SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            icon: Icon(
              Icons.favorite,
              color: isFavourite ? Colors.red : Colors.white,
              size: 40,
            ),
            onPressed: () {
              showSnackbar(context, "Added To FAV Successfully");
              isFavourite = !isFavourite;
              setState(() {});
            },
          ),
        ),
      ),
      Positioned(
          left: 25,
          top: 40,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back)),
          ))
    ]);
  }
}

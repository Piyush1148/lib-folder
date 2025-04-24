import 'package:flutter/material.dart';

import 'package:furnituresapp/utils/constants.dart';

class ProductPoster extends StatelessWidget {
  const ProductPoster({
    Key? key,  // Make key nullable
    required this.size,  // Use required instead of @required
    this.image,
  }) : super(key: key);

  final Size size;
  final String? image;  // Make image nullable

  @override
  Widget build(BuildContext context) {
    // Make image size responsive based on screen size
    final double containerHeight = size.width < 360 
        ? size.width * 0.7 
        : size.width * 0.8;
    final double imageHeight = containerHeight * 0.95;
    final double circleHeight = containerHeight * 0.85;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: kDefaultPadding),
      height: containerHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            height: circleHeight,
            width: circleHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
          Image.asset(
            image ?? '',
            height: imageHeight,
            width: imageHeight,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: imageHeight,
                width: imageHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey[400],
                    size: size.width * 0.15,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
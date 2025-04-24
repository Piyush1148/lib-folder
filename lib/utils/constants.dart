import 'package:flutter/material.dart';

// Colors
const Color kBackgroundColor = Color(0xFFF1EFF1);
const Color kPrimaryColor = Color(0xFF035AA6);
const Color kSecondaryColor = Color(0xFFFFA41B);
const Color kTextColor = Color(0xFF000839);
const Color kTextLightColor = Color(0xFF747474);
const Color kBlueColor = Color(0xFF40BAD5);

// Padding and Dimensions
const double kDefaultPadding = 20.0;

// Shadows
const kDefaultShadow = BoxShadow(
  offset: Offset(0, 15),
  blurRadius: 27,
  color: Colors.black12, // Black color with 12% opacity
);

// API and App Constants
class AppConstants {
  static const String apiKey = 'msy_8ZVUoquxHE6iFtHabUDzx2CVmBRKIP3Yat9A';
  static const String baseUrl = 'https://api.meshy.ai/openapi/v1';
  static const String appName = 'Meshy 3D Generator';
}
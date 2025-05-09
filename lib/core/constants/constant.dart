import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/product_model.dart';

import 'package:graduation_project/Models/subcateoery_model.dart';

const Color pkColor = Color(0xff3B8FDA);
const String Kpmessages = "messages";
final String baseUri = 'https://10.0.2.2:7273/api/';

// final String baseUri = 'http://192.168.137.1:7273/api/';

final List<String> specialties = [
  'General Internal Medicine',
  'Cardiology',
  'Gastroenterology & Hepatology',
  'Nephrology & Urology',
  'Endocrinology & Diabetes',
  'Rheumatology & Immunology',
];

void showSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(content: Text(message));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

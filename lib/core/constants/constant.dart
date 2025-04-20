import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/product_model.dart';

import 'package:graduation_project/Models/subcateoery_model.dart';

const Color pkColor = Color(0xff3B8FDA);

final String baseUri = 'https://10.0.2.2:7273/api/';
// ✅ List of Categories
// List<Category> categories = [
//   Category(
//     categoryId: 1,
//     name: "Furniture",
//     description:
//         "Furniture for hospitals and healthcare settings, including beds, tables, and cabinets.",
//     subCategories: [],
//     products: [],
//   ),
//   Category(
//     categoryId: 2,
//     name: "Physical Therapy Equipment",
//     description:
//         "A collection of equipment used in physical therapy treatments such as exercise machines and tools.",
//     subCategories: [],
//     products: [],
//   ),
//   Category(
//     categoryId: 3,
//     name: "Specialties",
//     description:
//         "Medical equipment and tools used in specialized fields like orthopedics, cardiology, and neurology.",
//     subCategories: [],
//     products: [],
//   ),
//   Category(
//     categoryId: 4,
//     name: "Medical Devices",
//     description:
//         "A range of medical devices, including blood pressure monitors, glucose monitors, and thermometers.",
//     subCategories: [],
//     products: [],
//   ),
//   Category(
//     categoryId: 5,
//     name: "Home Care Equipment",
//     description:
//         "Equipment designed to support home care needs such as wheelchairs, oxygen concentrators, and mobility aids.",
//     subCategories: [],
//     products: [],
//   ),
// ];

// ✅ List of SubCategories
// List<SubCategory> subCategories = [
//   // Furniture
//   SubCategory(
//     subCategoryId: 1,
//     categoryId: 1,
//     name: "Patients Room",
//     description:
//         "Furniture designed specifically for patient rooms, including hospital beds and bedside tables.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 2,
//     categoryId: 1,
//     name: "Surgical Operating Room",
//     description:
//         "Furniture used in surgical operating rooms, such as surgical tables and instrument trolleys.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 3,
//     categoryId: 1,
//     name: "Intensive Care Room",
//     description:
//         "Equipment and furniture designed for intensive care units (ICU), including specialized beds and monitors.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 4,
//     categoryId: 1,
//     name: "Reception Area",
//     description:
//         "Furniture designed for reception areas in healthcare facilities, including waiting chairs and counters.",
//     products: [],
//   ),

//   // Physical Therapy Equipment
//   SubCategory(
//     subCategoryId: 5,
//     categoryId: 2,
//     name: "Massage Devices",
//     description:
//         "Devices used for massage therapy, such as massagers and vibration tools.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 6,
//     categoryId: 2,
//     name: "Exercise Equipment",
//     description:
//         "Equipment used for rehabilitation exercises, including treadmills and resistance bands.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 7,
//     categoryId: 2,
//     name: "Electrotherapy Machines",
//     description:
//         "Machines used for electrotherapy treatments, including electrical stimulators and pain relief devices.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 8,
//     categoryId: 2,
//     name: "Rehabilitation Tools",
//     description:
//         "Tools used in the rehabilitation process, such as balance boards and therapy balls.",
//     products: [],
//   ),

//   // Specialties
//   SubCategory(
//     subCategoryId: 9,
//     categoryId: 3,
//     name: "Orthopedic Equipment",
//     description:
//         "Medical equipment related to orthopedics, such as braces and orthopedic beds.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 10,
//     categoryId: 3,
//     name: "Cardiology Equipment",
//     description:
//         "Medical devices used in cardiology, such as ECG machines and heart rate monitors.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 11,
//     categoryId: 3,
//     name: "Neurology Equipment",
//     description:
//         "Medical tools and equipment used in neurology, including EEG machines and nerve stimulators.",
//     products: [],
//   ),

//   // Medical Devices
//   SubCategory(
//     subCategoryId: 12,
//     categoryId: 4,
//     name: "Blood Pressure Monitors",
//     description:
//         "Devices used to measure blood pressure, including automatic and manual monitors.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 13,
//     categoryId: 4,
//     name: "Blood Sugar Monitors",
//     description:
//         "Devices for monitoring blood sugar levels, including glucose meters and testing strips.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 14,
//     categoryId: 4,
//     name: "Thermometers",
//     description:
//         "Medical thermometers for measuring body temperature, including digital and infrared models.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 15,
//     categoryId: 4,
//     name: "Patient Monitors",
//     description:
//         "Monitors used for tracking patient vitals, including heart rate, blood pressure, and oxygen levels.",
//     products: [],
//   ),

//   // Home Care Equipment
//   SubCategory(
//     subCategoryId: 16,
//     categoryId: 5,
//     name: "Wheelchairs",
//     description:
//         "Wheelchairs designed for home use, including foldable and electric models.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 17,
//     categoryId: 5,
//     name: "Oxygen Concentrators",
//     description:
//         "Devices that concentrate oxygen from the air for patients requiring supplemental oxygen.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 18,
//     categoryId: 5,
//     name: "First Aid Kits",
//     description:
//         "Comprehensive kits containing medical supplies for first aid in emergencies.",
//     products: [],
//   ),
//   SubCategory(
//     subCategoryId: 19,
//     categoryId: 5,
//     name: "Mobility Aids",
//     description:
//         "Devices that help with movement and mobility, including walkers and canes.",
//     products: [],
//   ),
// ];

// // ✅ List of Products
// List<ProductModel> products = [
//   // Furniture - Patients Room
//   ProductModel(
//     productId: 1,
//     name: "Adjustable Hospital Bed",
//     description:
//         "A hospital-grade bed that can be adjusted for patient comfort and care.",
//     price: 1200.00,
//     isNew: true,
//     discount: 3,
//     categoryId: 1,
//     subCategoryId: 1,
//     userId: 1,
//     image: "assets/images/bone1.jpg",
//   ),
//   ProductModel(
//     productId: 2,
//     name: "Bedside Cabinet",
//     description:
//         "A cabinet placed next to a patient's bed for storing personal items and medical supplies.",
//     price: 299.99,
//     isNew: true,
//     discount: 3,
//     categoryId: 1,
//     subCategoryId: 1,
//     userId: 2,
//     image: "assets/images/bone1.jpg",
//   ),
//   ProductModel(
//     productId: 3,
//     name: "Patient Overbed Table",
//     description:
//         "A table that can be placed over a patient's bed for eating or working.",
//     price: 199.99,
//     isNew: true,
//     discount: 3,
//     categoryId: 1,
//     subCategoryId: 1,
//     userId: 1,
//     image: "assets/images/bone1.jpg",
//   ),

//   // Furniture - Surgical Operating Room
//   ProductModel(
//     productId: 4,
//     name: "Surgical Table",
//     description:
//         "A table designed for surgical procedures, providing comfort and support for the patient.",
//     price: 3500.00,
//     isNew: true,
//     discount: 4,
//     categoryId: 1,
//     subCategoryId: 2,
//     userId: 1,
//     image: "assets/images/bone1.jpg",
//   ),
//   ProductModel(
//     productId: 5,
//     name: "Surgical Instrument Trolley",
//     description:
//         "A mobile trolley designed for holding and organizing surgical instruments.",
//     price: 799.99,
//     isNew: true,
//     discount: 3,
//     categoryId: 1,
//     subCategoryId: 2,
//     userId: 1,
//     image: "assets/images/bone1.jpg",
//   ),
//   ProductModel(
//     productId: 6,
//     name: "LED Surgical Light",
//     description:
//         "An advanced LED light used in surgical environments for clear visibility during procedures.",
//     price: 2500.00,
//     isNew: true,
//     discount: 3,
//     categoryId: 1,
//     subCategoryId: 2,
//     userId: 1,
//     image: "assets/images/bone1.jpg",
//   ),

//   // Physical Therapy - Exercise Equipment
//   ProductModel(
//     productId: 7,
//     name: "Resistance Bands",
//     description:
//         "Elastic bands used in physical therapy for strength training and rehabilitation exercises.",
//     price: 29.99,
//     isNew: true,
//     discount: 3,
//     categoryId: 2,
//     subCategoryId: 6,
//     userId: 1,
//     image: "assets/images/bone1.jpg",
//   ),
//   ProductModel(
//     productId: 8,
//     name: "Treadmill for Rehab",
//     description:
//         "A treadmill designed for use in physical therapy for rehabilitation and strength building.",
//     price: 1500.00,
//     isNew: true,
//     discount: 3,
//     categoryId: 2,
//     subCategoryId: 6,
//     userId: 1,
//     image: "assets/images/bone1.jpg",
//   ),
//   ProductModel(
//     productId: 9,
//     name: "Balance Board",
//     description:
//         "A balance board used to improve stability and coordination during physical therapy.",
//     price: 59.99,
//     isNew: true,
//     discount: 3,
//     categoryId: 2,
//     subCategoryId: 6,
//     userId: 1,
//     image: "assets/images/bone1.jpg",
//   ),

//   // Medical Devices - Blood Pressure Monitors
//   ProductModel(
//     productId: 10,
//     name: "Automatic Blood Pressure Monitor",
//     description:
//         "An automatic device for measuring blood pressure with easy-to-read results.",
//     price: 69.99,
//     isNew: true,
//     discount: 3,
//     categoryId: 3,
//     subCategoryId: 12,
//     userId: 1,
//     image: "assets/images/bone1.jpg",
//   ),
//   ProductModel(
//     productId: 11,
//     name: "Manual Sphygmomanometer",
//     description:
//         "A manual blood pressure cuff used by healthcare professionals for accurate readings.",
//     price: 49.99,
//     isNew: true,
//     discount: 3,
//     categoryId: 3,
//     subCategoryId: 12,
//     userId: 1,
//     image: "assets/images/bone1.jpg",
//   ),

//   // Home Care - Wheelchairs
//   ProductModel(
//     productId: 12,
//     name: "Foldable Wheelchair",
//     description:
//         "A lightweight wheelchair that can be easily folded for storage and transport.",
//     price: 800.00,
//     isNew: true,
//     discount: 3,
//     categoryId: 4,
//     subCategoryId: 16,
//     userId: 1,
//     image: "assets/images/bone1.jpg",
//   ),
//   ProductModel(
//     productId: 13,
//     name: "Electric Wheelchair",
//     description:
//         "An electric-powered wheelchair for individuals with mobility issues.",
//     price: 2500.00,
//     isNew: true,
//     discount: 3,
//     categoryId: 4,
//     subCategoryId: 16,
//     userId: 1,
//     image: "assets/images/bone1.jpg",
//   ),
// ];

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

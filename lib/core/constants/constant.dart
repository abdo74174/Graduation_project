import 'dart:ui';
import 'package:graduation_project/Models/product_model.dart';

const Color pkColor = Color(0xff3B8FDA);

final List<Product> products = [
  // Furniture - Patients Room
  Product(
      id: 1,
      categoryId: 1,
      subCategoryId: 1,
      name: "Adjustable Hospital Bed",
      price: 1200.00,
      quantity: 2),
  Product(
      id: 2,
      categoryId: 1,
      subCategoryId: 1,
      name: "Bedside Cabinet",
      price: 299.99,
      quantity: 5),
  Product(
      id: 3,
      categoryId: 1,
      subCategoryId: 1,
      name: "Patient Overbed Table",
      price: 199.99,
      quantity: 3),

  // Furniture - Surgical Operating Room
  Product(
      id: 4,
      categoryId: 1,
      subCategoryId: 2,
      name: "Surgical Table",
      price: 3500.00,
      quantity: 2),
  Product(
      id: 5,
      categoryId: 1,
      subCategoryId: 2,
      name: "Surgical Instrument Trolley",
      price: 799.99,
      quantity: 4),
  Product(
      id: 6,
      categoryId: 1,
      subCategoryId: 2,
      name: "LED Surgical Light",
      price: 2500.00,
      quantity: 3),

  // Physical Therapy - Exercise Equipment
  Product(
      id: 14,
      categoryId: 2,
      subCategoryId: 6,
      name: "Resistance Bands",
      price: 29.99,
      quantity: 10),
  Product(
      id: 15,
      categoryId: 2,
      subCategoryId: 6,
      name: "Treadmill for Rehab",
      price: 1500.00,
      quantity: 2),
  Product(
      id: 16,
      categoryId: 2,
      subCategoryId: 6,
      name: "Balance Board",
      price: 59.99,
      quantity: 6),

  // Medical Devices - Blood Pressure Monitors
  Product(
      id: 23,
      categoryId: 3,
      subCategoryId: 12,
      name: "Automatic Blood Pressure Monitor",
      price: 69.99,
      quantity: 8),
  Product(
      id: 24,
      categoryId: 3,
      subCategoryId: 12,
      name: "Manual Sphygmomanometer",
      price: 49.99,
      quantity: 7),

  // Home Care - Wheelchairs
  Product(
      id: 29,
      categoryId: 4,
      subCategoryId: 16,
      name: "Foldable Wheelchair",
      price: 800.00,
      quantity: 4),
  Product(
      id: 30,
      categoryId: 4,
      subCategoryId: 16,
      name: "Electric Wheelchair",
      price: 2500.00,
      quantity: 2),
];

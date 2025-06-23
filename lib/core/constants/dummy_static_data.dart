import 'dart:typed_data';
import 'package:graduation_project/Models/cart_item.dart';
import 'package:graduation_project/Models/cart_model.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/favourite_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/Models/user_model.dart';

const String defaultProductImage = "assets/images/equip2.png";
const String defaultCategoryImage = "assets/images/category.jpg";
const String defaultSubCategoryImage = "assets/images/category.jpg";
// Dummy Products
final dummyProducts = [
  ProductModel(
    productId: 1,
    installmentAvailable: false,
    address: "sohag",
    name: "Blood Pressure Monitor",
    description: "Digital device with cuff and memory storage.",
    price: 450.0,
    donation: false,
    isNew: true,
    isDeleted: false,
    discount: 10.0,
    subCategoryId: 1,
    categoryId: 1,
    StockQuantity: 30,
    userId: 1,
    images: [],
  ),
  ProductModel(
    installmentAvailable: false,
    productId: 2,
    name: "Infrared Thermometer",
    description: "Non-contact, quick-reading thermometer.",
    price: 299.0,
    isNew: false,
    isDeleted: false,
    donation: false,
    discount: 5.0,
    subCategoryId: 2,
    address: "sohag",
    categoryId: 1,
    StockQuantity: 50,
    userId: 2,
    images: [],
  ),
];

// Dummy Cart Items
final dummyCartItems = [
  CartItems(
    id: 1,
    cartId: 1,
    productId: dummyProducts[0].productId,
    quantity: 2,
    product: dummyProducts[0],
  ),
  CartItems(
    id: 2,
    cartId: 1,
    productId: dummyProducts[1].productId,
    quantity: 1,
    product: dummyProducts[1],
  ),
];

// Dummy Cart
final dummyCart = CartModel(
  id: 1,
  userId: "user_123",
  cartItems: dummyCartItems,
);

// Dummy Subcategories

// Dummy Subcategories
final dummySubCategories = [
  SubCategory(
    subCategoryId: 1,
    name: "Monitors",
    description: "Monitoring devices",
    image: defaultSubCategoryImage,
    categoryId: 1,
    products: [dummyProducts[0]],
  ),
  SubCategory(
    subCategoryId: 2,
    name: "Thermometers",
    description: "Body temperature measurement tools",
    image: SubCategory.defaultSubCategoryImage,
    categoryId: 1,
    products: [dummyProducts[1]],
  ),
];

// Dummy Categories
final dummyCategories = [
  CategoryModel(
    categoryId: 1,
    name: "Medical Devices",
    description: "Tools for monitoring and diagnostics.",
    subCategories: dummySubCategories,
    products: dummyProducts,
  ),
  CategoryModel(
    categoryId: 2,
    name: "Physical Therapy",
    description: "Equipments for home physical treatment.",
    subCategories: [],
    products: [],
  ),
];
// Dummy Favourites
final dummyFavourites = [
  Favourite(
    id: 1,
    userId: "user_123",
    productId: dummyProducts[0].productId,
    product: dummyProducts[0],
  ),
  Favourite(
    id: 2,
    userId: "user_123",
    productId: dummyProducts[1].productId,
    product: dummyProducts[1],
  ),
];

// Dummy Users
final dummyUsers = [
  UserModel(
    status: UserStatus.active,
    kindOfWork: "docto",
    isAdmin: false,
    id: 1,
    name: "Dr. Sarah",
    email: "user@gmail.com",
    password: "user",
    confirmPassword: null,
    resetToken: null,
    resetTokenExpires: null,
    phone: "123456789",
    medicalSpecialist: "Cardiologist",
    address: "Cairo",
    profileImage: null,
    createdAt: DateTime.now(),
    products: [dummyProducts[0]],
    contactUsMessages: [],
  ),
  UserModel(
    status: UserStatus.active,
    kindOfWork: "docto",
    isAdmin: true,
    id: 2,
    name: "admin",
    email: "admin@gmail.com",
    password: "admin",
    confirmPassword: null,
    resetToken: null,
    resetTokenExpires: null,
    phone: "987654321",
    medicalSpecialist: "Pharmacist",
    address: "Alexandria",
    profileImage: null,
    createdAt: DateTime.now(),
    products: [dummyProducts[1]],
    contactUsMessages: [],
  ),
];

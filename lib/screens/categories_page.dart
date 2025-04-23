import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/components/category/Category_view.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/components/category/subcategory.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/product_page.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, this.id});
  final int? id;

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int? selectedCategoryId;
  int? selectedSubCategoryId;
  List<CategoryModel> categories = [];
  List<SubCategory> subcategories = [];
  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();

    // Using the dummy data instead of fetching from a service
    setState(() {
      categories = dummyCategories;
      subcategories = dummySubCategories;
      products = dummyProducts;
    });

    if (widget.id != null) {
      selectedCategoryId = widget.id! + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<SubCategory> filteredSubCategories = selectedCategoryId == null
        ? []
        : subcategories
            .where((sub) => sub.categoryId == selectedCategoryId)
            .toList();

    List<ProductModel> filteredProducts = selectedSubCategoryId == null
        ? []
        : products
            .where((prod) => prod.subCategoryId == selectedSubCategoryId)
            .toList();

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Color(0xFFF5F5F5),
        title: Text(
          "Categories",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Color(0xFF1A1A1A)),
        ),
        centerTitle: true,
      ),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 170,
                    width: double.infinity,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return CategoryView(
                          borderColor:
                              categories[index].categoryId == selectedCategoryId
                                  ? Colors.blue
                                  : isDark
                                      ? Colors.white
                                      : Colors.black,
                          category: categories[index],
                          onTap: () {
                            setState(() {
                              selectedCategoryId = categories[index].categoryId;
                              selectedSubCategoryId = null;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Divider(
                      color: isDark ? Colors.white : Colors.grey,
                      thickness: 0.5),
                  Center(
                    child: Text(
                      "SubCategory",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Color(0xFF1A1A1A)),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (filteredSubCategories.isNotEmpty)
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredSubCategories.length,
                        itemBuilder: (context, index) {
                          return SubCategoryView(
                            borderColor:
                                filteredSubCategories[index].subCategoryId ==
                                        selectedSubCategoryId
                                    ? Colors.blue
                                    : isDark
                                        ? Colors.white
                                        : Colors.black,
                            subCategory: filteredSubCategories[index],
                            onTap: () {
                              setState(() {
                                selectedSubCategoryId =
                                    filteredSubCategories[index].subCategoryId;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 520,
                    child: filteredProducts.isNotEmpty
                        ? GridView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              return ProductCard(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ProductPage(
                                          product: filteredProducts[index],
                                        );
                                      },
                                    ),
                                  );
                                },
                                product: filteredProducts[index],
                              );
                            },
                          )
                        : selectedSubCategoryId == null
                            ? Center(
                                child: Text(
                                  "Choose a subcategory",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 24),
                                ),
                              )
                            : Center(child: Text("No products available")),
                  ),
                ],
              ),
            ),
    );
  }
}

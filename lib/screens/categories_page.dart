import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/components/category/Category_view.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/components/category/subcategory.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/services/Product/category_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:graduation_project/services/Product/subcategory_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, this.id});
  final int? id;

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int? selectedCategoryId;
  int? selectedSubCategoryId;
  List<CategoryModel> categories = []; // Typed categories list
  List<SubCategory> subcategories = []; // Correctly typed list of SubCategory
  List<ProductModel> products = []; // List of products

  @override
  void initState() {
    super.initState();

    // Fetch categories
    CategoryService().fetchAllCategories().then((fetchedCategories) {
      setState(() {
        categories = fetchedCategories;
      });
    });

    // Fetch subcategories
    SubCategoryService().fetchAllSubCategories().then((fetchedSubCategories) {
      setState(() {
        subcategories = fetchedSubCategories; // Properly typed list
      });
    });

    // Fetch products (assume this function is available)
    ProductService().fetchAllProducts().then((fetchedProducts) {
      setState(() {
        products = fetchedProducts;
      });
    });

    setState(() {});

    // Set the selected category ID if available from the widget
    if (widget.id != null) {
      selectedCategoryId = widget.id! + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter subcategories based on the selected category
    List<SubCategory> filteredSubCategories = selectedCategoryId == null
        ? []
        : subcategories
            .where((sub) => sub.categoryId == selectedCategoryId)
            .toList();

    // Filter products based on the selected subcategory
    List<ProductModel> filteredProducts = selectedSubCategoryId == null
        ? []
        : products
            .where((prod) => prod.subCategoryId == selectedSubCategoryId)
            .toList();

    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xffFFFFFF),
        title: Text(
          "Categories",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Categories List
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
                                  : Colors.black,
                          category: categories[index],
                          onTap: () {
                            setState(() {
                              selectedCategoryId = categories[index].categoryId;
                              selectedSubCategoryId =
                                  null; // Reset selected subcategory
                            });
                          },
                        );
                      },
                    ),
                  ),

                  Divider(color: Colors.grey, thickness: .5),

                  Center(
                    child: Text(
                      "SubCategory",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),

                  SizedBox(height: 10),

                  // SubCategories List
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

                  // Products Grid
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

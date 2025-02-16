import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/components/Category_view.dart';
import 'package:graduation_project/components/product.dart';
import 'package:graduation_project/components/subcategory.dart';
import 'package:graduation_project/screens/product_page.dart';

List<Category> categories = [
  Category(id: 1, name: "Furniture"),
  Category(id: 2, name: "Physical Therapy Equipment"),
  Category(id: 3, name: "Specialties"),
  Category(id: 4, name: "Medical Devices"),
  Category(id: 5, name: "Home Care Equipment"),
];

List<SubCategory> subCategories = [
  // Furniture
  SubCategory(id: 1, categoryId: 1, name: "Patients Room"),
  SubCategory(id: 2, categoryId: 1, name: "Surgical Operating Room"),
  SubCategory(id: 3, categoryId: 1, name: "Intensive Care Room"),
  SubCategory(id: 4, categoryId: 1, name: "Reception Area"),

  // Physical Therapy Equipment
  SubCategory(id: 5, categoryId: 2, name: "Massage Devices"),
  SubCategory(id: 6, categoryId: 2, name: "Exercise Equipment"),
  SubCategory(id: 7, categoryId: 2, name: "Electrotherapy Machines"),
  SubCategory(id: 8, categoryId: 2, name: "Rehabilitation Tools"),

  // Specialties
  SubCategory(id: 9, categoryId: 3, name: "Orthopedic Equipment"),
  SubCategory(id: 10, categoryId: 3, name: "Cardiology Equipment"),
  SubCategory(id: 11, categoryId: 3, name: "Neurology Equipment"),

  // Medical Devices
  SubCategory(id: 12, categoryId: 4, name: "Blood Pressure Monitors"),
  SubCategory(id: 13, categoryId: 4, name: "Blood Sugar Monitors"),
  SubCategory(id: 14, categoryId: 4, name: "Thermometers"),
  SubCategory(id: 15, categoryId: 4, name: "Patient Monitors"),

  // Home Care Equipment
  SubCategory(id: 16, categoryId: 5, name: "Wheelchairs"),
  SubCategory(id: 17, categoryId: 5, name: "Oxygen Concentrators"),
  SubCategory(id: 18, categoryId: 5, name: "First Aid Kits"),
  SubCategory(id: 19, categoryId: 5, name: "Mobility Aids"),
];
// admin 



// user 



// merchant 

List<Product> products = [
  // Furniture - Patients Room
  Product(
      id: 1, subCategoryId: 1, name: "Adjustable Hospital Bed", price: 1200.00),
  Product(id: 2, subCategoryId: 1, name: "Bedside Cabinet", price: 299.99),
  Product(
      id: 3, subCategoryId: 1, name: "Patient Overbed Table", price: 199.99),
  Product(
      id: 4, subCategoryId: 1, name: "Adjustable Hospital Bed", price: 1200.00),
  Product(id: 2, subCategoryId: 1, name: "Bedside Cabinet", price: 299.99),
  Product(
      id: 5, subCategoryId: 1, name: "Patient Overbed Table", price: 199.99),

  // Furniture - Surgical Operating Room
  Product(id: 6, subCategoryId: 2, name: "Surgical Table", price: 3500.00),
  Product(
      id: 5,
      subCategoryId: 2,
      name: "Surgical Instrument Trolley",
      price: 799.99),
  Product(id: 6, subCategoryId: 2, name: "LED Surgical Light", price: 2500.00),

  // Furniture - Intensive Care Room
  Product(id: 7, subCategoryId: 3, name: "ICU Ventilator", price: 5000.00),
  Product(
      id: 8,
      subCategoryId: 3,
      name: "Multi-Parameter ICU Monitor",
      price: 4200.00),

  // Furniture - Reception Area
  Product(
      id: 9, subCategoryId: 4, name: "Medical Reception Desk", price: 1500.00),
  Product(id: 10, subCategoryId: 4, name: "Waiting Room Chairs", price: 500.00),

  // Physical Therapy - Massage Devices
  Product(id: 11, subCategoryId: 5, name: "Handheld Massager", price: 99.99),
  Product(
      id: 12, subCategoryId: 5, name: "Shiatsu Back Massager", price: 149.99),
  Product(
      id: 13,
      subCategoryId: 5,
      name: "Foot Reflexology Machine",
      price: 199.99),

  // Physical Therapy - Exercise Equipment
  Product(id: 14, subCategoryId: 6, name: "Resistance Bands", price: 29.99),
  Product(
      id: 15, subCategoryId: 6, name: "Treadmill for Rehab", price: 1500.00),
  Product(id: 16, subCategoryId: 6, name: "Balance Board", price: 59.99),

  // Physical Therapy - Electrotherapy
  Product(id: 17, subCategoryId: 7, name: "TENS Machine", price: 150.00),
  Product(
      id: 18,
      subCategoryId: 7,
      name: "Ultrasound Therapy Device",
      price: 300.00),

  // Specialties - Orthopedic Equipment
  Product(id: 19, subCategoryId: 9, name: "Knee Brace", price: 79.99),
  Product(
      id: 20, subCategoryId: 9, name: "Adjustable Back Support", price: 129.99),

  // Specialties - Cardiology Equipment
  Product(id: 21, subCategoryId: 10, name: "ECG Machine", price: 1500.00),
  Product(
      id: 22,
      subCategoryId: 10,
      name: "Portable Defibrillator",
      price: 2000.00),

  // Medical Devices - Blood Pressure Monitors
  Product(
      id: 23,
      subCategoryId: 12,
      name: "Automatic Blood Pressure Monitor",
      price: 69.99),
  Product(
      id: 24, subCategoryId: 12, name: "Manual Sphygmomanometer", price: 49.99),

  // Medical Devices - Blood Sugar Monitors
  Product(id: 25, subCategoryId: 13, name: "Digital Glucometer", price: 49.99),
  Product(
      id: 26,
      subCategoryId: 13,
      name: "Continuous Glucose Monitor",
      price: 249.99),

  // Medical Devices - Thermometers
  Product(
      id: 27, subCategoryId: 14, name: "Infrared Thermometer", price: 39.99),
  Product(
      id: 28, subCategoryId: 14, name: "Digital Ear Thermometer", price: 29.99),

  // Home Care - Wheelchairs
  Product(
      id: 29, subCategoryId: 16, name: "Foldable Wheelchair", price: 800.00),
  Product(
      id: 30, subCategoryId: 16, name: "Electric Wheelchair", price: 2500.00),

  // Home Care - Oxygen Concentrators
  Product(
      id: 31,
      subCategoryId: 17,
      name: "Portable Oxygen Concentrator",
      price: 1800.00),
  Product(
      id: 32,
      subCategoryId: 17,
      name: "Stationary Oxygen Concentrator",
      price: 2200.00),

  // Home Care - First Aid Kits
  Product(id: 33, subCategoryId: 18, name: "Basic First Aid Kit", price: 49.99),
  Product(
      id: 34, subCategoryId: 18, name: "Advanced Trauma Kit", price: 129.99),

  // Home Care - Mobility Aids
  Product(
      id: 35, subCategoryId: 19, name: "Adjustable Walking Cane", price: 39.99),
  Product(id: 36, subCategoryId: 19, name: "Walker with Wheels", price: 150.00),
];

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, this.id});
  final int? id;
  @override
  // ignore: library_private_types_in_public_api
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int? selectedCategoryId;
  int? selectedSubCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      selectedCategoryId = (widget.id! + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<SubCategory> filteredSubCategories = selectedCategoryId == null
        ? []
        : subCategories
            .where((sub) => sub.categoryId == selectedCategoryId)
            .toList();

    List<Product> filteredProducts = selectedSubCategoryId == null
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
      body: SingleChildScrollView(
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
                    borderColor: categories[index].id == selectedCategoryId
                        ? Colors.blue
                        : Colors.black,
                    category: categories[index],
                    onTap: () {
                      setState(() {
                        selectedCategoryId = categories[index].id;
                        selectedSubCategoryId = null;
                      });
                    },
                  );
                },
              ),
            ),

            Divider(
              color: Colors.grey,
              thickness: .5,
            ),

            Center(
                child: Text(
              "SubCategory",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),

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
                      borderColor: filteredSubCategories[index].id ==
                              selectedSubCategoryId
                          ? Colors.blue
                          : Colors.black,
                      subCategory: filteredSubCategories[index],
                      onTap: () {
                        setState(() {
                          selectedSubCategoryId =
                              filteredSubCategories[index].id;
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ProductPage();
                              }));
                            },
                            product: filteredProducts[index]);
                      },
                    )
                  : selectedSubCategoryId == null
                      ? Center(
                          child: Text(
                          "Choose a subcategory ",
                          style: TextStyle(color: Colors.blue, fontSize: 24),
                        ))
                      : Center(child: Text("No products available")),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdminProductReviewScreen extends StatefulWidget {
  const AdminProductReviewScreen({super.key});

  @override
  _AdminProductReviewScreenState createState() =>
      _AdminProductReviewScreenState();
}

class _AdminProductReviewScreenState extends State<AdminProductReviewScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUri));
  List<ProductModel> _pendingProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPendingProducts();
  }

  Future<void> _fetchPendingProducts() async {
    setState(() => _isLoading = true);
    try {
      print('Fetching pending products from: ${baseUri}Product/pending');
      final response = await _dio.get('Product/pending');
      print(
          'Pending products response: ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data as List;
        setState(() {
          _pendingProducts =
              data.map((item) => ProductModel.fromJson(item)).toList();
        });
        print('Loaded ${_pendingProducts.length} pending products');
      } else {
        print(
            'Error: Failed to load pending products, status: ${response.statusCode}');
        _showSnackbar('Failed to load pending products');
      }
    } catch (e, stackTrace) {
      print('Error fetching pending products: $e\n$stackTrace');
      _showSnackbar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProductStatus(int productId, String status) async {
    try {
      print('Updating product $productId to status: $status');
      final response = await _dio.put(
        'Product/approve/$productId',
        data: {'Status': status},
      );
      print('Update status response: ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        _showSnackbar('Product $status successfully');
        setState(() {
          _pendingProducts
              .removeWhere((product) => product.productId == productId);
        });
        print('Product $productId removed from pending list');
      } else {
        print(
            'Error: Failed to update product status, status: ${response.statusCode}');
        _showSnackbar('Failed to update product status');
      }
    } catch (e, stackTrace) {
      print('Error updating product status: $e\n$stackTrace');
      _showSnackbar('Error: $e');
    }
  }

  void _showSnackbar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message.tr())));
    } else {
      print('Error: Context not mounted for SnackBar: $message');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Review Products'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.white,
          ),
        ),
        backgroundColor: isDark ? theme.appBarTheme.backgroundColor : pkColor,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : _pendingProducts.isEmpty
              ? Center(
                  child: Text(
                    'No pending products to review'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingProducts.length,
                  itemBuilder: (context, index) {
                    final product = _pendingProducts[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${'Price:'.tr()} \$${product.price}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${'Quantity:'.tr()} ${product.StockQuantity}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (product.images.isNotEmpty)
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: product.images.length,
                                  itemBuilder: (context, imgIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          imageUrl: product.images[imgIndex],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) {
                                            print(
                                                'Error loading image: $url, $error');
                                            return Icon(Icons.error,
                                                color: Colors.red);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _updateProductStatus(
                                      product.productId, 'Approved'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('Approve'.tr()),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _updateProductStatus(
                                      product.productId, 'Rejected'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('Reject'.tr()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

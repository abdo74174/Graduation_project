import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/screens/delivery/delivery_person_profile_page.dart';
import 'package:graduation_project/services/elivery_person_service.dart'; // Fixed import

class DeliveryPersonRequestPage extends StatefulWidget {
  final int userId;
  const DeliveryPersonRequestPage({Key? key, required this.userId})
      : super(key: key);

  @override
  _DeliveryPersonRequestPageState createState() =>
      _DeliveryPersonRequestPageState();
}

class _DeliveryPersonRequestPageState extends State<DeliveryPersonRequestPage> {
  final DeliveryPersonService _deliveryPersonService = DeliveryPersonService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _showInstructions = false;
  String? _requestStatus;

  @override
  void initState() {
    super.initState();
    print('DeliveryPersonRequestPage: userId = ${widget.userId}');
    _checkExistingRequest();
  }

  Future<void> _checkExistingRequest() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final requests = await _deliveryPersonService.getAllRequests();
      print('Requests fetched: $requests');
      final existingRequest = requests.firstWhere(
        (request) {
          print(
              'Checking request with userId: ${request?.userId} against ${widget.userId}');
          return request.userId == widget.userId;
        },
        orElse: () {
          print('No matching request found for userId: ${widget.userId}');
          return DeliveryPersonRequestModel(); // Use DeliveryPersonRequestModel
        },
      );
      if (existingRequest.requestStatus != null) {
        setState(() {
          _requestStatus = existingRequest.requestStatus;
          print('Request status set: $_requestStatus');
        });
      } else {
        print('No request status found for userId: ${widget.userId}');
      }
    } catch (e) {
      print('Error fetching request status: $e');
      setState(() {
        _errorMessage = 'error_fetching_status'.tr();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      try {
        await _deliveryPersonService.submitDeliveryPersonRequest(
          phone: _phoneController.text,
          address: _addressController.text,
          cardNumber: _cardNumberController.text,
          userId: widget.userId,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('request_submitted_successfully'.tr()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _phoneController.clear();
        _addressController.clear();
        _cardNumberController.clear();
        await _checkExistingRequest();
      } catch (e) {
        print('Error submitting request: $e');
        setState(() {
          _errorMessage = e.toString().contains('Connection')
              ? 'network_error'
              : 'submission_error';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage.tr()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: isDark ? Colors.white : Colors.black87,
          ),
          iconTheme:
              IconThemeData(color: isDark ? Colors.white : Colors.black87),
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.8),
                  primaryColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text('apply_as_delivery_person'.tr()),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.grey[900]!, Colors.grey[800]!]
                      : [Colors.grey[50]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  if (_requestStatus != null) ...[
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: isDark ? Colors.grey[800] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'request_status'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'request_status_$_requestStatus'.tr(),
                              style: TextStyle(
                                color: _requestStatus == 'Approved'
                                    ? Colors.green
                                    : _requestStatus == 'Rejected'
                                        ? Colors.red
                                        : Colors.orange,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'existing_request_message'.tr(),
                              style: TextStyle(
                                  color:
                                      isDark ? Colors.white70 : Colors.black54),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DeliveryPersonProfilePage(
                                              userId: widget.userId),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  'view_profile'.tr(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: isDark ? Colors.grey[800] : Colors.white,
                            child: ExpansionTile(
                              title: Text(
                                'job_instructions'.tr(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'job_instructions_details'.tr(),
                                    style: TextStyle(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54),
                                  ),
                                ),
                              ],
                              onExpansionChanged: (expanded) {
                                setState(() {
                                  _showInstructions = expanded;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'personal_information'.tr(),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'phone'.tr(),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor:
                                  isDark ? Colors.grey[800] : Colors.white,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'phone_required'.tr() : null,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'address'.tr(),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor:
                                  isDark ? Colors.grey[800] : Colors.white,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'address_required'.tr() : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _cardNumberController,
                            decoration: InputDecoration(
                              labelText: 'card_number'.tr(),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor:
                                  isDark ? Colors.grey[800] : Colors.white,
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'card_number_required'.tr()
                                : null,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(_errorMessage.tr(),
                                  style: TextStyle(color: Colors.red[400])),
                            ),
                          Center(
                            child: _isLoading
                                ? CircularProgressIndicator(color: primaryColor)
                                : ElevatedButton(
                                    onPressed: _submitRequest,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child: Text(
                                      'submit_request'.tr(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

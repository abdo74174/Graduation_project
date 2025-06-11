import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/core/constants/constant.dart';

class InstallmentTermsPage extends StatelessWidget {
  final String bank;

  const InstallmentTermsPage({super.key, required this.bank});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final terms = bank == "SAB"
        ? [
            "To avail 0% installment for 6 or 12 months, customer must purchase worth SR 1000 on a single invoice from Jarir Bookstore.",
            "Customer must pay the full transaction amount using SAB credit card.",
            "SAB cardholders may convert their transaction to installment directly via online banking or mobile app (SAB Net / SAB Mobile).",
            "Converting the transaction to 0% is at the full discretion of the bank, customers must contact their bank directly for full terms and conditions or any queries.",
            "This promotion is applicable in Jarir Bookstore showroom and online purchases in the Kingdom of Saudi Arabia.",
            "Other bank terms and conditions apply.",
            "Prepaid & Debit cards are not included in the promotion.",
          ]
        : [
            "To avail 0% installment for 3, 6 or 12 months, customer must purchase worth EG 1500 on a single invoice from Jarir Bookstore.",
            "Customer must pay the full transaction amount using Emirates NBD credit card.",
            "To convert their transaction to 0% Installment, cardholders must call 8007547777 (ENBD Contact Center) 48 hours after the transaction and request for the installment.",
            "Converting the transaction to 0% is at the full discretion of the bank, customers must contact their bank directly for full terms and conditions or any queries.",
            "This promotion is applicable in Jarir Bookstore showroom and online purchases in the Kingdom of Saudi Arabia.",
            "Other bank terms and conditions apply.",
          ];

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          "0% Installment with $bank".tr(),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Conditions:".tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Color(pkColor.value),
              ),
            ),
            const SizedBox(height: 12),
            ...terms.map((term) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "• ",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          term,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

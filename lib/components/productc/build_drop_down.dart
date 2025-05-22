import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Import for localization

class BuildDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final Function(String?)? onChanged;
  final bool enabled;
  final String? hint;

  const BuildDropdown({
    Key? key,
    required this.label,
    required this.options,
    this.selectedValue,
    this.onChanged,
    this.enabled = true,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedValue,
            hint: Text(hint?.tr() ?? 'dropdown.select'.tr() + ' ' + label.tr()),
            isExpanded: true,
            underline: Container(),
            onChanged: enabled ? onChanged : null,
            items: options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.tr()),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

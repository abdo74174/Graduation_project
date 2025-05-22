import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomInputField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final String? errorText;

  const CustomInputField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.isPassword,
    this.errorText,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _isPasswordHidden : false,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon, color: Colors.grey[600]),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () => setState(
                    () => _isPasswordHidden = !_isPasswordHidden,
                  ),
                )
              : null,
          hintText: 'auth.${widget.hint}'.tr(),
          filled: true,
          // ignore: deprecated_member_use
          fillColor: Colors.white.withOpacity(0.8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          errorText:
              widget.errorText != null ? 'auth.${widget.errorText}'.tr() : null,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData startIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.startIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: Icon(widget.startIcon, color: AppColors.gray400),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.gray400,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}

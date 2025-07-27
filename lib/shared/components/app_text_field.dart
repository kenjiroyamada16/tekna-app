import 'package:flutter/material.dart';

import '../../style/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? errorMessage;
  final bool isObscure;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? Function(String? text)? validator;
  final void Function(String)? onChanged;

  const AppTextField({
    this.validator,
    super.key,
    this.label,
    this.isObscure = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      obscureText: isObscure,
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      cursorColor: AppColors.textColor,
      decoration: InputDecoration(
        errorText: errorMessage,
        label: Text(label ?? '', style: TextStyle(color: AppColors.textColor)),
        errorBorder: _errorBorder,
        disabledBorder: _disabledBorder,
        focusedErrorBorder: _errorBorder,
        enabledBorder: _outlineInputBorder,
        focusedBorder: _focusedOutlineInputBorder,
        labelStyle: TextStyle(fontSize: 14),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  OutlineInputBorder get _outlineInputBorder => OutlineInputBorder(borderRadius: BorderRadius.circular(12));

  OutlineInputBorder get _focusedOutlineInputBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.textColor),
  );

  OutlineInputBorder get _disabledBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.textColor.withValues(alpha: 0.2)),
  );

  OutlineInputBorder get _errorBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: AppColors.errorColor),
  );
}

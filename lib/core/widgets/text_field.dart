import 'package:amora/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final String? initialValue;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final int maxLines;

  const BuildTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral,
          ),
        ),
        8.verticalSpace,
        TextFormField(
          initialValue: controller == null ? initialValue : null,
          controller: controller,
          obscureText: isPassword,
          onChanged: onChanged,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }
}

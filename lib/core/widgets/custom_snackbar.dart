import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/colors.dart';

enum SnackBarType { success, error, info }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    IconData icon;
    Color iconColor;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = const Color(0xFFE8F5E9);
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.tertiary;
        break;
      case SnackBarType.error:
        backgroundColor = const Color(0xFFFDECEA);
        icon = Icons.error_rounded;
        iconColor = AppColors.error;
        break;
      case SnackBarType.info:
      default:
        backgroundColor = const Color(0xFFE3F2FD);
        icon = Icons.info_rounded;
        iconColor = AppColors.secondary;
        break;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: backgroundColor,
        padding: EdgeInsets.zero,
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  message,
                  style: theme.snackBarTheme.contentTextStyle?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        margin: EdgeInsets.all(20.w),
      ),
    );
  }
}

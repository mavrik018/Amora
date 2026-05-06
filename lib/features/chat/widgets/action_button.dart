import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 26.w,
        height: 26.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? Padding(
                padding: EdgeInsets.all(6.w),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, color: Colors.white, size: 16.w),
      ),
    );
  }
}

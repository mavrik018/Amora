import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStaggeredGrid extends StatelessWidget {
  const ProfileStaggeredGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MORE OF ME',
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 10.sp,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      height: 220.h,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.photo, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      height: 160.h,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.photo, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      height: 160.h,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.photo, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      height: 220.h,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.photo, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

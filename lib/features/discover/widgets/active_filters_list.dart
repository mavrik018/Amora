import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActiveFiltersList extends StatelessWidget {
  const ActiveFiltersList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _buildFilterChip(theme, '18-24'),
          SizedBox(width: 8.w),
          _buildFilterChip(theme, 'Verified Only'),
          SizedBox(width: 8.w),
          _buildFilterChip(theme, 'Brussels +20km'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        border: Border.all(color: theme.primaryColor),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.close,
            size: 16.w,
            color: theme.primaryColor,
          ),
        ],
      ),
    );
  }
}

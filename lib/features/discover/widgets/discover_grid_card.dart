import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscoverGridCard extends StatelessWidget {
  final int index;

  const DiscoverGridCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final names = ['Elena', 'Marc', 'Sophie', 'Aria', 'Julian', 'Chloe'];
    final ages = ['23', '25', '22', '24', '26', '21'];
    final locations = [
      'PARIS',
      'LONDON',
      'BERLIN',
      'MILAN',
      'BARCELONA',
      'BRUSSELS',
    ];
    final name = names[index % names.length];
    final age = ages[index % ages.length];
    final location = locations[index % locations.length];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: Colors.grey.shade300,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Container(color: Colors.grey.shade400),
            ),
          ),
          // Gradient for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Heart Rating / Compatibility
          Positioned(
            top: 12.h,
            left: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: theme.primaryColor, size: 12.w),
                  SizedBox(width: 4.w),
                  Text(
                    '${80 + index * 3}%',
                    style:
                        theme.textTheme.labelLarge?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ) ??
                        TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
                        ),
                  ),
                ],
              ),
            ),
          ),
          // Details (Bottom Left)
          Positioned(
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$name, $age',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.verified,
                      color: theme.colorScheme.secondary,
                      size: 18.w,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  location,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1.2,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

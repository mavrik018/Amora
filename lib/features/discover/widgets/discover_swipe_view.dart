import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiscoverSwipeView extends StatelessWidget {
  const DiscoverSwipeView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: 8,
      controller: PageController(viewportFraction: 0.9),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: _DiscoverSwipeCard(index: index),
        );
      },
    );
  }
}

class _DiscoverSwipeCard extends StatelessWidget {
  final int index;

  const _DiscoverSwipeCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy data based on index to provide variety
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
        borderRadius: BorderRadius.circular(24.r),
        color: Colors.grey.shade300,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Placeholder image wrapper
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: Container(color: Colors.grey.shade400),
            ),
          ),
          // Gradient for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Compatibility
          Positioned(
            top: 20.h,
            left: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: theme.primaryColor, size: 16.w),
                  SizedBox(width: 4.w),
                  Text(
                    '${80 + index * 3}% Match',
                    style:
                        theme.textTheme.labelLarge?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ) ??
                        TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                  ),
                ],
              ),
            ),
          ),
          // Details
          Positioned(
            bottom: 24.h,
            left: 20.w,
            right: 20.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$name, $age',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.verified,
                      color: theme.colorScheme.secondary,
                      size: 24.w,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white70, size: 16.w),
                    SizedBox(width: 4.w),
                    Text(
                      location,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      Icons.close,
                      Colors.white,
                      Colors.redAccent,
                      64.w,
                    ),
                    _buildActionButton(
                      Icons.favorite,
                      theme.primaryColor,
                      Colors.white,
                      80.w,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color bgColor,
    Color iconColor,
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: iconColor, size: size * 0.45),
      ),
    );
  }
}

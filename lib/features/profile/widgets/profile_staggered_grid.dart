import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStaggeredGrid extends StatelessWidget {
  final List<String> images;
  const ProfileStaggeredGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final gridImages = images.length > 1 ? images.sublist(1) : <String>[];

    if (gridImages.isEmpty) return const SizedBox.shrink();

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
                  if (gridImages.isNotEmpty)
                    _buildImageCard(gridImages[0], 220.h),
                  if (gridImages.length > 2) ...[
                    SizedBox(height: 12.h),
                    _buildImageCard(gridImages[2], 160.h),
                  ],
                ],
              ),
            ),
            if (gridImages.length > 1) ...[
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  children: [
                    _buildImageCard(gridImages[1], 160.h),
                    if (gridImages.length > 3) ...[
                      SizedBox(height: 12.h),
                      _buildImageCard(gridImages[3], 220.h),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildImageCard(String imageUrl, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: height,
        width: double.infinity,
        color: Colors.grey.shade200,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }
}

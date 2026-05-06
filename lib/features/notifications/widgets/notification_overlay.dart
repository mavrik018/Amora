import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/notification_model.dart';
import 'package:amora/core/constants/colors.dart';

class NotificationOverlay extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const NotificationOverlay({
    super.key,
    required this.notification,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child:
            GestureDetector(
                  onTap: onTap,
                  onVerticalDragEnd: (_) => onDismiss(),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 24.r,
                                      backgroundColor: AppColors.primary.withOpacity(0.1),
                                      backgroundImage: notification.sender?.photos.isNotEmpty == true
                                          ? NetworkImage(notification.sender!.photos.first)
                                          : null,
                                      child: notification.sender?.photos.isNotEmpty == true
                                          ? null
                                          : Icon(
                                              notification.type == NotificationType.message
                                                  ? Icons.chat_bubble_rounded
                                                  : Icons.person_add_rounded,
                                              color: AppColors.primary,
                                              size: 20.r,
                                            ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: EdgeInsets.all(4.r),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: Icon(
                                          notification.type == NotificationType.message
                                              ? Icons.chat_bubble_rounded
                                              : Icons.person_add_rounded,
                                          color: Colors.white,
                                          size: 10.r,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification.title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                      ),
                                      Text(
                                        notification.body,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.7),
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: onDismiss,
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.3),
                                    size: 20.r,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2.r),
                              child:
                                  LinearProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.primary.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                        backgroundColor: Colors.transparent,
                                        minHeight: 3.h,
                                      )
                                      .animate(onComplete: (c) => onDismiss())
                                      .custom(
                                        duration: 5.seconds,
                                        builder: (context, value, child) =>
                                            LinearProgressIndicator(
                                              value: 1 - value,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AppColors.primary
                                                        .withOpacity(0.5),
                                                  ),
                                              backgroundColor:
                                                  Colors.transparent,
                                              minHeight: 3.h,
                                            ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .animate()
                .slideY(
                  begin: -1,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.bounceInOut,
                )
                .fadeIn(duration: 400.ms),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModeToggle extends StatelessWidget {
  final bool isGridMode;
  final void Function(bool) onModeChanged;

  const ModeToggle({
    super.key,
    required this.isGridMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.05),
        border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onModeChanged(true),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isGridMode ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: isGridMode
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                'Grid',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isGridMode
                      ? theme.primaryColor
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onModeChanged(false),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: !isGridMode ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: !isGridMode
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                'Swipe',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: !isGridMode
                      ? theme.primaryColor
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

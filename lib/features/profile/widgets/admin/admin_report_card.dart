import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/profile_model.dart';
import '../../providers/admin_provider.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class AdminReportCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> report;
  const AdminReportCard({super.key, required this.report});

  @override
  ConsumerState<AdminReportCard> createState() => _AdminReportCardState();
}

class _AdminReportCardState extends ConsumerState<AdminReportCard> {
  ProfileModel? _reportedProfile;
  bool _isLoading = true;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile =
          await ref.read(adminProvider).getProfile(widget.report['reported_id']);
      if (mounted) {
        setState(() {
          _reportedProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _dismissReport() async {
    setState(() => _isDismissing = true);
    try {
      await ref.read(adminProvider).dismissReport(widget.report['id'].toString());
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Report dismissed',
          type: SnackBarType.success,
        );
        ref.invalidate(reportsStreamProvider);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Failed to dismiss: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDismissing = false);
      }
    }
  }

  Color _reasonColor(String? reason) {
    switch ((reason ?? '').toLowerCase()) {
      case 'spam':
        return Colors.orange;
      case 'harassment':
        return Colors.red;
      case 'inappropriate content':
        return Colors.purple;
      case 'fake profile':
        return Colors.blue;
      default:
        return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        height: 120.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_reportedProfile == null) return const SizedBox.shrink();

    final reason = widget.report['reason'] as String?;
    final reasonColor = _reasonColor(reason);
    final hasEvidence = widget.report['evidence_url'] != null;
    final hasDescription =
        (widget.report['description'] as String?)?.isNotEmpty == true;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 4.h, color: reasonColor.withOpacity(0.7)),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28.r,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: _reportedProfile!.photos.isNotEmpty
                              ? NetworkImage(_reportedProfile!.photos.first)
                              : null,
                          child: _reportedProfile!.photos.isEmpty
                              ? Icon(Icons.person, size: 28.r, color: Colors.grey)
                              : null,
                        ),
                        if (_reportedProfile!.isBanned)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.all(2.r),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.block_rounded, size: 14.r, color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _reportedProfile!.fullName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              fontSize: 18.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: reasonColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: reasonColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flag_rounded, size: 14.r, color: reasonColor),
                                SizedBox(width: 6.w),
                                Text(
                                  reason ?? 'No reason',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: reasonColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          _reportedProfile!.isBanned ? 'Banned' : 'Active',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                            color: _reportedProfile!.isBanned ? Colors.red.shade400 : Colors.green.shade600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: _reportedProfile!.isBanned,
                            activeColor: Colors.red.shade400,
                            activeTrackColor: Colors.red.shade100,
                            inactiveThumbColor: Colors.grey.shade400,
                            inactiveTrackColor: Colors.grey.shade200,
                            onChanged: (value) async {
                              try {
                                await ref.read(adminProvider).toggleBanStatus(_reportedProfile!.id, value);
                                setState(() {
                                  _reportedProfile = _reportedProfile!.copyWith(isBanned: value);
                                });
                                if (context.mounted) {
                                  CustomSnackBar.show(
                                    context,
                                    message: value ? 'User banned' : 'User unbanned',
                                    type: value ? SnackBarType.error : SnackBarType.success,
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  CustomSnackBar.show(
                                    context,
                                    message: 'Error: $e',
                                    type: SnackBarType.error,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (hasDescription) ...[
                  SizedBox(height: 14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F8FC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.black.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reporter\'s Note',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 13.sp,
                            letterSpacing: 0.4,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          widget.report['description'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.85),
                            fontSize: 15.sp,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (hasEvidence) ...[
            Container(
              height: 450.h,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.report['evidence_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image_outlined, size: 32.r, color: Colors.grey.shade400),
                          SizedBox(height: 8.h),
                          Text('Image unavailable', style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp)),
                        ],
                      ),
                    ),
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null,
                              strokeWidth: 2,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(20.r)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_rounded, size: 12.r, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text('Evidence', style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              border: Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20.r)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_outline_rounded, size: 12.r, color: Colors.grey.shade500),
                      SizedBox(width: 4.w),
                      Text(
                        'By ${widget.report['reporter_id']?.toString().substring(0, 8) ?? '?'}…',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _isDismissing
                    ? SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green.shade600))
                    : TextButton.icon(
                        onPressed: _dismissReport,
                        icon: Icon(Icons.check_circle_rounded, size: 16.r),
                        label: const Text('Dismiss'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green.shade600,
                          backgroundColor: Colors.green.shade50,
                          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
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

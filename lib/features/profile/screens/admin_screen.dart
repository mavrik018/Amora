import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/admin_provider.dart';
import '../models/profile_model.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/services/auth_service.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(reportsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F8),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Panel',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            reportsAsync.maybeWhen(
              data: (reports) => Text(
                '${reports.length} pending report${reports.length == 1 ? '' : 's'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.black.withOpacity(0.06), height: 1),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: IconButton(
              onPressed: () async => await AuthService.logout(),
              icon: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: theme.colorScheme.error,
                  size: 18.r,
                ),
              ),
            ),
          ),
        ],
      ),
      body: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 48.r,
                      color: Colors.green.shade500,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'All clear!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'No pending reports to review',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _ReportCard(report: report);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Text(
            'Error: $e',
            style: TextStyle(color: Colors.red.shade400),
          ),
        ),
      ),
    );
  }
}

// ─── Report reason chip colors ────────────────────────────────────────────────
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

class _ReportCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> report;
  const _ReportCard({required this.report});

  @override
  ConsumerState<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends ConsumerState<_ReportCard> {
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
      final profile = await ref
          .read(adminProvider)
          .getProfile(widget.report['reported_id']);
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
      await ref
          .read(adminProvider)
          .dismissReport(widget.report['id'].toString());
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Report dismissed',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDismissing = false);
        CustomSnackBar.show(
          context,
          message: 'Failed to dismiss: $e',
          type: SnackBarType.error,
        );
      }
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
          // ── Colored top accent strip ───────────────────────────────────
          Container(height: 4.h, color: reasonColor.withOpacity(0.7)),

          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── User info row ──────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28.r,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: _reportedProfile!.photos.isNotEmpty
                              ? NetworkImage(_reportedProfile!.photos.first)
                              : null,
                          child: _reportedProfile!.photos.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 28.r,
                                  color: Colors.grey,
                                )
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
                              child: Icon(
                                Icons.block_rounded,
                                size: 14.r,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(width: 12.w),

                    // Name + reason badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _reportedProfile!.fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: reasonColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: reasonColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag_rounded,
                                  size: 12.r,
                                  color: reasonColor,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  reason ?? 'No reason',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: reasonColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ban toggle
                    Column(
                      children: [
                        Text(
                          _reportedProfile!.isBanned ? 'Banned' : 'Active',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _reportedProfile!.isBanned
                                ? Colors.red.shade400
                                : Colors.green.shade600,
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
                                await ref
                                    .read(adminProvider)
                                    .toggleBanStatus(
                                      _reportedProfile!.id,
                                      value,
                                    );
                                setState(() {
                                  _reportedProfile = _reportedProfile!.copyWith(
                                    isBanned: value,
                                  );
                                });
                                if (context.mounted) {
                                  CustomSnackBar.show(
                                    context,
                                    message: value
                                        ? 'User banned'
                                        : 'User unbanned',
                                    type: value
                                        ? SnackBarType.error
                                        : SnackBarType.success,
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

                // ── Description ───────────────────────────────────────
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
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.45,
                            ),
                            letterSpacing: 0.4,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.report['description'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.75,
                            ),
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

          // ── Evidence image — full width, generous height ──────────────
          if (hasEvidence) ...[
            Container(
              height: 0.4.sh, // 40% of screen height
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
                          Icon(
                            Icons.broken_image_outlined,
                            size: 32.r,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Image unavailable',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                  ),
                  // Subtle label overlay
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image_rounded,
                            size: 12.r,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Evidence',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Action footer ─────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              border: Border(
                top: BorderSide(color: Colors.black.withOpacity(0.06)),
              ),
            ),
            child: Row(
              children: [
                // Reporter badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 12.r,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'By ${widget.report['reporter_id']?.toString().substring(0, 8) ?? '?'}…',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Dismiss button
                _isDismissing
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.green.shade600,
                        ),
                      )
                    : TextButton.icon(
                        onPressed: _dismissReport,
                        icon: Icon(Icons.check_circle_rounded, size: 16.r),
                        label: const Text('Dismiss'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green.shade600,
                          backgroundColor: Colors.green.shade50,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          textStyle: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
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

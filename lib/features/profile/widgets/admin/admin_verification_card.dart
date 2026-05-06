import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/verification_request_model.dart';
import '../../providers/admin_provider.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class AdminVerificationCard extends ConsumerStatefulWidget {
  final VerificationRequestModel request;
  const AdminVerificationCard({super.key, required this.request});

  @override
  ConsumerState<AdminVerificationCard> createState() =>
      _AdminVerificationCardState();
}

class _AdminVerificationCardState extends ConsumerState<AdminVerificationCard> {
  bool _isProcessing = false;

  Future<void> _handleApprove() async {
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(adminProvider)
          .approveVerification(widget.request.id, widget.request.userId);
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Verification approved!',
          type: SnackBarType.success,
        );
        ref.invalidate(pendingVerificationsProvider);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'Error: $e',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleReject() async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Verification'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: 'Reason for rejection...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => _isProcessing = true);
      try {
        await ref
            .read(adminProvider)
            .rejectVerification(widget.request.id, result);
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: 'Verification rejected',
            type: SnackBarType.info,
          );
          ref.invalidate(pendingVerificationsProvider);
        }
      } catch (e) {
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: 'Error: $e',
            type: SnackBarType.error,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    (widget.request.userFullName ?? '?')[0].toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.request.userFullName ?? 'Unknown User',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'ID Verification Request',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 450.h,
            width: double.infinity,
            child: Image.network(
              widget.request.idImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.broken_image_outlined)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : _handleReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _handleApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: _isProcessing
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Approve'),
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

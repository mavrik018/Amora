import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';
import '../models/verification_request_model.dart';

class VerificationRequestScreen extends ConsumerStatefulWidget {
  const VerificationRequestScreen({super.key});

  @override
  ConsumerState<VerificationRequestScreen> createState() =>
      _VerificationRequestScreenState();
}

class _VerificationRequestScreenState
    extends ConsumerState<VerificationRequestScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final repository = ref.read(profileRepositoryProvider);
      final profile = await ref.read(userProfileProvider.future);
      if (profile == null) return;

      // 1. Upload to storage
      final imageUrl = await repository.uploadVerificationId(
        profile.id,
        _selectedImage!,
      );

      // 2. Submit request
      await repository.submitVerificationRequest(profile.id, imageUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification request submitted!')),
        );
        ref.invalidate(userVerificationProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verificationAsync = ref.watch(userVerificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        centerTitle: true,
      ),
      body: verificationAsync.when(
        data: (request) {
          if (request != null) {
            return _buildStatusView(request, theme);
          }
          return _buildUploadView(theme);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatusView(VerificationRequestModel request, ThemeData theme) {
    IconData statusIcon;
    Color statusColor;
    String statusText;

    switch (request.status) {
      case 'approved':
        statusIcon = Icons.verified_rounded;
        statusColor = Colors.green;
        statusText = 'Your identity is verified!';
        break;
      case 'rejected':
        statusIcon = Icons.error_outline_rounded;
        statusColor = theme.colorScheme.error;
        statusText = 'Verification rejected';
        break;
      default:
        statusIcon = Icons.pending_actions_rounded;
        statusColor = Colors.orange;
        statusText = 'Verification pending';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon, size: 80.sp, color: statusColor),
            SizedBox(height: 24.h),
            Text(
              statusText,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (request.status == 'rejected' && request.rejectionReason != null) ...[
              SizedBox(height: 12.h),
              Text(
                'Reason: ${request.rejectionReason}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(userVerificationProvider);
                },
                child: const Text('Try Again'),
              ),
            ],
            if (request.status == 'pending') ...[
              SizedBox(height: 12.h),
              const Text(
                'Our team is reviewing your ID. This usually takes 24-48 hours.',
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadView(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verify Your Identity',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'To ensure a safe community, please upload a clear photo of your government-issued ID.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 32.h),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          size: 48.sp,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(height: 12.h),
                        const Text('Tap to upload ID photo'),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 40.h),
          ElevatedButton(
            onPressed: (_selectedImage == null || _isUploading)
                ? null
                : _submitRequest,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _isUploading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit for Verification'),
          ),
        ],
      ),
    );
  }
}

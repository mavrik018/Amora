import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../models/profile_model.dart';
import '../providers/profile_provider.dart';
import '../../../core/constants/enums.dart';
import '../../../core/widgets/text_field.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../shared/widgets/audio_bio_editor.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final ProfileModel profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late RelationshipIntent _intent;
  late List<String> _photos;
  late Map<String, String> _prompts;
  late String _gender;
  late String _interestedIn;
  String? _audioBioUrl;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Audio recording state
  String? _localAudioPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _intent = widget.profile.relationshipIntent ?? RelationshipIntent.serious;
    _photos = List<String>.from(widget.profile.photos);
    _prompts = Map<String, String>.from(widget.profile.prompts);
    _audioBioUrl = widget.profile.audioBioUrl;
    _gender = widget.profile.gender;
    _interestedIn = widget.profile.interestedIn;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }



  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _photos.add(image.path);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseClientProvider);
      final List<String> uploadedUrls = [];

      // Upload photos
      for (String photoPath in _photos) {
        if (photoPath.startsWith('http')) {
          uploadedUrls.add(photoPath);
        } else {
          final file = File(photoPath);
          final fileName =
              '${widget.profile.id}/${DateTime.now().millisecondsSinceEpoch}${path.extension(photoPath)}';

          await supabase.storage.from('profiles').upload(fileName, file);
          final publicUrl = supabase.storage
              .from('profiles')
              .getPublicUrl(fileName);
          uploadedUrls.add(publicUrl);
        }
      }

      // Upload audio bio if new
      String? finalAudioUrl = _audioBioUrl;
      if (_localAudioPath != null) {
        final file = File(_localAudioPath!);

        // Check file size (3MB limit)
        final int fileSizeInBytes = await file.length();
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        if (fileSizeInMB > 3.0) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Audio too long'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }

        final fileName =
            '${widget.profile.id}/audio_bio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await supabase.storage.from('profiles').upload(fileName, file);
        finalAudioUrl = supabase.storage
            .from('profiles')
            .getPublicUrl(fileName);
      }

      // Identify photos that were removed to delete them from storage
      final originalUrls = widget.profile.photos;
      final remainingUrls = _photos.where((p) => p.startsWith('http')).toList();
      final urlsToDelete = originalUrls.where((url) => !remainingUrls.contains(url)).toList();

      // Handle Audio Bio cleanup
      if (widget.profile.audioBioUrl != null && widget.profile.audioBioUrl != finalAudioUrl) {
        urlsToDelete.add(widget.profile.audioBioUrl!);
      }

      // Delete removed files from Supabase Storage
      for (String url in urlsToDelete) {
        try {
          final uri = Uri.parse(url);
          final pathSegments = uri.pathSegments;
          final storagePath = pathSegments.sublist(pathSegments.indexOf('profiles') + 1).join('/');
          
          await supabase.storage.from('profiles').remove([storagePath]);
        } catch (e) {
          debugPrint('Error deleting orphaned file: $e');
        }
      }

      final updatedProfile = ProfileModel(
        id: widget.profile.id,
        fullName: _nameController.text.trim(),
        dob: widget.profile.dob,
        gender: _gender,
        interestedIn: _interestedIn,
        relationshipIntent: _intent,
        interests: widget.profile.interests,
        prompts: _prompts,
        photos: uploadedUrls,
        audioBioUrl: finalAudioUrl,
        latitude: widget.profile.latitude,
        longitude: widget.profile.longitude,
      );

      await ref.read(profileRepositoryProvider).updateProfile(updatedProfile);
      ref.invalidate(userProfileProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Save',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photos',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 120.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length + 1,
                itemBuilder: (context, index) {
                  if (index == _photos.length) {
                    return GestureDetector(
                      onTap: () => _showImageSourceActionSheet(context),
                      child: Container(
                        width: 100.w,
                        margin: EdgeInsets.only(right: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  }

                  final photo = _photos[index];
                  return Stack(
                    children: [
                      Container(
                        width: 100.w,
                        margin: EdgeInsets.only(right: 12.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          image: DecorationImage(
                            image: photo.startsWith('http')
                                ? NetworkImage(photo) as ImageProvider
                                : FileImage(File(photo)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 16,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 32.h),

            // Audio Bio Section
            Text(
              'Audio Bio',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16.h),
            AudioBioEditor(
              initialAudioUrl: _audioBioUrl,
              initialLocalPath: _localAudioPath,
              onAudioChanged: (path) {
                setState(() {
                  _localAudioPath = path;
                  if (path != null) {
                    _audioBioUrl = null;
                  }
                });
              },
            ),
            SizedBox(height: 32.h),

            BuildTextField(
              label: 'Full Name',
              hintText: 'Your Name',
              controller: _nameController,
            ),
            SizedBox(height: 32.h),

            Text(
              'My Gender',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: ['Man', 'Woman', 'Other'].map((gender) {
                final isSelected = _gender == gender;
                return ChoiceChip(
                  label: Text(gender),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                  onSelected: (selected) {
                    if (selected) setState(() => _gender = gender);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 32.h),

            Text(
              'Interested In',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: ['Men', 'Women', 'Everyone'].map((option) {
                final isSelected = _interestedIn == option;
                return ChoiceChip(
                  label: Text(option),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                  onSelected: (selected) {
                    if (selected) setState(() => _interestedIn = option);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 32.h),

            Text(
              'Relationship Intent',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: RelationshipIntent.values.map((intent) {
                final isSelected = _intent == intent;
                return ChoiceChip(
                  label: Text(
                    intent.name[0].toUpperCase() + intent.name.substring(1),
                  ),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.grey.shade700,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _intent = intent);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 32.h),

            Text(
              'Personality Prompts',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16.h),
            ..._prompts.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: BuildTextField(
                  label: entry.key,
                  hintText: 'Write your answer...',
                  initialValue: entry.value,
                  maxLines: 3,
                  onChanged: (val) {
                    _prompts[entry.key] = val;
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}

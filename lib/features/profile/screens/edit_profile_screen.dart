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
  String? _audioBioUrl;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Audio recording state
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _localAudioPath;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _intent = widget.profile.relationshipIntent ?? RelationshipIntent.serious;
    _photos = List<String>.from(widget.profile.photos);
    _prompts = Map<String, String>.from(widget.profile.prompts);
    _audioBioUrl = widget.profile.audioBioUrl;

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = path.join(
          directory.path,
          'audio_bio_${DateTime.now().millisecondsSinceEpoch}.m4a',
        );

        const config = RecordConfig();
        await _audioRecorder.start(config, path: filePath);

        setState(() {
          _isRecording = true;
          _localAudioPath = filePath;
        });
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _localAudioPath = path;
        _audioBioUrl = null; // Clear existing URL if we have a new recording
      });
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _playRecording() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_localAudioPath != null) {
          await _audioPlayer.play(DeviceFileSource(_localAudioPath!));
        } else if (_audioBioUrl != null) {
          await _audioPlayer.play(UrlSource(_audioBioUrl!));
        }
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
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

      final updatedProfile = ProfileModel(
        id: widget.profile.id,
        fullName: _nameController.text.trim(),
        dob: widget.profile.dob,
        gender: widget.profile.gender,
        interestedIn: widget.profile.interestedIn,
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
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _isRecording ? _stopRecording : _startRecording,
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? Colors.red
                            : theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isRecording
                              ? 'Recording...'
                              : (_localAudioPath != null ||
                                    _audioBioUrl != null)
                              ? 'Audio bio ready'
                              : 'Record an audio bio',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!_isRecording &&
                            (_localAudioPath != null || _audioBioUrl != null))
                          Text(
                            'Tap play to listen',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!_isRecording &&
                      (_localAudioPath != null || _audioBioUrl != null))
                    Row(
                      children: [
                        IconButton(
                          onPressed: _playRecording,
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _localAudioPath = null;
                              _audioBioUrl = null;
                            });
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            BuildTextField(
              label: 'Full Name',
              hintText: 'Your Name',
              controller: _nameController,
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AudioBioEditor extends StatefulWidget {
  final String? initialAudioUrl;
  final String? initialLocalPath;
  final Function(String? localPath) onAudioChanged;

  const AudioBioEditor({
    super.key,
    this.initialAudioUrl,
    this.initialLocalPath,
    required this.onAudioChanged,
  });

  @override
  State<AudioBioEditor> createState() => _AudioBioEditorState();
}

class _AudioBioEditorState extends State<AudioBioEditor> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _localAudioPath;
  String? _audioBioUrl;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _localAudioPath = widget.initialLocalPath;
    _audioBioUrl = widget.initialAudioUrl;

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
      final recordedPath = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _localAudioPath = recordedPath;
        _audioBioUrl = null; // Clear existing URL if we have a new recording
      });
      widget.onAudioChanged(_localAudioPath);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
                color: _isRecording ? Colors.red : theme.colorScheme.primary,
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
                      : (_localAudioPath != null || _audioBioUrl != null)
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
          if (!_isRecording && (_localAudioPath != null || _audioBioUrl != null))
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
                    widget.onAudioChanged(null);
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
    );
  }
}

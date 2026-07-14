import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/main.dart';
import 'package:homemed/widgets/field_label.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestForm extends StatefulWidget {
  const RequestForm({super.key});

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _symptoms = TextEditingController();
  bool _isLoading = false;

  // Photos
  final List<XFile> _images = [];
  final _picker = ImagePicker();

  // Audio
  final _audioRecorder = AudioRecorder();
  String? _audioPath;
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;

  // ── Photo picker ──────────────────────────────────────────────────────────

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 70, limit: 5);
    if (picked.isEmpty) return;
    setState(() {
      final combined = [..._images, ...picked];
      _images
        ..clear()
        ..addAll(combined.take(5)); // cap at 5
    });
  }

  // ── Voice recorder ────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    if (!await _audioRecorder.hasPermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allow voice recording to continue')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    _recordDuration = Duration.zero;
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _recordDuration += const Duration(seconds: 1));
    });
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    _recordTimer?.cancel();
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _audioPath = path;
    });
  }

  void _deleteRecording() {
    if (_audioPath != null) {
      File(_audioPath!).deleteSync(recursive: true);
    }
    setState(() {
      _audioPath = null;
      _recordDuration = Duration.zero;
    });
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<String> _uploadFile(String localPath, String folder) async {
    final file = File(localPath);
    final name = localPath.split('/').last;
    final userId = supabase.auth.currentUser!.id;
    final storagePath = '$userId/$folder/$name';

    await supabase.storage
        .from('consultation-files')
        .upload(
          storagePath,
          file,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage
        .from('consultation-files')
        .createSignedUrl(storagePath, 3600);
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    setState(() => _isLoading = true);

    if (_isRecording) _stopRecording();

    try {
      // Upload all files in parallel — minimises total wait time
      final uploadFutures = [
        ..._images.map((img) => _uploadFile(img.path, 'images')),
        if (_audioPath != null) _uploadFile(_audioPath!, 'audio'),
      ];
      final fileUrls = await Future.wait(uploadFutures);

      await supabase.from('consultation_requests').insert({
        'patient_id': supabase.auth.currentUser?.id,
        'symptoms': _symptoms.text.trim(),
        'file_urls': fileUrls,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request sent! A doctor will be with you shortly.'),
        ),
      );
      context.pop();
    } on AuthApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      String errMsg = 'Something went wrong. Try again later.';
      if (e.toString().contains('SocketException')) {
        errMsg = 'No internet connection.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errMsg)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _symptoms.dispose();
    _recordTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Medical Help')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      const FieldLabel(label: 'Describe your symptoms'),
                      TextFormField(
                        controller: _symptoms,
                        maxLines: 5,
                        textInputAction: .done,
                        decoration: const InputDecoration(
                          hintText:
                              'Describe your symptoms, how it feels and when it started...',
                          alignLabelWithHint: true,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Please describe your symptoms',
                          ),
                          FormBuilderValidators.minLength(
                            20,
                            errorText:
                                'Please provide more detail (at least 20 characters)',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 24),
                      const FieldLabel(label: 'Additional info'),
                      _PhotoSection(
                        images: _images,
                        onAdd: _pickImages,
                        onRemove: (i) => setState(() => _images.removeAt(i)),
                      ),
                      const SizedBox(height: 12),
                      _AudioSection(
                        isRecording: _isRecording,
                        audioPath: _audioPath,
                        duration: _recordDuration,
                        onStart: _startRecording,
                        onStop: _stopRecording,
                        onDelete: _deleteRecording,
                        formatDuration: _formatDuration,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send to Doctor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Photo section ─────────────────────────────────────────────────────────────

class _PhotoSection extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onAdd;
  final void Function(int) onRemove;

  const _PhotoSection({
    required this.images,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (images.isEmpty) {
      return _OutlineButton(
        icon: Icons.add_a_photo_outlined,
        label: 'Add Photos',
        onTap: onAdd,
      );
    }

    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: .horizontal,
        children: [
          ...List.generate(images.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: .circular(8),
                    child: Image.file(
                      File(images[i].path),
                      width: 96,
                      height: 96,
                      fit: .cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: scheme.surface.withAlpha(220),
                          shape: .circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (images.length < 5)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: .circular(8),
                  border: Border.all(color: scheme.outline),
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: scheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Audio section ─────────────────────────────────────────────────────────────

class _AudioSection extends StatelessWidget {
  final bool isRecording;
  final String? audioPath;
  final Duration duration;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onDelete;
  final String Function(Duration) formatDuration;

  const _AudioSection({
    required this.isRecording,
    required this.audioPath,
    required this.duration,
    required this.onStart,
    required this.onStop,
    required this.onDelete,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // State: recording in progress
    if (isRecording) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: .circular(8),
          border: Border.all(color: scheme.error),
          color: scheme.errorContainer.withAlpha(60),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _PulsingDot(color: scheme.error),
            const SizedBox(width: 12),
            Text(
              formatDuration(duration),
              style: text.bodyMedium?.copyWith(
                fontWeight: .w600,
                color: scheme.error,
              ),
            ),
            const Spacer(),
            FilledButton.tonal(
              onPressed: onStop,
              style: FilledButton.styleFrom(
                backgroundColor: scheme.errorContainer,
                foregroundColor: scheme.onErrorContainer,
                minimumSize: const Size(0, 40),
              ),
              child: const Text('Stop'),
            ),
          ],
        ),
      );
    }

    // State: recording done
    if (audioPath != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: .circular(8),
          border: Border.all(color: scheme.outline),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.mic, color: scheme.primary),
            const SizedBox(width: 12),
            Text(
              'Voice note · ${formatDuration(duration)}',
              style: text.bodyMedium?.copyWith(fontWeight: .w500),
            ),
            const Spacer(),
            IconButton(
              onPressed: onDelete,
              icon: Icon(Icons.delete_outline, color: scheme.error),
              tooltip: 'Delete recording',
            ),
          ],
        ),
      );
    }

    // State: idle
    return _OutlineButton(
      icon: Icons.mic_none_outlined,
      label: 'Voice note',
      onTap: onStart,
    );
  }
}

// ── Shared outlined action button ─────────────────────────────────────────────

class _OutlineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: .circular(8),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: .circular(8),
          border: Border.all(color: scheme.outline),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 12),
            Text(label, style: text.bodyMedium?.copyWith(fontWeight: .w500)),
          ],
        ),
      ),
    );
  }
}

// ── Pulsing recording indicator ───────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: widget.color, shape: .circle),
      ),
    );
  }
}

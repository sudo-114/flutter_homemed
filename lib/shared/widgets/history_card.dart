import 'package:flutter/material.dart';
import 'package:homemed/shared/models/patient_file.dart';
import 'package:homemed/shared/models/consultation_request.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:skeletonizer/skeletonizer.dart';

(Color bg, Color fg) _getStatusColors(String? status, ColorScheme scheme) {
  final normalized = (status ?? '').toLowerCase();
  switch (normalized) {
    case 'pending':
      return (scheme.secondaryContainer, scheme.onSecondaryContainer);
    case 'accepted':
      return (scheme.primaryContainer, scheme.onPrimaryContainer);
    case 'completed':
      return (scheme.tertiaryContainer, scheme.onTertiaryContainer);
    case 'cancelled':
      return (scheme.errorContainer, scheme.onErrorContainer);
    default:
      return (scheme.surfaceContainerHighest, scheme.onSurfaceVariant);
  }
}

class HistoryCard extends StatelessWidget {
  final ConsultationRequest request;

  const HistoryCard({super.key, required this.request});

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 5) {
      return 'Just now';
    } else if (now.year == dateTime.year) {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  void _showDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _RequestDetailBottomSheet(request: request),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (statusBg, statusFg) = _getStatusColors(request.status, scheme);
    final fileCount = request.fileUrls?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: .circular(8),
        border: Border.all(
          color: scheme.outlineVariant.withAlpha(80),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: .circular(8),
        onTap: () => _showDetailsBottomSheet(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Status pill and Timestamp/Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusPill(
                    statusFg: statusFg,
                    statusBg: statusBg,
                    status: request.status!,
                  ),
                  Row(
                    children: [
                      Text(
                        _formatDate(request.createdAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.more_horiz,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Symptoms Title
              Text(
                request.symptoms,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium,
              ),

              // Bottom Metadata Row (Files / Doctor info)
              if (fileCount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Transform.rotate(
                      angle: -0.7,
                      child: Icon(
                        Icons.attach_file,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$fileCount file${fileCount > 1 ? "s" : ""} attached',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ] else if (request.doctorName != null &&
                  request.doctorName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.medical_services_outlined,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      request.doctorName!,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestDetailBottomSheet extends StatelessWidget {
  final ConsultationRequest request;

  const _RequestDetailBottomSheet({required this.request});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (statusBg, statusFg) = _getStatusColors(request.status, scheme);

    final fileUrls = request.fileUrls ?? [];
    final fileCount = fileUrls.length;
    bool hasImage = fileUrls.toString().contains('images');
    bool hasAudio = fileUrls.toString().contains('audio');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status badge & Date
          // TODO: edit and delete requests based on status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusPill(
                statusFg: statusFg,
                statusBg: statusBg,
                status: request.status!,
              ),
              Text(
                DateFormat('MMM d, yyyy · h:mm a').format(request.createdAt),
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Symptoms Label & Full Content
          Text(
            'Symptoms',
            style: textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(request.symptoms, style: textTheme.bodyLarge),

          // Doctor Info (if assigned)
          if (request.doctorName != null && request.doctorName!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Assigned Doctor',
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 18,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  request.doctorName!,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],

          // Attachments Info (if any)
          if (fileCount > 0) ...[
            const SizedBox(height: 20),
            Text(
              'Attachments ($fileCount)',
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: hasImage ? 98 : 0,
              child: ListView(
                scrollDirection: .horizontal,
                children: fileUrls.map((file) {
                  if (PatientFile.type(file) == 'images') {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _ImageCard(image: file),
                    );
                  }
                  return const SizedBox.shrink();
                }).toList(),
              ),
            ),

            (hasAudio && hasImage)
                ? const SizedBox(height: 16)
                : const SizedBox.shrink(),

            Column(
              children: fileUrls.map((file) {
                if (PatientFile.type(file) == 'audio') {
                  return _AudioCard(audio: file);
                }
                return const SizedBox.shrink();
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Color statusFg;
  final Color statusBg;
  final String status;

  const _StatusPill({
    required this.statusFg,
    required this.statusBg,
    required this.status,
  });

  @override
  Widget build(context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: text.labelSmall?.copyWith(
          color: statusFg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String image;
  const _ImageCard({required this.image});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PatientFile.url(image),
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) {
          return _ImageLoading();
        }
        if (snapshot.hasError) {
          final err = snapshot.error.toString();
          debugPrint('Failed to load image: $err');

          return _ImageError();
        }
        if (snapshot.hasData && snapshot.data != '') {
          return ClipRRect(
            borderRadius: .circular(8),
            child: Image.network(
              snapshot.data!,
              width: 96,
              height: 96,
              fit: .cover,
              errorBuilder: ((context, error, _) {
                debugPrint(error.toString());
                return _ImageError();
              }),
              frameBuilder: ((context, child, frame, _) {
                if (frame == null) return _ImageLoading();
                return child;
              }),
              loadingBuilder: ((context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                if (loadingProgress.cumulativeBytesLoaded !=
                    loadingProgress.expectedTotalBytes) {
                  return _ImageLoading();
                } else {
                  return _ImageLoading();
                }
              }),
            ),
          );
        } else {
          return _ImageError();
        }
      },
    );
  }
}

class _ImageLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Bone.square(size: 96, borderRadius: .circular(8)),
    );
  }
}

class _ImageError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: .circular(8),
      ),
      height: 96,
      width: 96,
      child: Center(
        child: Icon(
          Icons.warning_amber_rounded,
          size: 42,
          color: scheme.onErrorContainer.withAlpha(200),
        ),
      ),
    );
  }
}

class _AudioCard extends StatelessWidget {
  final String audio;
  const _AudioCard({required this.audio});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PatientFile.url(audio),
      builder: (context, snapshot) {
        if (snapshot.connectionState == .waiting) return _AudioLoading();

        if (snapshot.hasData && snapshot.data != '') {
          return _PlayAudio(audio: snapshot.data!);
        }
        if (snapshot.hasError) {
          String err = snapshot.error.toString();
          debugPrint('Failed to get audio link: $err');

          debugPrint(snapshot.error.toString());
          return _AudioError();
        }

        return SizedBox();
      },
    );
  }
}

class _PlayAudio extends StatefulWidget {
  final String audio;
  const _PlayAudio({required this.audio});

  @override
  State<_PlayAudio> createState() => _PlayAudioState();
}

class _PlayAudioState extends State<_PlayAudio> {
  late final AudioPlayer _player;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });

    try {
      await _player.setUrl(widget.audio);
      if (mounted) setState(() => _isLoading = false);
    } catch (err) {
      if (mounted) setState(() => _hasError = true);
      debugPrint('AudioSource failed: $err');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final mm = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_hasError) return _AudioError();
    if (_isLoading) return _AudioLoading();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: scheme.surfaceDim,
      ),
      child: Row(
        children: [
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              return IconButton.filled(
                onPressed: () => playing ? _player.pause() : _player.play(),
                icon: Icon(playing ? Icons.pause : Icons.play_arrow_rounded),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                final total = _player.duration ?? Duration.zero;
                final progress = total.inMilliseconds == 0
                    ? 0.0
                    : position.inMilliseconds / total.inMilliseconds;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 5,
                        inactiveTrackColor: scheme.primary.withAlpha(50),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (value) => _player.seek(total * value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '${_formatDuration(position)} / ${_formatDuration(total)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: Bone(width: .infinity, height: 70, borderRadius: .circular(8)),
    );
  }
}

class _AudioError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: .symmetric(horizontal: 12, vertical: 16),
      width: .infinity,
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: .circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Text(
            'Failed to load voice note',
            style: text.bodySmall?.copyWith(color: scheme.onErrorContainer),
          ),
        ],
      ),
    );
  }
}

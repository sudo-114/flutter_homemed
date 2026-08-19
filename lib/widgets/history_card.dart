import 'package:flutter/material.dart';
import 'package:homemed/model/consultation_request.dart';
import 'package:homemed/model/patient_file.dart';
import 'package:intl/intl.dart';
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status badge & Date
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
                    return _ImageCard(image: file);
                  }
                  return const SizedBox.shrink();
                }).toList(),
              ),
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
          return Padding(
            padding: const .only(right: 8),
            child: ClipRRect(
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
    return Padding(
      padding: const .only(right: 8),
      child: Skeletonizer(
        child: Bone.square(size: 96, borderRadius: .circular(8)),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.errorContainer,
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

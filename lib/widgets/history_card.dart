import 'package:flutter/material.dart';
import 'package:homemed/model/consultation_request.dart';
import 'package:intl/intl.dart';

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

  void _showDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.status ?? 'Pending',
                      style: textTheme.labelSmall?.copyWith(
                        color: statusFg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (statusBg, statusFg) = _getStatusColors(request.status, scheme);
    final fileCount = request.fileUrls?.length ?? 0;

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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.status!,
                  style: textTheme.labelSmall?.copyWith(
                    color: statusFg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withAlpha(120),
                borderRadius: .circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file, size: 18, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '$fileCount attachment file${fileCount > 1 ? "s" : ""} uploaded',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

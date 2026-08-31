import 'package:flutter/material.dart';

class PatientHelpSupport extends StatelessWidget {
  const PatientHelpSupport({super.key});

  static const _faqs = [
    (
      'How does requesting help work?',
      'Describe your symptoms, attach photos or a voice note if it helps, '
          'and submit. A doctor will review your request and respond as soon '
          'as possible.',
    ),
    (
      'How long until a doctor responds?',
      'Response times vary. We\'re working on making this faster and more '
          'predictable as we grow.',
    ),
    (
      'Is my information private?',
      'Yes. Your medical information, photos, and voice notes are only '
          'accessible to you and the doctor assigned to your request.',
    ),
    (
      'Can I edit a request after submitting it?',
      'Not currently. If something changes, you can submit a new request '
          'with updated information.',
    ),
    (
      'What happens to my photos and voice notes?',
      'They\'re stored securely and are only used to help a doctor understand '
          'your symptoms. They\'re never shared outside your consultation.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Text(
            'Frequently Asked Questions',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._faqs.map(
            (faq) => ExpansionTile(
              title: Text(faq.$1, style: textTheme.bodyLarge),
              childrenPadding: const EdgeInsets.only(
                bottom: 12,
                left: 4,
                right: 4,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    faq.$2,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Still need help?',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reach out and we\'ll get back to you as soon as we can.',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => debugPrint('Send help email'),
                  // TODO: add actual email address

                  // onPressed: () => launchUrl(
                  //   Uri.parse(
                  //     'mailto:support@yourdomain.com?subject=HomeMed Support',
                  //   ),
                  // ),
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Contact us'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

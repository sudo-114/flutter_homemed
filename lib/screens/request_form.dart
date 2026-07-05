import 'package:flutter/material.dart';
import 'package:homemed/widgets/field_label.dart';

class RequestForm extends StatefulWidget {
  const RequestForm({super.key});

  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Medical Help')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(label: 'Describe your symptoms'),
                      TextFormField(
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText:
                              'Describe your symptoms, how it feels and when it started...',
                        ),
                      ),
                      const SizedBox(height: 24),
                      const FieldLabel(label: 'Additional info'),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoButton(
                              label: 'Add Photos',
                              icon: Icons.add_a_photo_outlined,
                              onTap: () {
                                // Action for adding photos
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _InfoButton(
                              label: 'Voice note',
                              icon: Icons.mic_none_outlined,
                              onTap: () {
                                // Action for recording voice
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: () {
                  // Submit request
                },
                child: const Text('Send to Doctor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _InfoButton({
    required this.label,
    required this.icon,
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
        decoration: BoxDecoration(
          borderRadius: .circular(8),
          border: Border.all(color: scheme.outline, width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                overflow: .ellipsis,
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

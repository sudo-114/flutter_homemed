import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:homemed/widgets/patient_form.dart';
import 'package:homemed/widgets/role_card.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final List<dynamic> _role = jsonDecode('''
  [
    {"id": "patient", "label": "Patient", "icon": "person"},
    {"id": "doctor", "label": "Doctor", "icon" : "medical_service" }
  ]
    ''');

  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = _role.first['id'];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                'Complete your profile',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: .bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Just a few more details to get you started',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 36),
              Text(
                'I am a ...',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: _role.map((role) {
                  final label = role['label'] ?? '';
                  final iconName = role['icon'] ?? '';
                  IconData icon;
                  if (iconName == 'person') {
                    icon = Icons.person;
                  } else if (iconName == 'medical_service') {
                    icon = Icons.medical_services;
                  } else {
                    icon = Icons.help_outline;
                  }

                  final id = role['id'] as String?;
                  final isSelected = id != null && id == _selectedRole;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: RoleCard(
                        label: label,
                        icon: icon,
                        selected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedRole = id;
                          });
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 38),

              (_selectedRole == 'patient')
                  ? const PatientForm()
                  : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

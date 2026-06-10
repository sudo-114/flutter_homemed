import 'dart:convert';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:homemed/main.dart';
import 'package:homemed/widgets/field_label.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientForm extends StatefulWidget {
  final String? phone;
  final String? role;
  const PatientForm({super.key, this.phone, this.role});

  @override
  State<PatientForm> createState() => _PatientFormState();
}

class _PatientFormState extends State<PatientForm> {
  final List _gender = jsonDecode('''
  [
    {"id": "male", "label" : "Male"},
    {"id": "female", "label" : "Female"},
    {"id": "other", "label" : "Other"}
  ]
  ''');

  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  String? _genderError;
  DateTime? _date;
  final _name = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final isValid = _formKey.currentState?.validate() ?? false;
      final dob = DateFormat.yMd().format(_date!);

      setState(() {
        _genderError = _selectedGender == null
            ? 'Please select a gender'
            : null;
      });

      if (!isValid || _selectedGender == null) {
        return;
      }

      final userId = supabase.auth.currentUser?.id;

      final payload = {
        'id': userId,
        'name': _name.text.trim(),
        'gender': _selectedGender,
        'dob': dob,
        'phone': widget.phone,
        'role': widget.role,
      };

      await supabase.from('profiles').upsert(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    } on AuthApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      String errMsg = 'Something went wrong. Try again later';

      if (e.toString().contains('SocketException')) {
        errMsg = 'No internet connection';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errMsg)));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const FieldLabel(label: 'Full name'),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'Enter your full name'),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Please enter your full name',
              ),
              FormBuilderValidators.minLength(
                3,
                errorText: 'Name must be at least 3 characters',
              ),
            ]),
          ),
          const SizedBox(height: 16),

          const FieldLabel(label: 'Date of birth'),
          DateTimeFormField(
            mode: .date,
            lastDate: .now(),
            decoration: const InputDecoration(hintText: 'mm/dd/yyyy'),
            onChanged: (date) => _date = date,
            validator: (date) => FormBuilderValidators.required(
              errorText: 'Please enter your date of birth',
            )(date),
          ),
          const SizedBox(height: 16),

          const FieldLabel(label: 'Gender'),
          Row(
            children: _gender.map((gender) {
              final id = gender['id'] as String;
              final label = gender['label'] as String;
              final selected = _selectedGender == id;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: .fromHeight(46),
                      side: BorderSide(
                        width: 2,
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant.withAlpha(130),
                      ),
                      backgroundColor: selected
                          ? theme.colorScheme.primary.withAlpha(20)
                          : null,
                      shape: RoundedRectangleBorder(borderRadius: .circular(8)),
                    ),
                    onPressed: () => setState(() => _selectedGender = id),
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: .w500,
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (_genderError != null) ...[
            const SizedBox(height: 4),
            Text(
              _genderError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],

          const SizedBox(height: 38),

          FilledButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Complete Registration'),
          ),
        ],
      ),
    );
  }
}

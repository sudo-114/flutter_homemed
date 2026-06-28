import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homemed/widgets/field_label.dart';

class DoctorForm extends StatefulWidget {
  final String? phone;
  final String? role;
  const DoctorForm({super.key, this.phone, this.role});

  @override
  State<DoctorForm> createState() => _DoctorFormState();
}

class _DoctorFormState extends State<DoctorForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _license = TextEditingController();
  final _xpYears = TextEditingController();
  String? _specialty;

  bool _isLoading = false;

  final List<DropdownMenuItem<String>> _specialties = [
    const DropdownMenuItem(value: 'cardiology', child: Text('Cardiology')),
    const DropdownMenuItem(value: 'dermatology', child: Text('Dermatology')),
    const DropdownMenuItem(value: 'pediatrics', child: Text('Pediatrics')),
    const DropdownMenuItem(value: 'general', child: Text('General Practice')),
  ];

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final isValid = _formKey.currentState?.validate() ?? false;
      if (!isValid) return;

      final userId = supabase.auth.currentUser?.id;
      final xpYears = int.tryParse(_xpYears.text.trim());

      final payload = {
        'id': userId,
        'name': _name.text.trim(),
        'specialty': _specialty,
        'license': _license.text.trim(),
        'xp_years': xpYears,
        'phone': widget.phone,
        'role': widget.role,
      };

      storage.write('role', widget.role);
      await supabase.from('profiles').upsert(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));

      context.go('/home');
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
    _license.dispose();
    _xpYears.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              FormBuilderValidators.required(errorText: 'Name is required'),
              FormBuilderValidators.minWordsCount(
                2,
                errorText: 'Please enter at least first and last name',
              ),
            ]),
          ),
          const SizedBox(height: 16),

          const FieldLabel(label: 'Specialty'),
          DropdownButtonFormField(
            items: _specialties,
            initialValue: _specialty,
            decoration: const InputDecoration(hintText: 'Select specialty'),
            onChanged: (value) => setState(() => _specialty = value),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Please select a specialty',
              ),
            ]),
          ),
          const SizedBox(height: 16),

          const FieldLabel(label: 'Medical license'),
          TextFormField(
            controller: _license,
            textInputAction: .next,
            decoration: const InputDecoration(hintText: 'Enter license number'),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Medical license is required',
              ),
              FormBuilderValidators.minLength(
                5,
                errorText: 'License must be at least 5 characters',
              ),
              FormBuilderValidators.maxLength(
                20,
                errorText: 'License must be at most 20 characters',
              ),
            ]),
          ),
          const SizedBox(height: 16),

          const FieldLabel(label: 'Years of experience'),
          TextFormField(
            controller: _xpYears,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter years of experience',
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Years of experience is required',
              ),
              FormBuilderValidators.numeric(errorText: 'Enter a valid number'),
              FormBuilderValidators.min(
                0,
                errorText: 'Years must be 0 or greater',
              ),
            ]),
          ),
          const SizedBox(height: 38),

          FilledButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Complete Registration'),
          ),
        ],
      ),
    );
  }
}

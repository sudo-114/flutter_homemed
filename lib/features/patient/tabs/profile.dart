import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homemed/features/patient/tabs/home.dart';
import 'package:homemed/main.dart';
import 'package:date_field/date_field.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:homemed/shared/widgets/field_label.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String convertToSentenceCase(String text) {
  if (text.isEmpty) return text;
  return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
}

class PatientProfile extends StatefulWidget {
  const PatientProfile({super.key});

  @override
  State<PatientProfile> createState() => _PatientProfileState();
}

class _PatientProfileState extends State<PatientProfile> {
  Future<void> _editInfo(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: ((context) => _EditPatientProfileForm()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final name = storage.read('name');
    final dob = storage.read('dob');
    final gender = convertToSentenceCase(storage.read('gender'));
    final phone = storage.read('phone');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Card.filled(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20).copyWith(top: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Row(
                            spacing: 8,
                            children: [
                              const Icon(Icons.person_outlined),
                              Text(
                                'Personal info',
                                style: text.bodyLarge!.copyWith(
                                  fontWeight: .w600,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            iconSize: 20,
                            icon: Icon(Icons.edit),
                            onPressed: () => _editInfo(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(label: 'Full Name', value: name),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Date of Birth', value: dob),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Gender', value: gender),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Phone Number', value: phone),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Card.filled(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingTile(
                      title: 'Notifications',
                      icon: Icons.notifications_outlined,
                      // TODO: show push notifications and their read state
                      onTap: () => debugPrint('Notification'),
                    ),
                    const Divider(),
                    _SettingTile(
                      title: 'Terms of Service',
                      icon: Icons.description_outlined,
                      // TODO: wire ToS domain/content ones it exist
                      onTap: () => debugPrint('Terms'),
                    ),
                    const Divider(),
                    _SettingTile(
                      title: 'Privacy Policy',
                      icon: Icons.privacy_tip_outlined,
                      // TODO: wire Privacy Policy domain/content ones it exist
                      onTap: () => debugPrint('Privacy'),
                    ),
                    const Divider(),
                    _SettingTile(
                      title: 'Help & Support',
                      icon: Icons.help_outline,
                      onTap: () => context.push('/help'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  supabase.auth.signOut();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  iconColor: scheme.error,
                  side: BorderSide(color: scheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(label),
        Text(value, style: TextStyle(fontWeight: .bold)),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _SettingTile({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: TextStyle(fontWeight: .w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _EditPatientProfileForm extends StatefulWidget {
  @override
  State<_EditPatientProfileForm> createState() =>
      _EditPatientProfileFormState();
}

class _EditPatientProfileFormState extends State<_EditPatientProfileForm> {
  final List<DropdownMenuItem<String>> _genderOptions = [
    DropdownMenuItem(value: 'male', child: Text('Male')),
    DropdownMenuItem(value: 'female', child: Text('Female')),
  ];

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  DateTime? _date;
  String? _dob;
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _name.text = storage.read('name') ?? '';
    _selectedGender = storage.read('gender');

    final storedDob = storage.read('dob');
    if (storedDob != null) {
      try {
        _date = DateFormat.yMd().parse(storedDob);
        _dob = storedDob;
      } catch (_) {
        _date = null;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_date != null) {
      _dob = DateFormat.yMd().format(_date!);
    }

    setState(() => _isLoading = true);

    try {
      final userId = supabase.auth.currentUser?.id;

      final payload = {
        'id': userId,
        'name': _name.text.trim(),
        'dob': _dob,
        'gender': _selectedGender,
      };

      await supabase
          .from('profiles')
          .update(payload)
          .eq('id', userId as Object);

      storage.write('name', _name.text.trim());
      storage.write('dob', _dob);
      storage.write('gender', _selectedGender);

      patientNameNotifier.value = _name.text.trim();

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } on AuthApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      debugPrint(e.toString());
      String errMsg = 'Something went wrong. Try again later';

      if (e.toString().contains('SocketException')) {
        errMsg = 'No internet connection';
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(
        24,
      ).copyWith(top: 0, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit personal info',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const FieldLabel(label: 'Full name'),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                hintText: 'Enter your full name',
              ),
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
              mode: DateTimeFieldPickerMode.date,
              lastDate: DateTime.now(),
              initialValue: _date,
              decoration: const InputDecoration(hintText: 'mm/dd/yyyy'),
              onChanged: (date) => _date = date,
              validator: (date) => FormBuilderValidators.required(
                errorText: 'Please enter your date of birth',
              )(date),
            ),
            const SizedBox(height: 16),

            const FieldLabel(label: 'Gender'),
            DropdownButtonFormField(
              items: _genderOptions,
              initialValue: _selectedGender,
              decoration: const InputDecoration(hintText: 'Select gender'),
              onChanged: (value) => _selectedGender = value,
              validator: FormBuilderValidators.required(
                errorText: 'Please select your gender',
              ),
            ),
            const SizedBox(height: 32),

            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save changes'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

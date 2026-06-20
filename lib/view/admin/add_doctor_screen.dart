import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:doctorapp/core/widgets/costum_text_field.dart';
import 'package:doctorapp/core/widgets/custom_button.dart';
import 'package:doctorapp/view%20model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();

  String _selectedSpecialist = 'General Physician';

  final List<String> _specializations = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Orthopedic',
    'Pediatrician',
    'Psychiatrist',
    'Gynecologist',
    'ENT Specialist',
    'Ophthalmologist',
    'Urologist',
    'Dentist',
    'Radiologist',
    'Oncologist',
    'Endocrinologist',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _addDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final error = await authVM.createStaffAccount(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: 'doctor',
      specialist: _selectedSpecialist,
      phone: _phoneController.text.trim(),
      experience: _experienceController.text.trim(),
      fee: _feeController.text.trim(),
    );

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor successfully add ho gaya!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Doctor'),
        backgroundColor: AppColors.doctorColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Doctor Avatar
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.doctorColor.withOpacity(0.1),
                      borderRadius: AppStyles.borderRadiusLarge,
                    ),
                    child: Icon(
                      Icons.medical_services_outlined,
                      color: AppColors.doctorColor,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Name
                CustomTextField(
                  label: 'Doctor Full Name',
                  hint: 'e.g. Dr. Ahmad Ali',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Name required';
                    if (val.length < 3) return 'Name too short';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter doctor email',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email required';
                    if (!val.contains('@')) return 'Valid email daalein';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  label: 'Password',
                  hint: 'Set doctor password',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Password required';
                    if (val.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Phone
                CustomTextField(
                  label: 'Phone Number',
                  hint: 'Enter doctor phone',
                  controller: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Phone required';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ✅ Specialization Dropdown
                Text('Specialization', style: AppStyles.bodyMedium),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppStyles.borderRadiusMedium,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSpecialist,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: _specializations.map((spec) {
                        return DropdownMenuItem<String>(
                          value: spec,
                          child: Text(spec),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSpecialist = val!;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Experience
                CustomTextField(
                  label: 'Experience (Years)',
                  hint: 'e.g. 5',
                  controller: _experienceController,
                  prefixIcon: Icons.work_outline,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Experience required';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Fee
                // Fee
                Text('Consultation Fee', style: AppStyles.bodyMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. 1500',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: AppStyles.borderRadiusMedium,
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppStyles.borderRadiusMedium,
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppStyles.borderRadiusMedium,
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    // ✅ Pehle PKR prefix
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      child: Text(
                        'PKR',
                        style: TextStyle(
                          color: AppColors.doctorColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // ✅ Baad mein /- suffix
                    suffixText: '/-',
                    suffixStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Fee required';
                    if (int.tryParse(val) == null) return 'Sirf number daalein';
                    if (int.parse(val) < 100)
                      return 'Minimum fee 100 PKR honi chahiye';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                Consumer<AuthViewModel>(
                  builder: (context, authVM, _) {
                    return CustomButton(
                      text: 'Add Doctor',
                      onPressed: _addDoctor,
                      isLoading: authVM.isLoading,
                      icon: Icons.medical_services_outlined,
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

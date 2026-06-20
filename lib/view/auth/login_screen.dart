import 'package:doctorapp/core/constents/app_color.dart';
import 'package:doctorapp/core/constents/app_style.dart';
import 'package:doctorapp/core/widgets/costum_text_field.dart';
import 'package:doctorapp/core/widgets/custom_button.dart';
import 'package:doctorapp/view%20model/auth_view_model.dart';
import 'package:doctorapp/view/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Login Screen - Supports Patient, Doctor & Admin login
class LoginScreen extends StatefulWidget {
  final String role; // 'patient', 'doctor', 'admin'

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Get role-specific color
  Color get roleColor {
    switch (widget.role) {
      case 'doctor':
        return AppColors.doctorColor;
      case 'admin':
        return AppColors.adminColor;
      default:
        return AppColors.patientColor;
    }
  }

  /// Get role display name
  String get roleTitle {
    switch (widget.role) {
      case 'doctor':
        return 'Doctor';
      case 'admin':
        return 'Admin';
      default:
        return 'Patient';
    }
  }

  /// Get role icon
  IconData get roleIcon {
    switch (widget.role) {
      case 'doctor':
        return Icons.medical_services_outlined;
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.person_outline;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final error = await authVM.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: widget.role,
    );

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else if (mounted) {
      // ✅ Role ke hisaab se navigate karo
      switch (widget.role) {
        case 'doctor':
          Navigator.pushReplacementNamed(context, '/doctor-home');
          break;
        case 'admin':
          Navigator.pushReplacementNamed(context, '/admin-home');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/patient-home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppStyles.borderRadiusSmall,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Role Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: AppStyles.borderRadiusMedium,
                  ),
                  child: Icon(roleIcon, color: roleColor, size: 32),
                ),

                const SizedBox(height: 20),

                // Title
                Text('Welcome Back!', style: AppStyles.heading1),
                const SizedBox(height: 8),
                Text(
                  'Login as $roleTitle to continue',
                  style: AppStyles.bodyMedium,
                ),

                const SizedBox(height: 40),

                // Email Field
                CustomTextField(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email is required';
                    if (!val.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty)
                      return 'Password is required';
                    if (val.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to forgot password
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppStyles.bodyMedium.copyWith(
                        color: roleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Button
                Consumer<AuthViewModel>(
                  builder: (context, authVM, _) {
                    return CustomButton(
                      text: 'Login',
                      onPressed: _login,
                      isLoading: authVM.isLoading,
                      color: roleColor,
                    );
                  },
                ),

                // Sign Up (only for patients)
                if (widget.role == 'patient') ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppStyles.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                            settings: const RouteSettings(arguments: 'patient'),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: AppStyles.bodyMedium.copyWith(
                            color: roleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

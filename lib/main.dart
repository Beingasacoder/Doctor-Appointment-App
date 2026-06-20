import 'package:doctorapp/firebase_options.dart';
import 'package:doctorapp/model/doctor_view_model.dart';
import 'package:doctorapp/view%20model/auth_view_model.dart';
import 'package:doctorapp/view%20model/patient_view_model.dart';
import 'package:doctorapp/view/admin/admin_home_screen.dart';
import 'package:doctorapp/view/auth/login_screen.dart';
import 'package:doctorapp/view/auth/role_selection_screen.dart';
import 'package:doctorapp/view/doctor/doctor_home_screen.dart';
import 'package:doctorapp/view/patient/patient_home.dart';
import 'package:doctorapp/view/service/notifecation_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => DoctorViewModel()),
        ChangeNotifierProvider(create: (_) => PatientViewModel()),
      ],
      child: MaterialApp(
        title: 'MediBook',
        debugShowCheckedModeBanner: false,
        home: const RoleSelectionScreen(),
        routes: {
          '/login': (ctx) {
            // ✅ Null safety ke saath arguments lo
            final role =
                ModalRoute.of(ctx)!.settings.arguments as String? ?? 'patient';
            return LoginScreen(role: role);
          },
          '/patient-home': (ctx) => const PatientHomeScreen(),
          '/doctor-home': (ctx) => const DoctorHomeScreen(),
          '/admin-home': (ctx) => const AdminHomeScreen(),
        },
      ),
    );
  }
}

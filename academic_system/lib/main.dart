import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'repositories/auth_repository.dart';
import 'repositories/academic_repository.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/student_viewmodel.dart';
import 'ui/auth/login_page.dart';
import 'ui/dashboard/dashboard_page.dart';
import 'ui/finance/finance_dashboard.dart';
import 'ui/student/student_dashboard.dart';
import 'core/constants.dart';
import 'repositories/http_auth_repository.dart';
import 'repositories/http_academic_repository.dart';
// import 'repositories/mock_academic_repository.dart'; // Removed because it's inside academic_repository.dart
import 'repositories/admin_repository.dart';
import 'repositories/http_admin_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<AuthRepository>(create: (_) => HttpAuthRepository()),
        Provider<AcademicRepository>(create: (_) => HttpAcademicRepository()),
        Provider<AdminRepository>(create: (_) => HttpAdminRepository()),
        
        // ViewModels
        ChangeNotifierProxyProvider<AuthRepository, AuthViewModel>(
          create: (context) => AuthViewModel(
            authRepository: Provider.of<AuthRepository>(context, listen: false),
          ),
          update: (context, authRepo, previous) => 
            previous ?? AuthViewModel(authRepository: authRepo),
        ),
        ChangeNotifierProxyProvider<AcademicRepository, StudentViewModel>(
          create: (context) => StudentViewModel(
            repository: Provider.of<AcademicRepository>(context, listen: false),
          ),
          update: (context, repo, previous) => 
            previous ?? StudentViewModel(repository: repo),
        ),
      ],
      child: MaterialApp(
        title: 'Sistem Akademik',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667EEA)),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}



class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, child) {
        if (authVM.isLoggedIn) {
          final role = authVM.currentUser?.role;
          if (role == 'mahasiswa') {
            return StudentDashboard();
          } else if (role == 'keuangan') {
            return FinanceDashboard();
          } else {
            // superadmin, admin, dosen (temporary)
            return DashboardPage();
          }
        }
        return const LoginPage();
      },
    );
  }
}

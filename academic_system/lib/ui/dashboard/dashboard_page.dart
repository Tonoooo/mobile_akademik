import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/constants.dart';
import '../student/student_dashboard.dart';
import '../lecturer/lecturer_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../finance/finance_dashboard.dart';
import '../superadmin/superadmin_dashboard.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthViewModel>(context).currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Error: User not found')));
    }

    switch (user.role) {
      case AppConstants.roleMahasiswa:
        return const StudentDashboard();
      case AppConstants.roleDosen:
        return const LecturerDashboard();
      case AppConstants.roleAdmin:
        return AdminDashboard();
      case AppConstants.roleKeuangan:
        return FinanceDashboard();
      case AppConstants.roleSuperAdmin:
        return SuperAdminDashboard();
      default:
        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: Center(child: Text('Dashboard for ${user.role} is under construction')),
        );
    }
  }
}

import 'package:flutter/material.dart';

/// Admin dashboard screen placeholder
/// 
/// This will be implemented in a future task
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 대시보드'),
      ),
      body: const Center(
        child: Text(
          '관리자 대시보드 화면\n(향후 구현 예정)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
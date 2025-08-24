import 'package:flutter/material.dart';

/// Profile screen placeholder
/// 
/// This will be implemented in a future task
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
      ),
      body: const Center(
        child: Text(
          '프로필 화면\n(향후 구현 예정)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
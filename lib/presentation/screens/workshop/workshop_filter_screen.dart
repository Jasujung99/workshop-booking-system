import 'package:flutter/material.dart';

/// Workshop filter screen placeholder
/// 
/// This will be implemented in a future task
class WorkshopFilterScreen extends StatelessWidget {
  const WorkshopFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            '필터',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: Center(
              child: Text(
                '필터 화면\n(향후 구현 예정)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorPanel(this.message, {super.key, this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: const Color(0xFF111A2B), borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.cloud_off_rounded, color: Color(0xFFE5A45B), size: 25),
      const SizedBox(height: 10),
      Text(message, style: const TextStyle(color: Colors.white70, height: 1.4)),
      if (onRetry != null) TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Try again')),
    ]),
  );
}

class LoadingPanel extends StatelessWidget {
  const LoadingPanel({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(32),
    child: Center(child: CircularProgressIndicator()),
  );
}

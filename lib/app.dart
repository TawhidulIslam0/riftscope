import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/app_shell.dart';

class RiftScopeApp extends StatelessWidget {
  const RiftScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RiftScope',
      debugShowCheckedModeBanner: false,
      theme: RiftTheme.dark,
      home: const AppShell(),
    );
  }
}

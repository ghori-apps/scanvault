import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'screens/generator/generator_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/permissions/permission_screen.dart';
import 'screens/scanner/scanner_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/permission_service.dart';
import 'widgets/sv_bottom_nav.dart';

class ScanVaultApp extends StatelessWidget {
  const ScanVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'ScanVault',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: settings.themeMode,
          home: const AppRootScreen(),
        );
      },
    );
  }
}

class AppRootScreen extends StatefulWidget {
  const AppRootScreen({super.key});

  @override
  State<AppRootScreen> createState() => _AppRootScreenState();
}

class _AppRootScreenState extends State<AppRootScreen> {
  bool _hasCameraPermission = false;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await PermissionService.checkCameraPermission();
    if (mounted) {
      setState(() {
        _hasCameraPermission = status.isGranted;
        _isCheckingPermission = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    // 1. Onboarding check
    if (!settings.hasSeenOnboarding) {
      return OnboardingScreen(
        onFinish: () => setState(() {}),
      );
    }

    // 2. Camera Permission check
    if (_isCheckingPermission) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasCameraPermission) {
      return PermissionScreen(
        onGranted: () => setState(() => _hasCameraPermission = true),
      );
    }

    // 3. Main Navigation Shell
    return const MainNavigationShell();
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    ScannerScreen(),
    HistoryScreen(),
    GeneratorScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: SVBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

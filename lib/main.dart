import 'ads/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/generator_provider.dart';
import 'providers/history_provider.dart';
import 'providers/settings_provider.dart';
import 'services/preferences_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.init();

  // Enforce portrait orientation lock
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Enforce edge-to-edge transparent system navigation bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize local-first storage services
  final prefsService = await PreferencesService.init();
  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefsService)),
        ChangeNotifierProvider(create: (_) => HistoryProvider(storageService)),
        ChangeNotifierProvider(create: (_) => GeneratorProvider(storageService)),
      ],
      child: const ScanVaultApp(),
    ),
  );
}


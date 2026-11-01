import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/sv_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _items = [
    _OnboardingItem(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Scan Anything Instantly',
      description: 'Ultra-fast QR and barcode scanning powered by native ML acceleration.',
    ),
    _OnboardingItem(
      icon: Icons.security_rounded,
      title: 'Local-First & Private',
      description: 'Zero tracking, zero cloud dependencies. Your data stays 100% on your device.',
    ),
    _OnboardingItem(
      icon: Icons.inventory_2_rounded,
      title: 'Your Personal Scan Vault',
      description: 'Organize, search, favorite, and export your history seamlessly.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ScanVault',
                    style: AppTypography.titleLarge(isDark: isDark).copyWith(
                      color: AppColors.electricCoral,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_currentPage < _items.length - 1)
                    TextButton(
                      onPressed: () {
                        settings.completeOnboarding();
                        widget.onFinish();
                      },
                      child: const Text('Skip'),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.electricCoral.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, size: 64, color: AppColors.electricCoral),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          item.title,
                          style: AppTypography.headlineLarge(isDark: isDark),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description,
                          style: AppTypography.bodyLarge(isDark: isDark).copyWith(
                            color: AppColors.mediumGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Page Indicators & Next Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _items.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: _currentPage == i ? AppColors.electricCoral : AppColors.mediumGray.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Button
                  SVButton(
                    label: _currentPage == _items.length - 1 ? 'Get Started' : 'Next',
                    onPressed: () {
                      if (_currentPage < _items.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        settings.completeOnboarding();
                        widget.onFinish();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String description;

  _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

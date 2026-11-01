import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_typography.dart';
import '../../models/content_type.dart';
import '../../widgets/sv_button.dart';
import '../../widgets/sv_card.dart';
import 'generator_gallery.dart';
import 'generator_preview.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  CodeContentType _selectedType = CodeContentType.url;

  // Form Controllers
  final _urlController = TextEditingController();
  final _textController = TextEditingController();
  final _wifiSsidController = TextEditingController();
  final _wifiPassController = TextEditingController();
  final String _wifiSecurity = 'WPA';

  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  final _emailToController = TextEditingController();
  final _emailSubjectController = TextEditingController();
  final _emailBodyController = TextEditingController();

  final _smsPhoneController = TextEditingController();
  final _smsMessageController = TextEditingController();

  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _textController.dispose();
    _wifiSsidController.dispose();
    _wifiPassController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _emailToController.dispose();
    _emailSubjectController.dispose();
    _emailBodyController.dispose();
    _smsPhoneController.dispose();
    _smsMessageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _generateCode() {
    String rawValue = '';
    String title = '';

    switch (_selectedType) {
      case CodeContentType.url:
        final url = _urlController.text.trim();
        if (url.isEmpty) return;
        rawValue = url.startsWith('http') ? url : 'https://$url';
        title = Uri.tryParse(rawValue)?.host ?? 'Web Link';
        break;

      case CodeContentType.text:
        rawValue = _textController.text.trim();
        if (rawValue.isEmpty) return;
        title = rawValue.length > 20 ? '${rawValue.substring(0, 20)}...' : rawValue;
        break;

      case CodeContentType.wifi:
        final ssid = _wifiSsidController.text.trim();
        final pass = _wifiPassController.text.trim();
        if (ssid.isEmpty) return;
        rawValue = 'WIFI:S:$ssid;T:$_wifiSecurity;P:$pass;;';
        title = 'Wi-Fi: $ssid';
        break;

      case CodeContentType.contact:
        final name = _contactNameController.text.trim();
        final phone = _contactPhoneController.text.trim();
        final email = _contactEmailController.text.trim();
        if (name.isEmpty) return;
        rawValue = 'BEGIN:VCARD\nVERSION:3.0\nFN:$name\nTEL:$phone\nEMAIL:$email\nEND:VCARD';
        title = 'Contact: $name';
        break;

      case CodeContentType.email:
        final to = _emailToController.text.trim();
        final sub = _emailSubjectController.text.trim();
        final body = _emailBodyController.text.trim();
        if (to.isEmpty) return;
        rawValue = 'mailto:$to?subject=${Uri.encodeComponent(sub)}&body=${Uri.encodeComponent(body)}';
        title = 'Email: $to';
        break;

      case CodeContentType.sms:
        final phone = _smsPhoneController.text.trim();
        final msg = _smsMessageController.text.trim();
        if (phone.isEmpty) return;
        rawValue = 'smsto:$phone:$msg';
        title = 'SMS to $phone';
        break;

      case CodeContentType.phone:
        final phone = _phoneController.text.trim();
        if (phone.isEmpty) return;
        rawValue = 'tel:$phone';
        title = 'Phone: $phone';
        break;

      default:
        rawValue = 'ScanVault Sample';
        title = 'Sample Code';
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GeneratorPreviewScreen(
          title: title,
          rawValue: rawValue,
          contentType: _selectedType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final typeOptions = [
      _GenOption(type: CodeContentType.url, label: 'Website Link', icon: Icons.language_rounded),
      _GenOption(type: CodeContentType.text, label: 'Plain Text', icon: Icons.text_fields_rounded),
      _GenOption(type: CodeContentType.wifi, label: 'Wi-Fi Network', icon: Icons.wifi_rounded),
      _GenOption(type: CodeContentType.contact, label: 'Contact Card', icon: Icons.person_rounded),
      _GenOption(type: CodeContentType.email, label: 'Email', icon: Icons.email_rounded),
      _GenOption(type: CodeContentType.sms, label: 'SMS Message', icon: Icons.sms_rounded),
      _GenOption(type: CodeContentType.phone, label: 'Phone Number', icon: Icons.phone_rounded),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.collections_bookmark_rounded),
            tooltip: 'My Created Codes',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GeneratorGalleryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Content Type Selector Grid
            Text('Select Content Type', style: AppTypography.titleMedium(isDark: isDark)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: typeOptions.length,
              itemBuilder: (context, index) {
                final opt = typeOptions[index];
                final isSelected = _selectedType == opt.type;

                return GestureDetector(
                  onTap: () => setState(() => _selectedType = opt.type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.electricCoral
                          : (isDark ? AppColors.darkCard : AppColors.warmWhite),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.electricCoral
                            : (isDark ? const Color(0xFF38322E) : AppColors.borderGray),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          opt.icon,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.warmIvory : AppColors.graphite),
                          size: 24,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          opt.label,
                          style: AppTypography.labelSmall(isDark: isDark).copyWith(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.warmIvory : AppColors.graphite),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Dynamic Interactive Form Card
            SVCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedType.label} Details',
                    style: AppTypography.titleLarge(isDark: isDark),
                  ),
                  const SizedBox(height: 16),
                  _buildFormForType(isDark),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Generate Button
            SVButton(
              label: 'Generate QR Code',
              icon: Icons.qr_code_2_rounded,
              fullWidth: true,
              onPressed: _generateCode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormForType(bool isDark) {
    switch (_selectedType) {
      case CodeContentType.url:
        return _buildTextField(
          controller: _urlController,
          label: 'Website URL',
          hint: 'https://example.com',
          icon: Icons.link_rounded,
          isDark: isDark,
        );

      case CodeContentType.text:
        return _buildTextField(
          controller: _textController,
          label: 'Plain Text',
          hint: 'Enter your text message or note...',
          icon: Icons.text_fields_rounded,
          maxLines: 4,
          isDark: isDark,
        );

      case CodeContentType.wifi:
        return Column(
          children: [
            _buildTextField(
              controller: _wifiSsidController,
              label: 'Network Name (SSID)',
              hint: 'MyHomeWiFi',
              icon: Icons.wifi_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _wifiPassController,
              label: 'Password',
              hint: 'Wi-Fi Password',
              icon: Icons.lock_outline_rounded,
              isDark: isDark,
            ),
          ],
        );

      case CodeContentType.contact:
        return Column(
          children: [
            _buildTextField(
              controller: _contactNameController,
              label: 'Full Name',
              hint: 'John Doe',
              icon: Icons.person_outline_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _contactPhoneController,
              label: 'Phone Number',
              hint: '+1 234 567 8900',
              icon: Icons.phone_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _contactEmailController,
              label: 'Email Address',
              hint: 'john@example.com',
              icon: Icons.email_outlined,
              isDark: isDark,
            ),
          ],
        );

      case CodeContentType.email:
        return Column(
          children: [
            _buildTextField(
              controller: _emailToController,
              label: 'Recipient Email',
              hint: 'recipient@example.com',
              icon: Icons.email_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailSubjectController,
              label: 'Subject',
              hint: 'Subject line...',
              icon: Icons.subject_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailBodyController,
              label: 'Body',
              hint: 'Email message content...',
              icon: Icons.notes_rounded,
              maxLines: 3,
              isDark: isDark,
            ),
          ],
        );

      case CodeContentType.sms:
        return Column(
          children: [
            _buildTextField(
              controller: _smsPhoneController,
              label: 'Recipient Phone',
              hint: '+1 234 567 8900',
              icon: Icons.phone_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _smsMessageController,
              label: 'Message',
              hint: 'SMS text message...',
              icon: Icons.sms_outlined,
              maxLines: 3,
              isDark: isDark,
            ),
          ],
        );

      case CodeContentType.phone:
        return _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: '+1 234 567 8900',
          icon: Icons.phone_outlined,
          isDark: isDark,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge(isDark: isDark)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.bodyMedium(isDark: isDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium(isDark: isDark).copyWith(
              color: AppColors.mediumGray,
            ),
            prefixIcon: Icon(icon, color: AppColors.mediumGray, size: 20),
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _GenOption {
  final CodeContentType type;
  final String label;
  final IconData icon;

  _GenOption({required this.type, required this.label, required this.icon});
}

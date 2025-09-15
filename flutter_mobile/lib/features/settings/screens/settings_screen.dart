import 'package:flutter/material.dart';
import '../../../shared/widgets/common_app_bar.dart';
import 'network_printer_settings_screen.dart';

/// Màn hình cài đặt chính
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(
        title: 'Cài đặt',
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Printer Settings
          _buildSettingsSection(
            context,
            title: 'Máy in',
            items: [
              _buildSettingsItem(
                context,
                icon: Icons.print,
                title: 'Cài đặt máy in WiFi',
                subtitle: 'Kết nối với Xprinter T80W',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NetworkPrinterSettingsScreen(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // App Settings
          _buildSettingsSection(
            context,
            title: 'Ứng dụng',
            items: [
              _buildSettingsItem(
                context,
                icon: Icons.notifications,
                title: 'Thông báo',
                subtitle: 'Cài đặt thông báo đơn hàng',
                onTap: () {
                  // TODO: Implement notification settings
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.language,
                title: 'Ngôn ngữ',
                subtitle: 'Tiếng Việt',
                onTap: () {
                  // TODO: Implement language settings
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.info,
                title: 'Thông tin ứng dụng',
                subtitle: 'Phiên bản 1.0.0',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Card(
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Restaurant',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.restaurant,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const Text('Ứng dụng quản lý nhà hàng thông minh'),
        const SizedBox(height: 8),
        const Text('Phát triển bởi Smart Restaurant Team'),
      ],
    );
  }
}
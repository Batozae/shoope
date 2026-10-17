import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/ui.dart';
import '../address/address_list_screen.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

// Layar Pengaturan Akun dengan navigasi dan opsi profil
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Keluar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 16,
      color: Colors.grey[200],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          // Bagian 1: Akun Saya
          _buildSectionTitle('Akun Saya'),
          _buildTile(
            context,
            title: 'Keamanan & Akun',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildTile(
            context,
            title: 'Alamat Saya',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddressListScreen()),
              );
            },
          ),
          _buildDivider(),
          _buildTile(
            context,
            title: 'Kartu / Rekening Bank',
            onTap: () => showComingSoon(context),
          ),

          // Bagian 2: Pengaturan
          _buildSectionTitle('Pengaturan'),
          _buildTile(
            context,
            title: 'Pengaturan Chat',
            onTap: () => showComingSoon(context),
          ),
          _buildDivider(),
          _buildTile(
            context,
            title: 'Pengaturan Pesanan',
            onTap: () => showComingSoon(context),
          ),
          _buildDivider(),
          _buildTile(
            context,
            title: 'Pengaturan Notifikasi',
            onTap: () => showComingSoon(context),
          ),
          _buildDivider(),
          _buildTile(
            context,
            title: 'Pengaturan Privasi',
            onTap: () => showComingSoon(context),
          ),
          _buildDivider(),
          _buildTile(
            context,
            title: 'Pengguna Diblokir',
            onTap: () => showComingSoon(context),
          ),
          _buildDivider(),
          _buildTile(
            context,
            title: 'Bahasa / Language',
            subtitle: 'Bahasa Indonesia',
            onTap: () => showComingSoon(context),
          ),

          // Bagian 3: Bantuan
          _buildSectionTitle('Bantuan'),
          _buildTile(
            context,
            title: 'Pusat Bantuan',
            onTap: () => showComingSoon(context),
          ),
          _buildDivider(),
          _buildTile(
            context,
            title: 'Peraturan Komunitas',
            onTap: () => showComingSoon(context),
          ),
          _buildDivider(),
          _buildTile(
            context,
            title: 'Kebijakan',
            onTap: () => showComingSoon(context),
          ),
          _buildDivider(),
          _buildTile(
            context,
            title: 'Suka Shoope? Nilai kami!',
            onTap: () => showComingSoon(context),
          ),
          _buildDivider(),
          _buildTile(
            context,
            title: 'Informasi',
            onTap: () => showComingSoon(context),
          ),
          _buildDivider(),
          _buildTile(
            context,
            title: 'Ajukan Penghapusan Akun',
            onTap: () => showComingSoon(context),
          ),

          // Tombol Keluar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            child: OutlinedButton(
              onPressed: () => _confirmLogout(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Keluar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'main_shell.dart';

// Layar awal saat aplikasi dibuka untuk memeriksa status login pengguna
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  //Dipanggil saat splash muncul: mengecek apakah user masih punya sesi login yang valid.
  Future<void> _checkAuth() async {
    //	tryAutoLogin membaca token yang tersimpan lalu memverifikasinya ke server (detailnya di auth_provider).
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    //mounted memastikan layar masih ada setelah proses async selesai, supaya navigasi tidak error.
    final isLoggedIn = await authProvider.tryAutoLogin();
    //Sudah login: masuk ke MainShell (menu utama). pushReplacement mengganti splash, jadi tombol Back tidak kembali ke splash.
    if (!mounted) return;

    if (isLoggedIn) {
      //	Belum login atau token tidak valid: arahkan ke LoginScreen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 16),
            Text(
              'Shoope',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}


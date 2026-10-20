import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'live/live_screen.dart';
import 'notification/notification_screen.dart';
import 'profile/profile_screen.dart';

// Shell utama aplikasi dengan BottomNavigationBar 4 tab dan sinyal tab aktif
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final ValueNotifier<int> _tabSignal = ValueNotifier<int>(0);
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _tabSignal.value = _currentIndex;

    _screens = [
      const HomeScreen(),
      const LiveScreen(),
      NotificationScreen(tabSignal: _tabSignal),
      ProfileScreen(tabSignal: _tabSignal),
    ];

    // Segarkan jumlah notifikasi belum dibaca saat shell dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refreshUnreadCount();
    });
  }

  @override
  void dispose() {
    _tabSignal.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _tabSignal.value = index;
    });
    // Segarkan unread count setiap kali tab berganti
    context.read<NotificationProvider>().refreshUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle),
            label: 'Live & Video',
          ),
          BottomNavigationBarItem(
            icon: Consumer<NotificationProvider>(
              builder: (context, notifProv, _) {
                final count = notifProv.unreadCount;
                const icon = Icon(Icons.notifications_none);
                if (count <= 0) return icon;
                return Badge(
                  label: Text(count > 9 ? '9+' : '$count'),
                  backgroundColor: Colors.red,
                  child: icon,
                );
              },
            ),
            activeIcon: Consumer<NotificationProvider>(
              builder: (context, notifProv, _) {
                final count = notifProv.unreadCount;
                const icon = Icon(Icons.notifications);
                if (count <= 0) return icon;
                return Badge(
                  label: Text(count > 9 ? '9+' : '$count'),
                  backgroundColor: Colors.red,
                  child: icon,
                );
              },
            ),
            label: 'Notifikasi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Saya',
          ),
        ],
      ),
    );
  }
}

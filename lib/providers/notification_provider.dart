import 'package:flutter/material.dart';
import '../services/notification_service.dart';

// Provider manajemen state notifikasi pengguna
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  // Segarkan jumlah notifikasi belum dibaca dari server
  Future<void> refreshUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      _unreadCount = count;
      notifyListeners();
    } catch (_) {
      // Abaikan error saat refresh background
    }
  }

  // Tandai semua notifikasi telah dibaca
  Future<void> markAllRead() async {
    await _notificationService.markAllRead();
    _unreadCount = 0;
    notifyListeners();
  }

  // Tandai satu notifikasi telah dibaca
  Future<void> markRead(int id) async {
    await _notificationService.markRead(id);
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }
}


import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// Model representasi data kartu live statis
class _LiveItem {
  final int id;
  final String title;
  final String viewers;

  const _LiveItem({
    required this.id,
    required this.title,
    required this.viewers,
  });
}

// Layar Shopee Live & Video (tampilan statis)
class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  // Daftar data statis 8 siaran live
  static const List<_LiveItem> _liveItems = [
    _LiveItem(id: 1, title: 'Diskon Kilat 50% Semua Produk', viewers: '1.2RB'),
    _LiveItem(id: 2, title: 'Flash Sale Jam Tangan Mewah', viewers: '850'),
    _LiveItem(id: 3, title: 'Fashion Hijab OOTD Terbaru', viewers: '2.5RB'),
    _LiveItem(id: 4, title: 'Unboxing Gadget & Aksesoris Murah', viewers: '3.1RB'),
    _LiveItem(id: 5, title: 'Pakaian Casual Pria Trendy', viewers: '940'),
    _LiveItem(id: 6, title: 'Skincare Glowing BPOM Original', viewers: '1.8RB'),
    _LiveItem(id: 7, title: 'Elektronik Rumah Tangga Hemat', viewers: '4.2RB'),
    _LiveItem(id: 8, title: 'Serbu Promo Camilan & Minuman', viewers: '720'),
  ];

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Segera hadir'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Shopee Live & Video',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _liveItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final item = _liveItems[index];

          return GestureDetector(
            onTap: () => _showComingSoon(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gambar thumbnail siaran live
                  Image.network(
                    'https://picsum.photos/seed/live${item.id}/400/600',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),

                  // Gradien gelap di bagian bawah untuk keterbacaan teks
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.transparent,
                            Colors.black.withOpacity(0.75),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Badge merah LIVE di pojok kiri atas
                  Positioned(
                    top: 8.0,
                    left: 8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fiber_manual_record,
                            size: 8.0,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.0),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Ikon mata dan jumlah penonton di pojok kanan atas
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 12.0,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            item.viewers,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Judul siaran di bagian bawah kartu
                  Positioned(
                    left: 8.0,
                    right: 8.0,
                    bottom: 8.0,
                    child: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

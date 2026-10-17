import 'package:flutter/material.dart';
import '../../models/address.dart';
import '../../services/address_service.dart';
import '../../services/api_client.dart';
import '../../theme/app_dimens.dart';
import '../../theme/app_theme.dart';
import 'address_form_screen.dart';

// Layar daftar alamat pengiriman pengguna
class AddressListScreen extends StatefulWidget {
  final bool selectMode;

  const AddressListScreen({
    super.key,
    this.selectMode = false,
  });

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final AddressService _addressService = AddressService();

  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _addressService.getAddresses();
      if (mounted) {
        setState(() {
          _addresses = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is ApiException ? e.message : 'Gagal memuat daftar alamat.';
          _isLoading = false;
        });
      }
    }
  }

  // Dialog konfirmasi hapus alamat
  Future<void> _confirmDelete(Address address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Alamat'),
        content: Text(
          'Apakah kamu yakin ingin menghapus alamat penerima "${address.recipientName}"?',
          style: const TextStyle(fontSize: AppDimens.fontTitle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD0011B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _addressService.deleteAddress(address.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alamat berhasil dihapus.'),
            duration: Duration(seconds: 2),
          ),
        );
        _loadAddresses();
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red[700],
          ),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal menghapus alamat.'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.selectMode ? 'Pilih Alamat' : 'Alamat Saya'),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: _buildBody(),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        child: SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
            ),
            icon: const Icon(Icons.add_location_alt_outlined, size: AppDimens.iconMd),
            label: const Text(
              'Tambah Alamat Baru',
              style: TextStyle(fontSize: AppDimens.fontTitle, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddressFormScreen()),
              );
              if (result == true) {
                _loadAddresses();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: AppDimens.space12),
              ElevatedButton(
                onPressed: _loadAddresses,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 72,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppDimens.space12),
            Text(
              'Belum ada alamat',
              style: TextStyle(
                fontSize: AppDimens.fontPrice,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tambahkan alamat pengiriman untuk memudahkan checkout.',
              style: TextStyle(fontSize: AppDimens.fontCaption, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: _loadAddresses,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        itemCount: _addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppDimens.space8),
        itemBuilder: (context, index) {
          final address = _addresses[index];
          return Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              side: BorderSide(
                color: address.isDefault ? AppTheme.primaryColor : Colors.grey[200]!,
                width: address.isDefault ? 1.2 : 1,
              ),
            ),
            child: InkWell(
              onTap: widget.selectMode
                  ? () => Navigator.of(context).pop(address)
                  : null,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    address.recipientName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppDimens.fontTitle,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimens.space8),
                                  Text(
                                    '(${address.phone})',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: AppDimens.fontBody,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                address.fullAddress,
                                style: const TextStyle(fontSize: AppDimens.fontBody, height: 1.3),
                              ),
                              const SizedBox(height: AppDimens.space4),
                              Text(
                                '${address.city}, ${address.postalCode}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: AppDimens.fontCaption,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Ikon Hapus Alamat
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: AppDimens.iconMd),
                          onPressed: () => _confirmDelete(address),
                        ),
                      ],
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(height: AppDimens.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECE7),
                          border: Border.all(color: AppTheme.primaryColor),
                          borderRadius: BorderRadius.circular(AppDimens.radiusSm / 2),
                        ),
                        child: const Text(
                          'Utama',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


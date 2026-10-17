import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';

// Kartu produk bergaya Shopee untuk grid 2 kolom dengan dimensi visual konsisten
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.zero,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar persegi dengan badge diskon
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                            size: 40,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: SizedBox(
                              width: AppDimens.iconLg,
                              height: AppDimens.iconLg,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Badge diskon di pojok kanan atas gambar jika discountPercent > 0
                  if (product.discountPercent > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.space4,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF1C5),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(2),
                          ),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Informasi produk
            Padding(
              padding: const EdgeInsets.all(AppDimens.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul maksimal 2 baris dengan badge Mall di depannya jika isMall
                  RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        if (product.isMall) ...[
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Container(
                              margin: const EdgeInsets.only(right: AppDimens.space4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.space4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD0011B),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Text(
                                'Mall',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                        TextSpan(
                          text: product.name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: AppDimens.fontBody,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.space4),

                  // Harga dan harga coret
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        formatRupiah(product.price),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: AppDimens.fontTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (product.originalPrice != null &&
                          product.originalPrice! > product.price) ...[
                        const SizedBox(width: AppDimens.space4),
                        Expanded(
                          child: Text(
                            formatRupiah(product.originalPrice!),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppDimens.space4),

                  // Rating dan terjual
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 11,
                        color: Color(0xFFFFB800),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppDimens.space8),
                      Text(
                        '${formatSold(product.soldCount)} terjual',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.space4),

                  // Lokasi toko
                  if (product.shopCity != null && product.shopCity!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            product.shopCity!,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

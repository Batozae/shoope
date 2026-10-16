import '../models/category.dart';
import '../models/product.dart';
import 'api_client.dart';

// Response model pembungkus daftar produk dan informasi total halaman
class ProductListResult {
  final List<Product> items;
  final int totalPages;

  ProductListResult({
    required this.items,
    required this.totalPages,
  });
}

// Layanan API untuk produk dan kategori
class ProductService {
  final ApiClient _apiClient = ApiClient();

  // Ambil daftar semua kategori
  Future<List<Category>> getCategories() async {
    final data = await _apiClient.get('/categories', withAuth: false);
    if (data is List) {
      return data
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Ambil daftar produk dengan filter, sort, dan paginasi
  Future<ProductListResult> getProducts({
    String? search,
    int? categoryId,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (categoryId != null) {
      queryParams['category_id'] = categoryId.toString();
    }
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final endpoint = '/products?$queryString';

    final data = await _apiClient.get(endpoint, withAuth: false) as Map<String, dynamic>;

    final rawItems = data['items'] as List? ?? [];
    final items = rawItems
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();

    final pagination = data['pagination'] as Map<String, dynamic>?;
    final totalPages = pagination?['total_pages'] is int
        ? pagination!['total_pages'] as int
        : int.tryParse(pagination?['total_pages']?.toString() ?? '1') ?? 1;

    return ProductListResult(
      items: items,
      totalPages: totalPages,
    );
  }

  // Ambil detail produk berdasarkan ID
  Future<ProductDetail> getProductDetail(int id) async {
    final data = await _apiClient.get('/products/$id', withAuth: false) as Map<String, dynamic>;
    return ProductDetail.fromJson(data);
  }
}


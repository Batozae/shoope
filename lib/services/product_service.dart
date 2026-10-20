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
class ProductService { //Service adalah lapisan antara layar dan ApiClient: layar cukup memanggil method, tanpa tahu detail HTTP.
  final ApiClient _apiClient = ApiClient();

  // Ambil daftar semua kategori
  Future<List<Category>> getCategories() async { //	getCategories: endpoint publik (withAuth false). Hasil JSON diubah menjadi daftar objek Category.
    final data = await _apiClient.get('/categories', withAuth: false);
    if (data is List) {
      return data
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Ambil daftar produk dengan filter, sort, dan paginasi
  Future<ProductListResult> getProducts({ //	getProducts: satu method dipakai Beranda dan Pencarian, dengan parameter opsional search, categoryId, sort, page, dan limit.
    String? search,
    int? categoryId,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{ //	Query selalu memuat page dan limit. Search, kategori, dan sort ditambahkan hanya kalau diisi (baris 44 sampai 52).
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

    final queryString = Uri(queryParameters: queryParams).query; //	Uri(queryParameters) membuat query string yang aman, karakter khusus di-encode otomatis.
    final endpoint = '/products?$queryString';

    final data = await _apiClient.get(endpoint, withAuth: false) as Map<String, dynamic>;

    final rawItems = data['items'] as List? ?? []; //Ubah JSON menjadi objek Product. Total halaman diambil dari pagination (baris 64) dengan konversi aman.
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

//
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Nama tabel di Supabase
  final String _tableName = 'products';

  // ==================== CREATE ====================
  // Menambah produk baru
  Future<Product> createProduct(Product product) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(product.toJson())
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menambah produk: $e');
    }
  }

  // ==================== READ ====================
  // Ambil semua produk milik user yang sedang login
  Future<List<Product>> getProducts() async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User belum login');
      }

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data produk: $e');
    }
  }

  // Ambil produk berdasarkan ID
  Future<Product> getProductById(int id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil detail produk: $e');
    }
  }

  // Stream - Real-time data (auto-update ketika ada perubahan)
  Stream<List<Product>> getProductsStream() {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      return Stream.value([]);
    }

    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => Product.fromJson(json)).toList());
  }

  // ==================== UPDATE ====================
  // Update produk
  Future<Product> updateProduct(int id, Product product) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .update(product.toJson())
          .eq('id', id)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengupdate produk: $e');
    }
  }

  // ==================== DELETE ====================
  // Hapus produk
  Future<void> deleteProduct(int id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }

  // ==================== SEARCH ====================
  // Cari produk berdasarkan nama
  Future<List<Product>> searchProducts(String keyword) async {
    try {
      final userId = _supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User belum login');
      }

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .ilike('name', '%$keyword%') // Case-insensitive search
          .order('created_at', ascending: false);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mencari produk: $e');
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // ==================== PICK IMAGE ====================

  // Pilih foto dari galeri
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85, // Kompresi 85%
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      throw Exception('Gagal memilih foto: $e');
    }
  }

  // Ambil foto dari kamera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      throw Exception('Gagal mengambil foto: $e');
    }
  }

  // ==================== UPLOAD IMAGE ====================

  // Upload foto produk
  Future<String> uploadProductImage({
    required File file,
    required String userId,
    required int productId,
  }) async {
    try {
      // Generate unique filename
      final String fileExt = path.extension(file.path);
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final String filePath = '$userId/$productId/$fileName';

      // Upload file
      await _supabase.storage.from('product-images').upload(filePath, file);

      // Get public URL
      final String publicUrl = _supabase.storage
          .from('product-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Gagal upload foto produk: $e');
    }
  }

  // Upload avatar
  Future<String> uploadAvatar({
    required File file,
    required String userId,
  }) async {
    try {
      final String fileExt = path.extension(file.path);
      // Tambahkan timestamp untuk membuat filename unik
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${userId}_$timestamp$fileExt';
      final String filePath = '$userId/$fileName';

      // Upload file (upsert akan replace jika path sama, tapi kita pakai timestamp jadi selalu beda)
      await _supabase.storage
          .from('avatars')
          .upload(
            filePath,
            file,
            fileOptions: const FileOptions(upsert: true), // Replace if exists
          );

      // Get public URL
      final String publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Gagal upload avatar: $e');
    }
  }

  // ==================== DELETE IMAGE ====================

  // Hapus foto produk dari URL
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      // Extract path dari URL
      // URL format: https://xxx.supabase.co/storage/v1/object/public/product-images/userId/productId/filename.jpg
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;

      // Get path after 'product-images/'
      final bucketIndex = segments.indexOf('product-images');
      if (bucketIndex == -1) return;

      final filePath = segments.sublist(bucketIndex + 1).join('/');

      // Delete file
      await _supabase.storage.from('product-images').remove([filePath]);
    } catch (e) {
      throw Exception('Gagal menghapus foto: $e');
    }
  }

  // Hapus avatar
  Future<void> deleteAvatar(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;

      final bucketIndex = segments.indexOf('avatars');
      if (bucketIndex == -1) return;

      final filePath = segments.sublist(bucketIndex + 1).join('/');

      await _supabase.storage.from('avatars').remove([filePath]);
    } catch (e) {
      throw Exception('Gagal menghapus avatar: $e');
    }
  }

  // ==================== SHOW PICKER DIALOG ====================

  // Dialog untuk pilih sumber foto (galeri/kamera)
  Future<File?> showImageSourceDialog(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    if (source == ImageSource.gallery) {
      return await pickImageFromGallery();
    } else {
      return await pickImageFromCamera();
    }
  }
}

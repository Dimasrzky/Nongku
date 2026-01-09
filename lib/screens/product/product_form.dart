import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/product.dart';
import '../../services/database.dart';
import '../../services/storage.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _databaseService = DatabaseService();
  final _storageService = StorageService();

  bool _isLoading = false;
  bool get _isEditMode => widget.product != null;

  File? _selectedImage; // Foto yang dipilih
  String? _currentImageUrl; // URL foto existing (untuk edit mode)

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _currentImageUrl = widget.product!.imageUrl; // Load existing image
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // Pick image
  Future<void> _pickImage() async {
    try {
      final file = await _storageService.showImageSourceDialog(context);
      if (file != null) {
        setState(() {
          _selectedImage = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Remove selected image
  void _removeImage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Foto'),
        content: const Text('Yakin ingin menghapus foto produk?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _selectedImage = null;
        _currentImageUrl = null;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User belum login');
      }

      String? imageUrl = _currentImageUrl;

      // Jika ada foto baru dipilih, upload dulu
      if (_selectedImage != null) {
        // Jika edit mode dan sudah ada foto lama, hapus dulu
        if (_isEditMode && _currentImageUrl != null) {
          try {
            await _storageService.deleteProductImage(_currentImageUrl!);
          } catch (e) {
            // Silently ignore error when deleting old image
          }
        }

        // Upload foto baru
        // Generate temporary productId untuk path
        final tempProductId = _isEditMode
            ? widget.product!.id!
            : DateTime.now().millisecondsSinceEpoch;

        imageUrl = await _storageService.uploadProductImage(
          file: _selectedImage!,
          userId: userId,
          productId: tempProductId,
        );
      }

      final product = Product(
        id: _isEditMode ? widget.product!.id : null,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: int.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        userId: userId,
        imageUrl: imageUrl,
      );

      if (_isEditMode) {
        await _databaseService.updateProduct(widget.product!.id!, product);
      } else {
        await _databaseService.createProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Produk berhasil diupdate'
                  : 'Produk berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image Picker Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _currentImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _currentImageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambah Foto Produk',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                  ),
                  // Tombol pilih/ganti foto
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: FloatingActionButton.small(
                      onPressed: _pickImage,
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                  // Tombol hapus foto (jika ada foto)
                  if (_selectedImage != null || _currentImageUrl != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: _removeImage,
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nama Produk
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Produk *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama produk tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Deskripsi
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Harga
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Harga (Rp) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga tidak boleh kosong';
                }
                if (int.tryParse(value) == null) {
                  return 'Harga harus berupa angka';
                }
                if (int.parse(value) < 0) {
                  return 'Harga tidak boleh negatif';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Stok
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Stok *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Stok tidak boleh kosong';
                }
                if (int.tryParse(value) == null) {
                  return 'Stok harus berupa angka';
                }
                if (int.parse(value) < 0) {
                  return 'Stok tidak boleh negatif';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Tombol Simpan
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProduct,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isEditMode ? 'Update' : 'Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

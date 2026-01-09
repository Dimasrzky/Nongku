import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar dengan foto besar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 80,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Foto tidak dapat dimuat',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.deepPurple.shade50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 100,
                            color: Colors.deepPurple.shade200,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada foto',
                            style: TextStyle(
                              color: Colors.deepPurple.shade300,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Produk
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Harga
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          currencyFormat.format(product.price),
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Info Cards Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Stok Card
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.inventory_2,
                          label: 'Stok',
                          value: product.stock.toString(),
                          color: product.stock > 0 ? Colors.blue : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Status Card
                      Expanded(
                        child: _buildInfoCard(
                          icon: product.stock > 0
                              ? Icons.check_circle
                              : Icons.cancel,
                          label: 'Status',
                          value: product.stock > 0 ? 'Tersedia' : 'Habis',
                          color: product.stock > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Deskripsi Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            size: 24,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Deskripsi Produk',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          product.description ?? 'Tidak ada deskripsi',
                          style: TextStyle(
                            fontSize: 16,
                            color: product.description != null
                                ? Colors.grey.shade800
                                : Colors.grey.shade500,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // Detail Informasi Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 24,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Informasi Detail',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ID Produk
                      if (product.id != null)
                        _buildDetailRow(
                          icon: Icons.tag,
                          label: 'ID Produk',
                          value: '#${product.id}',
                        ),

                      // Tanggal Dibuat
                      if (product.createdAt != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Dibuat pada',
                          value: DateFormat(
                            'dd MMMM yyyy, HH:mm',
                          ).format(product.createdAt!),
                        ),
                      ],

                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.attach_money,
                        label: 'Harga Satuan',
                        value: currencyFormat.format(product.price),
                      ),
                    ],
                  ),
                ),

                // Spacing bottom
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),

      // Floating Action Button untuk Edit (Optional)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur edit akan segera hadir')),
          );
        },
        icon: const Icon(Icons.edit),
        label: const Text('Edit Produk'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Widget untuk Info Card (Stok & Status)
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Detail Row
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

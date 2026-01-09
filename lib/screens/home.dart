import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../models/user.dart';
import 'auth/login.dart';
import 'product/product_list.dart';
import 'profile/edit_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final authService = AuthService();
  UserModel? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => isLoading = true);
    try {
      final profile = await authService.getCurrentUserProfile();
      setState(() {
        userProfile = profile;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple.shade100,
                    child: userProfile?.avatarUrl != null
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: userProfile!.avatarUrl!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) => Text(
                                (userProfile?.fullName ?? user?.email ?? 'U')[0]
                                    .toUpperCase(),
                                style: const TextStyle(fontSize: 40),
                              ),
                            ),
                          )
                        : Text(
                            (userProfile?.fullName ?? user?.email ?? 'U')[0]
                                .toUpperCase(),
                            style: const TextStyle(fontSize: 40),
                          ),
                  ),

                  // Nama
                  Text(
                    userProfile?.fullName ?? 'Nama belum diisi',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Email
                  Text(
                    user?.email ?? "Unknown",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),

                  // Bio
                  if (userProfile?.bio != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        userProfile!.bio!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Tombol Edit Profil
                  OutlinedButton.icon(
                    onPressed: () async {
                      if (userProfile != null) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProfileScreen(user: userProfile!),
                          ),
                        );
                        // Jika ada perubahan, reload profil
                        if (result == true) {
                          _loadUserProfile();
                        }
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profil'),
                  ),
                  const SizedBox(height: 16),

                  // Tombol ke Product List
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductListScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.inventory_2),
                    label: const Text('Kelola Produk'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

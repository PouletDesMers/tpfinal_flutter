import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/favorites_provider.dart';

// Écran de détail d'un produit — affiché après un clic sur une carte produit
class ProductDetailScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final productId = product['id'] as int;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Retour à la liste
        ),
        title: Text(
          product['titre'] ?? 'Détail',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favs, _) {
              final isFav = favs.isFavorite(productId);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : Colors.white,
                ),
                onPressed: () => favs.toggleFavorite(productId),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image pleine largeur avec coins inférieurs arrondis
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              child: Image.network(
                product['image'] ?? '',
                width: double.infinity,
                height: 320,
                fit: BoxFit.cover,
                // Fallback si l'image ne charge pas
                errorBuilder: (_, _, _) => Container(
                  height: 320,
                  color: Colors.white.withValues(alpha: 0.05),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 80,
                    color: Colors.white38,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre du produit
                  Text(
                    product['titre'] ?? '',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Prix
                  Text(
                    '${product['prix']} €',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Badge catégorie
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      product['categorie'] ?? '',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Description complète
                  Text(
                    product['description'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                      height: 1.5,
                    ),
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

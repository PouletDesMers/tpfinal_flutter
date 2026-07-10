import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/auth_provider.dart';
import '../services/favorites_provider.dart';
import 'product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  String? _error;

  // Filtres
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  List<String> _categories = [];
  bool _showFavoritesOnly = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Appel GET vers l'API avec les filtres en query params
  Future<void> _fetchProducts() async {
    final params = <String, String>{};
    if (_searchQuery.isNotEmpty) params['search'] = _searchQuery;
    if (_selectedCategory != null) params['categorie'] = _selectedCategory!;

    final uri = Uri.parse('$apiBaseUrl/api/produits')
        .replace(queryParameters: params.isNotEmpty ? params : null);

    try {
      final response = await http.get(uri);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _products = data;
          // On met à jour les catégories seulement si aucun filtre n'est actif
          // (pour que la liste des chips reste complète)
          if (_searchQuery.isEmpty && _selectedCategory == null) {
            _categories =
                data
                    .map((p) => p['categorie'] as String)
                    .toSet()
                    .cast<String>()
                    .toList()
                  ..sort();
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur de chargement';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger les produits';
        _isLoading = false;
      });
    }
  }

  // Recherche avec debounce pour éviter les appels trop fréquents
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      setState(() => _searchQuery = value);
      _fetchProducts();
    });
  }

  // Déconnexion via AuthProvider, puis retour à l'écran de connexion
  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Barre de recherche + filtres par catégorie
  Widget _buildFiltersBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Champ de recherche
          SizedBox(
            height: 44,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[500],
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[500],
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _debounce?.cancel();
                          _fetchProducts();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (_categories.isNotEmpty) ...[
            const SizedBox(height: 10),
            // Filtres par catégorie + favoris (scroll horizontal)
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length + 2,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  // index 0 = filtre favoris
                  // index 1 = Tout
                  // index 2+ = catégories
                  if (index == 0) {
                    return _FilterChip(
                      label: '❤️ Favoris',
                      selected: _showFavoritesOnly,
                      onTap: () {
                        setState(
                          () => _showFavoritesOnly = !_showFavoritesOnly,
                        );
                      },
                    );
                  }

                  final isAll = index == 1;
                  final selected = isAll
                      ? _selectedCategory == null
                      : _categories[index - 2] == _selectedCategory;

                  return _FilterChip(
                    label: isAll ? 'Tout' : _categories[index - 2],
                    selected: selected,
                    onTap: () {
                      setState(() {
                        _selectedCategory = isAll
                            ? null
                            : _categories[index - 2];
                      });
                      _debounce?.cancel();
                      _fetchProducts();
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupère le prénom depuis l'utilisateur connecté dans AuthProvider
    final auth = context.watch<AuthProvider>();
    final prenom = auth.user?.prenom ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Bonjour $prenom',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    if (_products.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isNotEmpty || _selectedCategory != null
              ? 'Aucun résultat trouvé'
              : 'Aucun produit',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    // Filtre favoris local (optionnel)
    final displayProducts = _showFavoritesOnly
        ? _products.where((p) {
            final favs = context.read<FavoritesProvider>();
            return favs.isFavorite(p['id'] as int);
          }).toList()
        : _products;

    if (displayProducts.isEmpty) {
      return Center(
        child: Text(
          'Aucun favori',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchProducts,
      color: Colors.white,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: displayProducts.length,
        itemBuilder: (context, index) => _ProductCard(
          product: displayProducts[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProductDetailScreen(product: displayProducts[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Petits widgets privés ───────────────────────────────────────────────

/// Chip de filtre réutilisable (catégorie ou favoris)
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Carte produit avec bouton cœur favoris
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final productId = product['id'] as int;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.07),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + bouton favori superposé
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product['image'] ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.white.withValues(alpha: 0.05),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Consumer<FavoritesProvider>(
                      builder: (context, favs, _) {
                        final isFav = favs.isFavorite(productId);
                        return GestureDetector(
                          onTap: () => favs.toggleFavorite(productId),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.redAccent : Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['titre'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product['prix']} €',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
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

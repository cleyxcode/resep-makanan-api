import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/favorite_service.dart';
import '../widgets/favorite_button.dart';
import 'recipe_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final TextEditingController _searchController = TextEditingController();
  List<Recipe> _filteredFavorites = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _updateFilteredFavorites();
    // Listen to favorite service changes
    _favoriteService.addListener(_onFavoriteServiceChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _favoriteService.removeListener(_onFavoriteServiceChanged);
    super.dispose();
  }

  void _onFavoriteServiceChanged() {
    // Update filtered favorites when favorite service changes
    if (mounted) {
      _updateFilteredFavorites();
    }
  }

  void _updateFilteredFavorites() {
    setState(() {
      _filteredFavorites = _favoriteService.searchFavorites(_searchQuery);
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _updateFilteredFavorites();
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Semua Favorite'),
          content: const Text('Apakah Anda yakin ingin menghapus semua resep favorite?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _favoriteService.clearAllFavorites();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua favorite telah dihapus'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus Semua'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Flexible(
                child: Text(
                  'Resep Favorite',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_favoriteService.favoriteCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (_favoriteService.favoriteCount > 0)
            IconButton(
              onPressed: _showClearAllDialog,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Hapus Semua',
            ),
        ],
      ),
      body: _favoriteService.favoriteCount == 0
          ? _buildEmptyState()
          : Column(
              children: [
                // Search Bar
                if (_favoriteService.favoriteCount > 0) _buildSearchBar(),
                
                // Favorite List
                Expanded(
                  child: _filteredFavorites.isEmpty && _searchQuery.isNotEmpty
                      ? _buildNoSearchResults()
                      : _buildFavoriteList(),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Belum Ada Resep Favorite',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tap ♥ pada resep untuk menambahkannya ke favorite',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari resep favorite...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ditemukan resep dengan kata "$_searchQuery"',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _filteredFavorites.length,
      itemBuilder: (context, index) {
        final recipe = _filteredFavorites[index];
        return _buildFavoriteCard(recipe);
      },
    );
  }

  Widget _buildFavoriteCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipe: recipe),
            ),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Recipe Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child: recipe.image.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          recipe.image,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
              ),
              
              const SizedBox(width: 12),
              
              // Recipe Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${recipe.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 14,
                          color: Colors.orange[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap untuk detail',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Favorite Button
              FavoriteButton(
                recipe: recipe,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
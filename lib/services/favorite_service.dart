import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class FavoriteService extends ChangeNotifier {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final List<Recipe> _favoriteRecipes = [];

  // Getter untuk list favorite recipes
  List<Recipe> get favoriteRecipes => List.unmodifiable(_favoriteRecipes);

  // Check apakah resep sudah di favorite
  bool isFavorite(int recipeId) {
    return _favoriteRecipes.any((recipe) => recipe.id == recipeId);
  }

  // Tambah resep ke favorite
  void addToFavorite(Recipe recipe) {
    if (!isFavorite(recipe.id)) {
      _favoriteRecipes.add(recipe);
      notifyListeners();
      print('Resep "${recipe.title}" ditambahkan ke favorite');
    }
  }

  // Hapus resep dari favorite
  void removeFromFavorite(int recipeId) {
    final index = _favoriteRecipes.indexWhere((recipe) => recipe.id == recipeId);
    if (index != -1) {
      final removedRecipe = _favoriteRecipes.removeAt(index);
      notifyListeners();
      print('Resep "${removedRecipe.title}" dihapus dari favorite');
    }
  }

  // Toggle favorite status
  void toggleFavorite(Recipe recipe) {
    if (isFavorite(recipe.id)) {
      removeFromFavorite(recipe.id);
    } else {
      addToFavorite(recipe);
    }
  }

  // Get jumlah favorite
  int get favoriteCount => _favoriteRecipes.length;

  // Clear all favorites
  void clearAllFavorites() {
    _favoriteRecipes.clear();
    notifyListeners();
    print('Semua favorite dihapus');
  }

  // Search favorite recipes
  List<Recipe> searchFavorites(String query) {
    if (query.isEmpty) return favoriteRecipes;
    
    return _favoriteRecipes.where((recipe) {
      return recipe.title.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
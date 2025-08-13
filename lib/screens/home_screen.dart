import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Recipe> recipes = []; // list untuk menyimpan resep
  bool isLoading = true; // status loading
  String errorMessage = ''; // pesan error

  @override
  void initState() {
    super.initState();
    loadRecipes(); // panggil fungsi load data
  }

  // Fungsi untuk memuat data resep
  Future<void> loadRecipes() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await ApiService.searchRecipes(
        query: 'pasta', // cari resep pasta
        number: 10, // ambil 10 resep
      );

      setState(() {
        recipes = response.results;
        isLoading = false;
      });

      print('Berhasil memuat ${recipes.length} resep'); // debug
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      print('Error di loadRecipes: $e'); // debug
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe App'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      // Tampilkan loading
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat resep...'),
          ],
        ),
      );
    } else if (errorMessage.isNotEmpty) {
      // Tampilkan error
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Error:'),
            Text(errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadRecipes,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    } else if (recipes.isEmpty) {
      // Tidak ada data
      return const Center(
        child: Text('Tidak ada resep ditemukan'),
      );
    } else {
      // Tampilkan data resep
      return ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return buildRecipeCard(recipe);
        },
      );
    }
  }

  Widget buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Gambar resep
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
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported);
                        },
                      ),
                    )
                  : const Icon(Icons.image_not_supported),
            ),
            const SizedBox(width: 12),
            // Informasi resep
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
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${recipe.id}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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
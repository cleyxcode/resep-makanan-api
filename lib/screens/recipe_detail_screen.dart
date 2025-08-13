import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe; // resep yang dipilih

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? detailedRecipe; // detail resep dari API
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadRecipeDetails();
  }

  Future<void> loadRecipeDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final details = await ApiService.getRecipeDetails(widget.recipe.id);
      
      setState(() {
        detailedRecipe = details;
        isLoading = false;
      });

      print('Berhasil memuat detail resep: ${details.title}');
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      print('Error loading details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipe.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat detail resep...'),
          ],
        ),
      );
    } else if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Gagal memuat detail resep'),
            Text(errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadRecipeDetails,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    } else if (detailedRecipe == null) {
      return const Center(
        child: Text('Detail resep tidak ditemukan'),
      );
    } else {
      return buildRecipeDetail();
    }
  }

  Widget buildRecipeDetail() {
    final recipe = detailedRecipe!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar resep
          buildRecipeImage(),
          
          const SizedBox(height: 20),
          
          // Judul resep
          buildTitle(),
          
          const SizedBox(height: 16),
          
          // Info singkat (waktu, porsi)
          buildQuickInfo(),
          
          const SizedBox(height: 20),
          
          // Ringkasan
          if (recipe.summary != null) buildSummary(),
          
          const SizedBox(height: 20),
          
          // Bahan-bahan
          if (recipe.ingredients != null && recipe.ingredients!.isNotEmpty)
            buildIngredients(),
          
          const SizedBox(height: 20),
          
          // Instruksi
          if (recipe.instructions != null) buildInstructions(),
        ],
      ),
    );
  }

  Widget buildRecipeImage() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: detailedRecipe!.image.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                detailedRecipe!.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            )
          : const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 64,
                color: Colors.grey,
              ),
            ),
    );
  }

  Widget buildTitle() {
    return Text(
      detailedRecipe!.title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget buildQuickInfo() {
    return Row(
      children: [
        if (detailedRecipe!.readyInMinutes != null)
          buildInfoChip(
            Icons.schedule,
            '${detailedRecipe!.readyInMinutes} menit',
            Colors.blue,
          ),
        
        if (detailedRecipe!.servings != null) ...[
          const SizedBox(width: 12),
          buildInfoChip(
            Icons.people,
            '${detailedRecipe!.servings} porsi',
            Colors.green,
          ),
        ],
      ],
    );
  }

  Widget buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tentang Resep',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            // Remove HTML tags dari summary
            detailedRecipe!.summary!.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bahan-bahan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...detailedRecipe!.ingredients!.map((ingredient) => 
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.circle,
                  size: 6,
                  color: Colors.orange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ingredient,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )
        ).toList(),
      ],
    );
  }

  Widget buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cara Memasak',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            // Remove HTML tags dari instructions
            detailedRecipe!.instructions!.replaceAll(RegExp(r'<[^>]*>'), ''),
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
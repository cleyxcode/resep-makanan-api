import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class ApiService {
  // API Key Anda
  static const String apiKey = '0061cde1f0184bc0b610d2bfdc9e0412';
  static const String baseUrl = 'https://api.spoonacular.com';

  // Fungsi untuk search resep dengan filter
  static Future<RecipeResponse> searchRecipes({
    String query = 'pasta', // default search
    int number = 10, // jumlah hasil
    String? diet, // filter diet
    String? type, // filter meal type
    int? maxReadyTime, // filter waktu memasak
  }) async {
    try {
      // Build URL dengan parameter
      var urlString = '$baseUrl/recipes/complexSearch?apiKey=$apiKey&query=$query&number=$number';
      
      // Tambahkan filter jika ada
      if (diet != null && diet.isNotEmpty) {
        urlString += '&diet=$diet';
      }
      
      if (type != null && type.isNotEmpty) {
        urlString += '&type=$type';
      }
      
      if (maxReadyTime != null) {
        urlString += '&maxReadyTime=$maxReadyTime';
      }
      
      final url = Uri.parse(urlString);

      print('Memanggil API: $url'); // untuk debug

      // Panggil API
      final response = await http.get(url);

      print('Status Code: ${response.statusCode}'); // untuk debug
      print('Response Body: ${response.body}'); // untuk debug

      if (response.statusCode == 200) {
        // Berhasil
        final jsonData = json.decode(response.body);
        return RecipeResponse.fromJson(jsonData);
      } else {
        // Gagal
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e'); // untuk debug
      throw Exception('Error: $e');
    }
  }

  // Fungsi untuk mendapatkan detail resep
  static Future<Recipe> getRecipeDetails(int recipeId) async {
    try {
      // URL endpoint untuk detail resep
      final url = Uri.parse(
          '$baseUrl/recipes/$recipeId/information?apiKey=$apiKey');

      print('Memanggil Detail API: $url'); // untuk debug

      // Panggil API
      final response = await http.get(url);

      print('Detail Status Code: ${response.statusCode}'); // untuk debug

      if (response.statusCode == 200) {
        // Berhasil
        final jsonData = json.decode(response.body);
        return Recipe.fromJson(jsonData);
      } else {
        // Gagal
        throw Exception('Gagal memuat detail resep: ${response.statusCode}');
      }
    } catch (e) {
      print('Error Detail: $e'); // untuk debug
      throw Exception('Error: $e');
    }
  }
}
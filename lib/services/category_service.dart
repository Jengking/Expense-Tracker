import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';

class CategoryService {
  final String _url = "https://media.halogen.my/experiment/mobile/expenseCategories.json";

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(_url));
      if(response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> expensesCategories = jsonResponse['expenseCategories'];
        return expensesCategories
            .map((dynamic item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load categories data: ${response.statusCode} - ${response.body}');
      }
    } catch(e) {
      print('Error fetching data: $e');
      throw Exception('Failed to fetch data: $e');
    }
  }
}
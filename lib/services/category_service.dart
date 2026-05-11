import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/category.dart';

class CategoryService {
  final String _assetPath = "assets/json/expenseCategories.json";

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await rootBundle.loadString(_assetPath);
      Map<String, dynamic> jsonResponse = jsonDecode(response);
      List<dynamic> expensesCategories = jsonResponse['expenseCategories'];
      return expensesCategories
          .map((dynamic item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch(e) {
      print('Error fetching data: $e');
      throw Exception('Failed to fetch data: $e');
    }
  }
}
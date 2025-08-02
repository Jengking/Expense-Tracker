import 'package:expense_tracker/models/category.dart';
import 'package:expense_tracker/models/expenses.dart';
import 'package:expense_tracker/services/category_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';

class ExpensesProvider with ChangeNotifier {
  List<Expenses> _expenses = [];
  List<Category> _categories = [];
  double _monthlyBudget = 0.0;
  String? _selectedCategoryFilter;
  bool _isLoadingCategories = false;
  String? _categoriesFetchError;

  //getters
  List<Expenses> get expenses => _expenses;
  List<Category> get categories => _categories;
  double get monthlyBudget => _monthlyBudget;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get categoriesFetchError => _categoriesFetchError;

  double get currentBalance {
    double totalExpenses = _expenses.fold(0.0, (sum, item) => sum + item.amount);
    return _monthlyBudget - totalExpenses;
  }

  ExpensesProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await fetchExpenses();
    await _loadMonthlyBudget();
    await fetchCategories();
    notifyListeners();
  }

  //to manage expenses
  Future<void> fetchExpenses() async {
    _expenses = await DatabaseHelper().getExpenses();
    notifyListeners();
  }

  Future<void> addExpense(Expenses expense) async {
    await DatabaseHelper().insertExpense(expense);
    await fetchExpenses();
  }

  Future<void> updateExpense(Expenses expense) async {
    await DatabaseHelper().updateExpenses(expense);
    await fetchExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await DatabaseHelper().deleteExpenses(id);
    await fetchExpenses();
  }

  //to manage categories
  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    _categoriesFetchError = null;
    notifyListeners();

    try {
      _categories = await CategoryService().fetchCategories();
    } catch (e) {
      _categoriesFetchError = 'Failed loading categories.';
      print('Error loading categories in provider: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  //budget management
  Future<void> _loadMonthlyBudget() async {
    final prefs = await SharedPreferences.getInstance();
    _monthlyBudget = prefs.getDouble('monthlyBudget') ?? 0.0;
  }

  Future<void> setMonthlyBudget(double budget) async {
    _monthlyBudget = budget;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthlyBudget', budget);
    notifyListeners();
  }

  //expenses filtering
  void filterExpensesByCategory(String? category) {
    _selectedCategoryFilter = category;
    notifyListeners();
  }

  List<Expenses> get filteredExpenses {
    if (_selectedCategoryFilter == null || _selectedCategoryFilter == 'All') {
      return _expenses;
    } else {
      return _expenses.where((expense) => expense.category == _selectedCategoryFilter).toList();
    }
  }
}

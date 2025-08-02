import 'package:expense_tracker/models/expenses.dart';
import 'package:expense_tracker/providers/expenses_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expenses? expense;

  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _selectedCategory = widget.expense!.category;
      _amountController.text = widget.expense!.amount.toStringAsFixed(2);
      _selectedDate = widget.expense!.date;
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      _notesController.text = widget.expense!.notes ?? '';
    } else {
      _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    }
  }

  //date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  //handle submission
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final expenseProvider = Provider.of<ExpensesProvider>(context, listen: false);

      final newExpense = Expenses(
        id: widget.expense?.id,
        category: _selectedCategory!,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        notes: _notesController.text.isEmpty ? null : _notesController.text
      );

      if (widget.expense == null) {
        expenseProvider.addExpense(newExpense);
        snackBarComponent(context, 'Expense added successfully');
      } else {
        expenseProvider.updateExpense(newExpense);
        snackBarComponent(context, 'Expense updated successfully');
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Consumer<ExpensesProvider>(
            builder: (context, expenseProvider, child) {
              if (expenseProvider.isLoadingCategories) {
                return const Center(child: CircularProgressIndicator());
              }
              if (expenseProvider.categoriesFetchError != null) {
                return Center(
                  child: Text(
                    expenseProvider.categoriesFetchError!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              //if categories are fetched - show form
              return ListView(
                children: [
                  //category dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategory,
                    items: expenseProvider.categories.map((category){
                      return DropdownMenuItem(
                        value: category.name,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  //amount
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (e.g. 100.00)',
                      suffixText: 'RM',
                      border: OutlineInputBorder()
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number (e.g. 100.00)';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Please enter an amount greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  //Date picker
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  //Notes
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 15),
                  //submit button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontSize: 18)
                    ),
                    child: Text(widget.expense == null ? 'Add Expense' : 'Update Expense'),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void snackBarComponent(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

}
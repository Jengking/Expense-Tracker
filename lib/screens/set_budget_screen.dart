import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expenses_provider.dart';

class SetBudgetScreen extends StatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final expenseProvider = Provider.of<ExpensesProvider>(context, listen: false);
    _budgetController.text = expenseProvider.monthlyBudget.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Monthly Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monthly Budget (RM)',
                  border: OutlineInputBorder()
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Please enter a positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBudget,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18)
                ),
                child: const Text('Save Budget'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _saveBudget() {
    if (_formKey.currentState!.validate()) {
      final newBudget = double.parse(_budgetController.text);
      final expenseProvider = Provider.of<ExpensesProvider>(context, listen: false);
      expenseProvider.setMonthlyBudget(newBudget);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly budget updated!')),
      );
      Navigator.of(context).pop();
    }
  }
}
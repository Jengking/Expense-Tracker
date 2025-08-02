import 'package:expense_tracker/models/expenses.dart';
import 'package:expense_tracker/providers/expenses_provider.dart';
import 'package:expense_tracker/screens/set_budget_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'expense_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    //reserved for refreshing data if need
  }

  List<PieChartSectionData> _getSections(List<Expenses> expenses) {
    if (expenses.isEmpty) {
      return [];
    }

    Map<String, double> categorySums = {};
    double totalAmount = 0;

    for(var expense in expenses) {
      categorySums.update(expense.category, (value) => value + expense.amount,
      ifAbsent: () => expense.amount);
      totalAmount += expense.amount;
    }

    List<PieChartSectionData> sections = [];
    int i = 0;

    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.brown,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.pink,
    ];

    categorySums.forEach((category, sum) {
      final double percentage = (sum/totalAmount) * 100;
      final color = colors[i % colors.length];

      sections.add(
        PieChartSectionData(
          color: color,
          value: percentage,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: _buildCategoryBadge(category, color),
          badgePositionPercentageOffset: 1.0,
        )
      );
      i++;
    });
    return sections;
  }

  Widget _buildCategoryBadge(String category, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            tooltip: 'Set Monthly Budget',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SetBudgetScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Categories',
            onPressed: () {
              Provider.of<ExpensesProvider>(
                context,
                listen: false,
              ).fetchCategories();
            },
          ),
        ],
      ),
      body: Consumer<ExpensesProvider>(
        builder: (context, expensesProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Monthly Budget: RM ${expensesProvider.monthlyBudget.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Current Balance: RM ${expensesProvider.currentBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            expensesProvider.currentBalance < 0
                                ? Colors.red
                                : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              //pie chart
              if (expensesProvider.filteredExpenses.isNotEmpty)
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(16),
                  child: PieChart(
                    PieChartData(
                      sections: _getSections(expensesProvider.filteredExpenses),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {

                      }),
                    )
                  ),
                ),
              const SizedBox(height: 20),
              //category filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child:
                    expensesProvider.isLoadingCategories
                        ? const Center(child: CircularProgressIndicator())
                        : expensesProvider.categoriesFetchError != null
                        ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            expensesProvider.categoriesFetchError!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Filter by Category',
                            border: OutlineInputBorder(),
                          ),
                          value:
                              expensesProvider.selectedCategoryFilter ?? 'All',
                          items: [
                            const DropdownMenuItem(
                              value: 'All',
                              child: Text('All Categories'),
                            ),
                            ...expensesProvider.categories.map((category) {
                              return DropdownMenuItem(
                                value: category.name,
                                child: Text(category.name),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            expensesProvider.filterExpensesByCategory(value);
                          },
                        ),
              ),
              const SizedBox(height: 10),
              //expenses list
              Expanded(
                child:
                    expensesProvider.filteredExpenses.isEmpty
                        ? const Center(child: Text('No expenses data found.'))
                        : ListView.builder(
                          itemCount: expensesProvider.filteredExpenses.length,
                          itemBuilder: (context, index) {
                            final expense =
                                expensesProvider.filteredExpenses[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: ListTile(
                                title: Text(
                                  expense.category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${DateFormat('dd/MM/yyyy').format(expense.date)}\n${expense.notes ?? ''}',
                                ),
                                trailing: Text(
                                  'RM ${expense.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                onTap: () {
                                  //navigate to edit expense form
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ExpenseFormScreen(expense: expense),
                                    ),
                                  );
                                },
                                leading: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  tooltip: 'Delete Expense',
                                  onPressed: () {
                                    expensesProvider.deleteExpense(expense.id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Expense deleted.')),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //add new expense
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ExpenseFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

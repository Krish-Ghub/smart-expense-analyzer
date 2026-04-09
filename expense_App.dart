import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'analytics_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}



class HomeScreen extends StatefulWidget {
  
  @override

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> expenses = [];
  Color getCategoryColor(String category) {
    switch (category) {
      case "Food":
        return Colors.red;
      case "Travel":
        return Colors.blue;
      case "Shopping":
        return Colors.purple;
      case "Gym":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

void initState() {
  super.initState();
  loadExpenses();
  debugPrintData(); // 👈 ADD THIS
}
void debugPrintData() async {
  final data = await DatabaseHelper.instance.getAllExpenses();
  print("ALL DATA: $data");
}


void loadExpenses() async {
  final data = await DatabaseHelper.instance.getExpenses();
  print("DATA FROM DB: $data"); // 👈 IMPORTANT
  setState(() {
    expenses = data;
  });
}
  double get total {
  return expenses.fold(0, (sum, item) {
    final value = item["amount"];
    if (value is int) return sum + value.toDouble();
    if (value is double) return sum + value;
    return sum;
  });
}

  void addExpense(Map<String, dynamic> expense) async {
  await DatabaseHelper.instance.insertExpense(expense);
  loadExpenses();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text("Expense Tracker"),
  actions: [
    IconButton(
      icon: Icon(Icons.bar_chart),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalyticsScreen(expenses: expenses),
          ),
        );
      },
    )
  ],
),
      
      body: Column(
        children: [
    // 🔷 Top Card (Total)
    Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Expense",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 8),
          Text(
            "₹$total",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),

    // 🔹 Expense List
    Expanded(
      child: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];

          return Dismissible(
        key: Key(expense["id"].toString()),
        direction: DismissDirection.endToStart,

        onDismissed: (direction) async {
          await DatabaseHelper.instance.deleteExpense(expense["id"]);
          loadExpenses();
        },

        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),

        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
  expense["category"],
  style: TextStyle(
    color: getCategoryColor(expense["category"]),
    fontWeight: FontWeight.bold,
  ),
),
              Text("₹${expense["amount"]}"),
                ],
              ),
            ),
          );
        },
      ),
    ),
  ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddExpenseScreen(),
            ),
          );

          if (result != null) {
            addExpense(result);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}


class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController amountController = TextEditingController();

  String selectedCategory = "Food";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Expense"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 16),

            // ✅ FIXED Dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              items: ["Food", "Travel", "Shopping", "Gym"]
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),

              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },

              decoration: InputDecoration(labelText: "Category"),
            ),

            SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                final expense = {
                  "amount": double.parse(amountController.text),
                  "category": selectedCategory,
                  "date": DateTime.now().toString().substring(0, 10),
                };

                Navigator.pop(context, expense);
              },
              child: Text("Save Expense"),
            )
          ],
        ),
      ),
    );
  }
}
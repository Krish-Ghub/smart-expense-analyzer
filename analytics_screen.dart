import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class AnalyticsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> expenses;

  AnalyticsScreen({required this.expenses});

  double getTotalByCategory(String category) {
    return expenses
        .where((e) => e["category"] == category)
        .fold(0, (sum, e) => sum + e["amount"]);
  }

  String getInsight() {
    if (expenses.isEmpty) return "No data";

    double total =
        expenses.fold(0, (sum, e) => sum + e["amount"]);

    double food = getTotalByCategory("Food");

    if (food > 0.4 * total) {
      return "⚠️ You spend too much on Food";
    }

    if (total > 2000) {
      return "⚠️ Your overall spending is high";
    }

    return "✅ Spending looks balanced";
  }

  @override
  Widget build(BuildContext context) {
    double food = getTotalByCategory("Food");
    double travel = getTotalByCategory("Travel");
    double gym = getTotalByCategory("Gym");

    return Scaffold(
      appBar: AppBar(title: Text("Analytics")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 🧠 Insight
            Text(
              getInsight(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // 📊 Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: food, color: Colors.red),
                    PieChartSectionData(value: travel, color: Colors.blue),
                    PieChartSectionData(value: gym, color: Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
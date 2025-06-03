import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalesDashboardScreen extends StatefulWidget {
  @override
  _SalesDashboardScreenState createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  String selectedFilter = "Month"; // Default filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Sales Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xffD9A441),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildFilterRow(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 20),
              _buildSalesLineChart(),
              const SizedBox(height: 20),
              _buildSalesBarChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: ["Week", "Month", "Year"]
          .map((filter) => ChoiceChip(
                label: Text(filter),
                selected: selectedFilter == filter,
                onSelected: (selected) {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
                selectedColor: const Color(0xffD9A441),
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: selectedFilter == filter ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _summaryCard("Total Revenue", "0", Icons.money),
        _summaryCard("Total Orders", "0", Icons.shopping_cart),
        _summaryCard("Best Seller", "Null", Icons.star),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xffD9A441), size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesLineChart() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(0, 10),
                const FlSpot(1, 20),
                const FlSpot(2, 40),
                const FlSpot(3, 30),
                const FlSpot(4, 50),
                const FlSpot(5, 80),
              ],
              isCurved: true,
              color: Color(0xffD9A441),
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesBarChart() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                  toY: 30, color: const Color(0xffD9A441), width: 12)
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(
                  toY: 50, color: const Color(0xffD9A441), width: 12)
            ]),
            BarChartGroupData(x: 3, barRods: [
              BarChartRodData(
                  toY: 80, color: const Color(0xffD9A441), width: 12)
            ]),
          ],
        ),
      ),
    );
  }
}

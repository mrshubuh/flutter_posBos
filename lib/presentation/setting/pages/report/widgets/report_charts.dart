import 'package:flutter/material.dart';
import 'package:flutter_pos/core/extensions/string_ext.dart';
import 'package:flutter_pos/data/models/response/product_sales_report.dart';
import 'package:flutter_pos/data/models/response/summary_response_model.dart';
import 'package:flutter_pos/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportCharts extends StatelessWidget {
  final List<ProductSales> productSales;
  final Summary summary;

  const ReportCharts({
    super.key,
    required this.productSales,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    // Prepare data for charts
    final topProducts = List<ProductSales>.from(productSales)
      ..sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));

    final top5Products = topProducts.take(5).toList();

    return Column(
      children: [
        // Sales Trend Chart (placeholder for daily/weekly/monthly data)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(
                    labelStyle: const TextStyle(fontSize: 10),
                  ),
                  primaryYAxis: NumericAxis(
                    numberFormat: NumberFormat.compact(),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries>[
                    LineSeries<Map<String, dynamic>, String>(
                      dataSource: _generateDummySalesData(),
                      xValueMapper: (data, _) => data['day'],
                      yValueMapper: (data, _) => data['sales'],
                      name: 'Sales',
                      color: AppColors.primary,
                      markerSettings: const MarkerSettings(isVisible: true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Top Products Chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Selling Products',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: SfCircularChart(
                  legend: const Legend(
                    isVisible: true,
                    position: LegendPosition.bottom,
                    overflowMode: LegendItemOverflowMode.wrap,
                  ),
                  series: <CircularSeries>[
                    DoughnutSeries<ProductSales, String>(
                      dataSource: top5Products,
                      xValueMapper: (ProductSales data, _) => data.productName,
                      yValueMapper: (ProductSales data, _) =>
                          data.totalQuantity.toIntegerFromText,
                      pointColorMapper: (ProductSales data, _) {
                        final index = top5Products.indexOf(data);
                        return _getColorForIndex(index);
                      },
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside,
                        textStyle: TextStyle(fontSize: 10),
                        labelIntersectAction: LabelIntersectAction.none,
                      ),
                      radius: '80%',
                      innerRadius: '60%',
                      dataLabelMapper: (ProductSales data, _) =>
                          '${data.productName} (${data.totalQuantity})',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Summary Cards
        _buildSummaryCards(),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Revenue',
            summary.totalRevenue.toString(),
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Items Sold',
            '${summary.totalSoldQuantity} items',
            Icons.shopping_cart,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to generate dummy data for the sales trend chart
  List<Map<String, dynamic>> _generateDummySalesData() {
    return [
      {'day': 'Mon', 'sales': 12},
      {'day': 'Tue', 'sales': 15},
      {'day': 'Wed', 'sales': 20},
      {'day': 'Thu', 'sales': 18},
      {'day': 'Fri', 'sales': 25},
      {'day': 'Sat', 'sales': 30},
      {'day': 'Sun', 'sales': 22},
    ];
  }

  // Helper function to get colors for the pie chart
  Color _getColorForIndex(int index) {
    final colors = [
      const Color(0xFF4285F4), // Blue
      const Color(0xFFEA4335), // Red
      const Color(0xFFFBBC05), // Yellow
      const Color(0xFF34A853), // Green
      const Color(0xFF673AB7), // Purple
    ];
    return colors[index % colors.length];
  }
}

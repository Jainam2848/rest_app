import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/analytics.dart';
import '../../../core/providers/restaurant_provider.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';

class RestaurantAnalyticsScreen extends ConsumerStatefulWidget {
  const RestaurantAnalyticsScreen({super.key});

  @override
  ConsumerState<RestaurantAnalyticsScreen> createState() => _RestaurantAnalyticsScreenState();
}

class _RestaurantAnalyticsScreenState extends ConsumerState<RestaurantAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Coupons'),
            Tab(text: 'Customers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildCouponsTab(),
          _buildCustomersTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final analyticsAsync = ref.watch(restaurantAnalyticsProvider);
    
    return analyticsAsync.when(
      data: (analytics) {
        if (analytics == null) {
          return _buildEmptyAnalytics();
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(restaurantAnalyticsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Key Metrics Cards
              _buildMetricsGrid(analytics),
              const SizedBox(height: 24),
              
              // Charts
              _buildChartsSection(analytics),
              const SizedBox(height: 24),
              
              // Recent Activity
              _buildRecentActivity(),
            ],
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorView(
        error: error.toString(),
        onRetry: () => ref.invalidate(restaurantAnalyticsProvider),
      ),
    );
  }

  Widget _buildMetricsGrid(RestaurantAnalytics analytics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Coupons',
                analytics.totalCoupons.toString(),
                Icons.local_offer,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Active Coupons',
                analytics.activeCoupons.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Views',
                analytics.totalViews.toString(),
                Icons.visibility,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Redemptions',
                analytics.totalRedemptions.toString(),
                Icons.redeem,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Unique Customers',
                analytics.uniqueCustomers.toString(),
                Icons.people,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Conversion Rate',
                '${(analytics.conversionRate ?? 0).toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(RestaurantAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Charts',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        
        // Conversion Rate Chart
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversion Rate Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildConversionChart(analytics),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Coupon Performance Chart
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coupon Performance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: _buildCouponPerformanceChart(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConversionChart(RestaurantAnalytics analytics) {
    // Mock data for demonstration
    final conversionRate = analytics.conversionRate ?? 0.0;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}%');
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return Text(days[value.toInt() % 7]);
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 2.5),
              const FlSpot(1, 3.2),
              const FlSpot(2, 2.8),
              const FlSpot(3, 4.1),
              const FlSpot(4, 3.9),
              const FlSpot(5, 4.5),
              FlSpot(6, conversionRate),
            ],
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponPerformanceChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const coupons = ['Pizza', 'Burger', 'Drink', 'Dessert'];
                return Text(coupons[value.toInt() % 4]);
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 45, color: Colors.blue)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 32, color: Colors.green)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 28, color: Colors.orange)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 38, color: Colors.purple)]),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          child: Column(
            children: [
              _buildActivityItem(
                'New coupon created',
                '20% Off Pizza',
                '2 hours ago',
                Icons.add_circle,
                Colors.green,
              ),
              const Divider(),
              _buildActivityItem(
                'Coupon redeemed',
                'Free Coffee',
                '4 hours ago',
                Icons.redeem,
                Colors.blue,
              ),
              const Divider(),
              _buildActivityItem(
                'Coupon viewed',
                'Burger Special',
                '6 hours ago',
                Icons.visibility,
                Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String action, String coupon, String time, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(action),
      subtitle: Text(coupon),
      trailing: Text(
        time,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
      ),
    );
  }

  Widget _buildCouponsTab() {
    final performanceAsync = ref.watch(couponPerformanceProvider);
    
    return performanceAsync.when(
      data: (performance) {
        if (performance.isEmpty) {
          return _buildEmptyCoupons();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: performance.length,
          itemBuilder: (context, index) {
            final coupon = performance[index];
            return CustomCard(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(coupon.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatChip(Icons.visibility, '${coupon.views}'),
                        const SizedBox(width: 8),
                        _buildStatChip(Icons.redeem, '${coupon.redemptions}'),
                        const SizedBox(width: 8),
                        _buildStatChip(Icons.favorite, '${coupon.favorites}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Conversion Rate: ${coupon.conversionRate.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                trailing: Text(
                  '${coupon.conversionRate.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: coupon.conversionRate > 5 ? Colors.green : Colors.orange,
                      ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorView(
        error: error.toString(),
        onRetry: () => ref.invalidate(couponPerformanceProvider),
      ),
    );
  }

  Widget _buildCustomersTab() {
    final insightsAsync = ref.watch(customerInsightsProvider);
    
    return insightsAsync.when(
      data: (insights) {
        if (insights.isEmpty) {
          return _buildEmptyCustomers();
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: insights.length,
          itemBuilder: (context, index) {
            final customer = insights[index];
            return CustomCard(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: customer.photoUrl != null 
                      ? NetworkImage(customer.photoUrl!) 
                      : null,
                  child: customer.photoUrl == null 
                      ? Text(customer.displayName[0].toUpperCase())
                      : null,
                ),
                title: Text(customer.displayName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('${customer.totalRedemptions} redemptions'),
                    Text('${customer.totalFavorites} favorites'),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${customer.totalRedemptions}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    Text(
                      'redemptions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorView(
        error: error.toString(),
        onRetry: () => ref.invalidate(customerInsightsProvider),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAnalytics() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No analytics data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analytics will appear once you have active coupons and customer engagement',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCoupons() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No coupon performance data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create coupons to see performance analytics',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCustomers() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No customer insights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customer insights will appear once customers start redeeming your coupons',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

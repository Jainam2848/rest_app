import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/restaurant_provider.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import 'create_coupon_screen.dart';
import 'manage_coupons_screen.dart';
import 'analytics_screen.dart';
import 'qr_code_screen.dart';

class RestaurantHomeScreen extends ConsumerStatefulWidget {
  const RestaurantHomeScreen({super.key});

  @override
  ConsumerState<RestaurantHomeScreen> createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends ConsumerState<RestaurantHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const RestaurantDashboardPage(),
    const ManageCouponsScreen(),
    const RestaurantAnalyticsScreen(),
    const RestaurantProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer),
            label: 'Coupons',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Dashboard Page
class RestaurantDashboardPage extends ConsumerWidget {
  const RestaurantDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final analyticsAsync = ref.watch(restaurantAnalyticsProvider);
    final couponsAsync = ref.watch(restaurantCouponsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/restaurant/qr-scanner'),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Section
            Text(
              'Welcome, ${user?.displayName ?? 'Restaurant'}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your coupons and track performance',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            analyticsAsync.when(
              data: (analytics) => _buildStatsGrid(analytics),
              loading: () => const LoadingIndicator(),
              error: (error, stack) => ErrorView(
                error: error.toString(),
                onRetry: () => ref.invalidate(restaurantAnalyticsProvider),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_circle, color: Colors.blue),
                    title: const Text('Create New Coupon'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/restaurant/create-coupon'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.orange),
                    title: const Text('Manage Coupons'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/restaurant/manage-coupons'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner, color: Colors.green),
                    title: const Text('Scan QR Code'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/restaurant/qr-scanner'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.analytics, color: Colors.purple),
                    title: const Text('View Analytics'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/restaurant/analytics'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Coupons
            Text(
              'Recent Coupons',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            couponsAsync.when(
              data: (coupons) => _buildRecentCoupons(coupons),
              loading: () => const LoadingIndicator(),
              error: (error, stack) => ErrorView(
                error: error.toString(),
                onRetry: () => ref.invalidate(restaurantCouponsProvider),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStatsGrid(dynamic analytics) {
    if (analytics == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_offer,
                title: 'Total Coupons',
                value: analytics.totalCoupons.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle,
                title: 'Active',
                value: analytics.activeCoupons.toString(),
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.visibility,
                title: 'Views',
                value: analytics.totalViews.toString(),
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.redeem,
                title: 'Redemptions',
                value: analytics.totalRedemptions.toString(),
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentCoupons(List<dynamic> coupons) {
    if (coupons.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No coupons yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first coupon to start attracting customers',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push('/restaurant/create-coupon'),
                icon: const Icon(Icons.add),
                label: const Text('Create Coupon'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: coupons.take(3).map((coupon) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: coupon.isActive ? Colors.green : Colors.grey,
              child: Icon(
                Icons.local_offer,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(coupon.title),
            subtitle: Text(coupon.discountDisplayText),
            trailing: Text(
              coupon.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: coupon.isActive ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => context.push('/restaurant/manage-coupons'),
          );
        }).toList(),
      ),
    );
  }
}

// Profile Page
class RestaurantProfilePage extends StatelessWidget {
  const RestaurantProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Restaurant Details'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Business Information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notification Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// Helper Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

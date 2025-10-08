import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/coupon.dart';
import '../../../core/providers/restaurant_provider.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/utils/format_utils.dart';

class ManageCouponsScreen extends ConsumerStatefulWidget {
  const ManageCouponsScreen({super.key});

  @override
  ConsumerState<ManageCouponsScreen> createState() => _ManageCouponsScreenState();
}

class _ManageCouponsScreenState extends ConsumerState<ManageCouponsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Manage Coupons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/restaurant/create-coupon'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Draft'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search coupons...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    DropdownMenuItem(value: 'expired', child: Text('Expired')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Coupons List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCouponsList('all'),
                _buildCouponsList('active'),
                _buildCouponsList('draft'),
                _buildCouponsList('expired'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponsList(String status) {
    final couponsAsync = ref.watch(restaurantCouponsProvider);
    
    return couponsAsync.when(
      data: (coupons) {
        // Filter coupons based on status and search query
        var filteredCoupons = coupons.where((coupon) {
          final matchesStatus = status == 'all' || 
              (status == 'active' && coupon.isActive) ||
              (status == 'draft' && coupon.status == 'draft') ||
              (status == 'expired' && coupon.isExpired);
          
          final matchesSearch = _searchQuery.isEmpty ||
              coupon.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              coupon.description.toLowerCase().contains(_searchQuery.toLowerCase());
          
          return matchesStatus && matchesSearch;
        }).toList();

        if (filteredCoupons.isEmpty) {
          return _buildEmptyState(status);
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(restaurantCouponsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredCoupons.length,
            itemBuilder: (context, index) {
              final coupon = filteredCoupons[index];
              return _buildCouponCard(coupon);
            },
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (error, stack) => ErrorView(
        error: error.toString(),
        onRetry: () => ref.invalidate(restaurantCouponsProvider),
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      coupon.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildStatusChip(coupon),
            ],
          ),
          const SizedBox(height: 12),
          
          // Discount Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  coupon.discountDisplayText,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (coupon.code != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    coupon.code!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Stats
          Row(
            children: [
              _buildStatItem(Icons.visibility, '${coupon.usageCount ?? 0}'),
              const SizedBox(width: 16),
              _buildStatItem(Icons.redeem, '${coupon.usageCount ?? 0}'),
              const SizedBox(width: 16),
              _buildStatItem(Icons.favorite, '0'),
            ],
          ),
          const SizedBox(height: 12),
          
          // Validity
          Text(
            coupon.validityText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: coupon.isExpired ? Colors.red : Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/restaurant/create-coupon', extra: coupon),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _toggleCouponStatus(coupon),
                  icon: Icon(
                    coupon.isActive ? Icons.pause : Icons.play_arrow,
                    size: 16,
                  ),
                  label: Text(coupon.isActive ? 'Pause' : 'Activate'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showDeleteDialog(coupon),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(Coupon coupon) {
    Color color;
    String text;
    
    if (coupon.isExpired) {
      color = Colors.red;
      text = 'Expired';
    } else if (!coupon.isActive) {
      color = Colors.orange;
      text = 'Paused';
    } else if (coupon.status == 'draft') {
      color = Colors.grey;
      text = 'Draft';
    } else {
      color = Colors.green;
      text = 'Active';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String status) {
    String message;
    IconData icon;
    
    switch (status) {
      case 'active':
        message = 'No active coupons';
        icon = Icons.local_offer_outlined;
        break;
      case 'draft':
        message = 'No draft coupons';
        icon = Icons.edit_outlined;
        break;
      case 'expired':
        message = 'No expired coupons';
        icon = Icons.schedule_outlined;
        break;
      default:
        message = 'No coupons found';
        icon = Icons.local_offer_outlined;
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first coupon to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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

  Future<void> _toggleCouponStatus(Coupon coupon) async {
    try {
      final couponService = ref.read(couponServiceProvider);
      await couponService.toggleCouponStatus(coupon.id, !coupon.isActive);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              coupon.isActive 
                  ? 'Coupon paused successfully' 
                  : 'Coupon activated successfully',
            ),
          ),
        );
        ref.invalidate(restaurantCouponsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(Coupon coupon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Coupon'),
        content: Text('Are you sure you want to delete "${coupon.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final couponService = ref.read(couponServiceProvider);
        await couponService.deleteCoupon(coupon.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coupon deleted successfully')),
          );
          ref.invalidate(restaurantCouponsProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

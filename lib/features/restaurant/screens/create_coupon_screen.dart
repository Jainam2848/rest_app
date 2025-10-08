import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/coupon.dart';
import '../../../core/providers/restaurant_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/utils/validators.dart';

class CreateCouponScreen extends ConsumerStatefulWidget {
  final Coupon? coupon; // For editing existing coupon

  const CreateCouponScreen({super.key, this.coupon});

  @override
  ConsumerState<CreateCouponScreen> createState() => _CreateCouponScreenState();
}

class _CreateCouponScreenState extends ConsumerState<CreateCouponScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _codeController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minPurchaseController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _usageLimitController = TextEditingController();
  final _perUserLimitController = TextEditingController();

  String _discountType = 'percentage';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  List<String> _selectedCategories = [];
  List<String> _imageUrls = [];
  bool _isFeatured = false;
  bool _isActive = true;

  final List<String> _availableCategories = [
    'Food',
    'Drinks',
    'Desserts',
    'Appetizers',
    'Main Course',
    'Beverages',
    'Specials',
    'Happy Hour',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.coupon != null) {
      _populateForm(widget.coupon!);
    }
  }

  void _populateForm(Coupon coupon) {
    _titleController.text = coupon.title;
    _descriptionController.text = coupon.description;
    _codeController.text = coupon.code ?? '';
    _discountValueController.text = coupon.discountValue?.toString() ?? '';
    _minPurchaseController.text = coupon.minPurchase?.toString() ?? '';
    _maxDiscountController.text = coupon.maxDiscount?.toString() ?? '';
    _usageLimitController.text = coupon.usageLimit?.toString() ?? '';
    _perUserLimitController.text = coupon.perUserLimit?.toString() ?? '';
    
    _discountType = coupon.discountType;
    _startDate = coupon.startDate;
    _endDate = coupon.endDate;
    _selectedCategories = List.from(coupon.categories);
    _imageUrls = List.from(coupon.imageUrls ?? []);
    _isFeatured = coupon.isFeatured;
    _isActive = coupon.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _codeController.dispose();
    _discountValueController.dispose();
    _minPurchaseController.dispose();
    _maxDiscountController.dispose();
    _usageLimitController.dispose();
    _perUserLimitController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      // TODO: Upload images to Supabase storage
      setState(() {
        _imageUrls.addAll(images.map((image) => image.path));
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveCoupon() async {
    if (!_formKey.currentState!.validate()) return;

    final userAsync = ref.read(currentUserProvider);
    final restaurantAsync = ref.read(currentRestaurantProvider);
    
    if (userAsync.value == null || restaurantAsync.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User or restaurant not found')),
      );
      return;
    }

    final coupon = Coupon(
      id: widget.coupon?.id ?? '',
      restaurantId: restaurantAsync.value!.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      code: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
      discountType: _discountType,
      discountValue: _discountValueController.text.isEmpty 
          ? null 
          : double.tryParse(_discountValueController.text),
      minPurchase: _minPurchaseController.text.isEmpty 
          ? null 
          : double.tryParse(_minPurchaseController.text),
      maxDiscount: _maxDiscountController.text.isEmpty 
          ? null 
          : double.tryParse(_maxDiscountController.text),
      imageUrls: _imageUrls.isEmpty ? null : _imageUrls,
      startDate: _startDate,
      endDate: _endDate,
      usageLimit: _usageLimitController.text.isEmpty 
          ? null 
          : int.tryParse(_usageLimitController.text),
      perUserLimit: _perUserLimitController.text.isEmpty 
          ? null 
          : int.tryParse(_perUserLimitController.text),
      categories: _selectedCategories,
      status: 'active',
      isActive: _isActive,
      isFeatured: _isFeatured,
      createdAt: widget.coupon?.createdAt ?? DateTime.now(),
    );

    if (widget.coupon != null) {
      await ref.read(couponCreationProvider.notifier).updateCoupon(coupon);
    } else {
      await ref.read(couponCreationProvider.notifier).createCoupon(coupon);
    }

    if (mounted) {
      final state = ref.read(couponCreationProvider);
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.coupon != null 
                ? 'Coupon updated successfully!' 
                : 'Coupon created successfully!'),
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(couponCreationProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coupon != null ? 'Edit Coupon' : 'Create Coupon'),
        actions: [
          if (creationState.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _titleController,
              label: 'Coupon Title',
              hint: 'e.g., 20% Off Pizza',
              validator: Validators.required,
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Describe your coupon offer',
              maxLines: 3,
              validator: Validators.required,
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _codeController,
              label: 'Coupon Code (Optional)',
              hint: 'e.g., PIZZA20',
            ),
            const SizedBox(height: 24),

            // Discount Information
            _buildSectionTitle('Discount Information'),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _discountType,
              decoration: const InputDecoration(
                labelText: 'Discount Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                DropdownMenuItem(value: 'fixed_amount', child: Text('Fixed Amount')),
                DropdownMenuItem(value: 'buy_one_get_one', child: Text('Buy One Get One')),
              ],
              onChanged: (value) {
                setState(() {
                  _discountType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            if (_discountType != 'buy_one_get_one')
              CustomTextField(
                controller: _discountValueController,
                label: _discountType == 'percentage' ? 'Discount Percentage' : 'Discount Amount',
                hint: _discountType == 'percentage' ? '20' : '5.00',
                keyboardType: TextInputType.number,
                validator: Validators.required,
              ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _minPurchaseController,
              label: 'Minimum Purchase (Optional)',
              hint: '10.00',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            if (_discountType == 'percentage')
              CustomTextField(
                controller: _maxDiscountController,
                label: 'Maximum Discount (Optional)',
                hint: '25.00',
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 24),

            // Validity Period
            _buildSectionTitle('Validity Period'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_startDate.toString().split(' ')[0]),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_endDate.toString().split(' ')[0]),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Usage Limits
            _buildSectionTitle('Usage Limits'),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _usageLimitController,
              label: 'Total Usage Limit (Optional)',
              hint: '100',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _perUserLimitController,
              label: 'Per User Limit (Optional)',
              hint: '1',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Categories
            _buildSectionTitle('Categories'),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableCategories.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Images
            _buildSectionTitle('Images'),
            const SizedBox(height: 16),
            
            if (_imageUrls.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _imageUrls[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Images'),
            ),
            const SizedBox(height: 24),

            // Settings
            _buildSectionTitle('Settings'),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Featured Coupon'),
              subtitle: const Text('Show in featured section'),
              value: _isFeatured,
              onChanged: (value) {
                setState(() {
                  _isFeatured = value;
                });
              },
            ),
            
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Coupon is currently active'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 32),

            // Save Button
            CustomButton(
              text: widget.coupon != null ? 'Update Coupon' : 'Create Coupon',
              onPressed: creationState.isLoading ? null : _saveCoupon,
              isLoading: creationState.isLoading,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

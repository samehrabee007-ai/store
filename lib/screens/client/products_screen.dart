import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../../services/database_service.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<Product> allProducts = [];
  List<Product> displayedProducts = [];
  TextEditingController searchController = TextEditingController();

  // Filter State
  RangeValues _currentPriceRange = RangeValues(0, 10000);
  String? _selectedCategory;
  String _sortOrder = 'newest'; // newest, priceAsc, priceDesc

  @override
  void initState() {
    super.initState();
  }

  void _applyFilters() {
    List<Product> temp = List.from(allProducts);

    // Search
    if (searchController.text.isNotEmpty) {
      temp = temp
          .where(
            (p) => p.name.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    // Category
    if (_selectedCategory != null) {
      temp = temp.where((p) => p.category == _selectedCategory).toList();
    }

    // Price Range
    temp = temp
        .where(
          (p) =>
              p.price >= _currentPriceRange.start &&
              p.price <= _currentPriceRange.end,
        )
        .toList();

    // Sorting
    if (_sortOrder == 'priceAsc') {
      temp.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOrder == 'priceDesc') {
      temp.sort((a, b) => b.price.compareTo(a.price));
    }
    // 'newest' is default (as coming from stream usually, or we can add date field logic later)

    setState(() {
      displayedProducts = temp;
    });
  }

  void _showFilterSheet() {
    // Extract Categories
    final categories = allProducts.map((e) => e.category).toSet().toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تصفية المنتجات',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Divider(),

                  Text('القسم', style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: categories.map((cat) {
                      return ChoiceChip(
                        label: Text(cat.isEmpty ? 'غير مصنف' : cat),
                        selected: _selectedCategory == cat,
                        onSelected: (selected) {
                          setSheetState(() {
                            _selectedCategory = selected ? cat : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),

                  Text(
                    'نطاق السعر: ${_currentPriceRange.start.round()} - ${_currentPriceRange.end.round()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RangeSlider(
                    values: _currentPriceRange,
                    min: 0,
                    max: 20000,
                    divisions: 100,
                    labels: RangeLabels(
                      _currentPriceRange.start.round().toString(),
                      _currentPriceRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setSheetState(() {
                        _currentPriceRange = values;
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  Text(
                    'الترتيب',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: _sortOrder,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(value: 'newest', child: Text('الأحدث')),
                      DropdownMenuItem(
                        value: 'priceAsc',
                        child: Text('الأقل سعراً'),
                      ),
                      DropdownMenuItem(
                        value: 'priceDesc',
                        child: Text('الأعلى سعراً'),
                      ),
                    ],
                    onChanged: (val) {
                      setSheetState(() => _sortOrder = val!);
                    },
                  ),
                  SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyFilters();
                      },
                      child: Text('تطبيق'),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/images/logo.png', height: 40),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'بحث عن منتج...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onChanged: (val) {
                _applyFilters();
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: DatabaseService().products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('لا يوجد منتجات'));
                }

                // Initialize list only once or when data changes heavily if needed
                // But simplified: Update allProducts and apply filters fresh
                if (allProducts.isEmpty ||
                    allProducts.length != snapshot.data!.length) {
                  allProducts = snapshot.data!;
                  // Apply filters initially to populate displayedProducts
                  // We defer this slightly to build frames but here it's fine for simple lists
                  // Ideally we shouldn't modify state during build, but for this StreamBuilder pattern:
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (displayedProducts.isEmpty) _applyFilters();
                  });
                }

                // If we are filtering, we use displayedProducts
                // Fallback to allProducts if displayed is empty BUT only if no filter is active?
                // No, displayedProducts should be authoritative content.
                // However, initial load issue: displayedProducts starts empty.
                // Quick fix:
                final productsToShow =
                    displayedProducts.isEmpty &&
                        searchController.text.isEmpty &&
                        _selectedCategory == null
                    ? snapshot.data!
                    : displayedProducts;

                if (productsToShow.isEmpty &&
                    (searchController.text.isNotEmpty ||
                        _selectedCategory != null)) {
                  return Center(child: Text('لا توجد نتائج مطابقة'));
                }

                return GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: productsToShow.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: productsToShow[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

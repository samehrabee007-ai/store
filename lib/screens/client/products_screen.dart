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
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', height: 40),
        centerTitle: true,
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
                setState(() {}); // Just rebuild to filter
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

                allProducts = snapshot.data!;

                List<Product> displayed = allProducts;
                if (searchController.text.isNotEmpty) {
                  displayed = allProducts
                      .where(
                        (p) => p.name.toLowerCase().contains(
                          searchController.text.toLowerCase(),
                        ),
                      )
                      .toList();
                }

                return GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: displayed.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: displayed[index]);
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

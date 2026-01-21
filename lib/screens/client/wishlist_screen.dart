import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('المفضلة')),
        body: Center(child: Text('يرجى تسجيل الدخول')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('المفضلة')),
      body: StreamBuilder<List<String>>(
        stream: DatabaseService().getWishlist(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد عناصر في المفضلة'));
          }

          final wishlistIds = snapshot.data!;

          return StreamBuilder<List<Product>>(
            stream: DatabaseService().products,
            builder: (context, productSnapshot) {
              if (!productSnapshot.hasData) return SizedBox();

              final allProducts = productSnapshot.data!;
              final wishlistProducts = allProducts
                  .where((p) => wishlistIds.contains(p.id))
                  .toList();

              if (wishlistProducts.isEmpty) {
                return Center(
                  child: Text('المنتجات في المفضلة غير متاحة حالياً'),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: wishlistProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: wishlistProducts[index]);
                },
              );
            },
          );
        },
      ),
    );
  }
}

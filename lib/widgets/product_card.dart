import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../screens/client/product_details_screen.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Stack(
                  children: [
                    product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image),
                          )
                        : Container(
                            color: Colors.grey[200],
                            width: double.infinity,
                            height: double.infinity,
                            child: Icon(Icons.image, size: 50),
                          ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: StreamBuilder<List<String>>(
                        stream: DatabaseService().getWishlist(
                          AuthService().currentUser?.uid ?? '',
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return SizedBox();
                          final isFav = snapshot.data!.contains(product.id);
                          return CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 15,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () {
                                final user = AuthService().currentUser;
                                if (user != null) {
                                  DatabaseService().toggleWishlist(
                                    user.uid,
                                    product.id,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('يرجى تسجيل الدخول'),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${product.price} ج.م',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

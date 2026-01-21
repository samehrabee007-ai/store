import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/cart_model.dart';
import '../../models/review_model.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({Key? key, required this.product})
    : super(key: key);

  Future<void> _launchWhatsApp() async {
    final String phone =
        "+201000000000"; // TODO: Replace with user's phone number
    final String message = "مرحبا، أريد الاستفسار عن المنتج: ${product.name}";
    final Uri url = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.white,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image, size: 100),
                    )
                  : Icon(Icons.image, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${product.price} ج.م',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'الوصف:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(product.description, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchWhatsApp,
                      icon: Icon(Icons.chat),
                      label: Text('طلب عبر واتساب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final user = AuthService().currentUser;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'يرجى تسجيل الدخول لإضافة للمنتجات للسلة',
                              ),
                              action: SnackBarAction(
                                label: 'دخول',
                                onPressed: () {
                                  Navigator.pushNamed(context, '/client-login');
                                },
                              ),
                            ),
                          );
                          return;
                        }

                        // Add to cart
                        await DatabaseService().addToCart(
                          user.uid,
                          CartItem(
                            productId: product.id,
                            productName: product.name,
                            price: product.price,
                            imageUrl: product.imageUrl,
                            quantity: 1,
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تمت الإضافة للسلة'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: Icon(Icons.add_shopping_cart),
                      label: Text('أضف للسلة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(thickness: 2),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المراجعات',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  StreamBuilder<List<Review>>(
                    stream: DatabaseService().getReviews(product.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Column(
                          children: [
                            Text('لا تتوفر مراجعات بعد لهذا المنتج'),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => _showAddReviewDialog(context),
                              child: Text('كن أول من يقيم'),
                            ),
                          ],
                        );
                      }

                      final reviews = snapshot.data!;
                      // Calculate averages visually here or rely on stored updated stats
                      // Simple list display:
                      return Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: reviews.length,
                            itemBuilder: (context, index) {
                              final rev = reviews[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(rev.userName[0].toUpperCase()),
                                ),
                                title: Text(rev.userName),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < rev.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    Text(rev.comment),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _showAddReviewDialog(context),
                            child: Text('أضف تقييمك'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context) {
    final _commentController = TextEditingController();
    double _rating = 5.0;

    final user = AuthService().currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('يجب تسجيل الدخول لإضافة تقييم')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('إضافة تقييم'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 30,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            _rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'تعليقك',
                      hintText: 'اكتب رأيك هنا...',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_commentController.text.isNotEmpty) {
                      Navigator.pop(context);
                      // Fetch user name fresh or use placeholder needed
                      Map<String, dynamic>? userData = await DatabaseService()
                          .getUserData(user.uid);
                      String userName = userData?['name'] ?? 'مستخدم';

                      final review = Review(
                        id: '', // Generated by Firestore doesn't matter for add, or we rely on .add()
                        userId: user.uid,
                        userName: userName,
                        rating: _rating,
                        comment: _commentController.text,
                        createdAt: DateTime.now(),
                      );

                      await DatabaseService().addReview(product.id, review);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('تم نشر تقييمك')));
                    }
                  },
                  child: Text('نشر'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

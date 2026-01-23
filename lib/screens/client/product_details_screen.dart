import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/product_model.dart'; // تأكد من صحة المسار
import '../../services/database_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // عرض صورة المنتج
            Image.network(
              widget.product.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 100),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.product.price} ج.م',
                    style: const TextStyle(fontSize: 20, color: Colors.blue),
                  ),
                  const Divider(),
                  const Text(
                    'التقييمات والمراجعات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  
                  // إصلاح استدعاء getReviews (الذي سبب خطأ البناء)
                  StreamBuilder(
                    stream: DatabaseService().getReviews(widget.product.id),
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      
                      if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Text('لا توجد تقييمات لهذا المنتج بعد.'),
                        );
                      }

                      Map<dynamic, dynamic> reviews = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          var review = reviews.values.elementAt(index);
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(review['comment'] ?? ''),
                            subtitle: Text('التقييم: ${review['rating']}'),
                          );
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // حقل إضافة تقييم جديد
                  TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      labelText: 'أضف تعليقك...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_reviewController.text.isNotEmpty) {
                        // إصلاح استدعاء addReview (الذي سبب خطأ البناء)
                        await DatabaseService().addReview(widget.product.id, {
                          'comment': _reviewController.text,
                          'rating': 5, // افتراضي مؤقتاً
                          'date': DateTime.now().toIso8601String(),
                        });
                        _reviewController.clear();
                      }
                    },
                    child: const Text('إرسال التقييم'),
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

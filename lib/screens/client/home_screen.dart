import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart'; // إضافة مكتبة Firebase
import '../../widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  final List<String> imgList = [
    'https://via.placeholder.com/800x400?text=Offer+1',
    'https://via.placeholder.com/800x400?text=Offer+2',
    'https://via.placeholder.com/800x400?text=Offer+3',
  ];

  final List<Map<String, dynamic>> categories = [
    {'name': 'أجهزة', 'icon': Icons.device_hub},
    {'name': 'محاليل', 'icon': Icons.science},
    {'name': 'مستلزمات', 'icon': Icons.medical_services},
    {'name': 'أخرى', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    // مرجع قاعدة بيانات Firebase - مسار المنتجات
    final DatabaseReference _productsRef =
        FirebaseDatabase.instance.ref().child('products');

    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/images/logo.png', height: 40,
              errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.business,
                color: Colors.blue); // بديل في حال فقدان الصورة
          }),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // 1. قسم الصور المتحركة (Slider)
            CarouselSlider(
              options: CarouselOptions(
                height: 180.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.85,
              ),
              items: imgList
                  .map((item) => Container(
                        margin: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          image: DecorationImage(
                              image: NetworkImage(item), fit: BoxFit.cover),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 20),

            // 2. قسم الفئات (Categories)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('الفئات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: Icon(categories[index]['icon'],
                              size: 28, color: Colors.blue),
                        ),
                        const SizedBox(height: 5),
                        Text(categories[index]['name'],
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 3. قسم أحدث المنتجات (جلب البيانات من Firebase)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('أحدث المنتجات',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/products'),
                    child: const Text('عرض الكل'),
                  ),
                ],
              ),
            ),

            // عرض المنتجات باستخدام StreamBuilder لضمان التحديث اللحظي
            SizedBox(
              height: 260,
              child: StreamBuilder(
                stream:
                    _productsRef.limitToLast(10).onValue, // جلب آخر 10 منتجات
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Center(
                        child: Text('لا توجد منتجات متاحة حالياً'));
                  }

                  Map<dynamic, dynamic> values =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<dynamic> productList = values.values.toList();

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      var product = productList[index];
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 5)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15)),
                                  image: const DecorationImage(
                                    image: AssetImage(
                                        'assets/images/placeholder.png'), // صورة افتراضية
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product['name'] ?? 'منتج جديد',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('${product['price'] ?? '0'} ج.م',
                                      style:
                                          const TextStyle(color: Colors.blue)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

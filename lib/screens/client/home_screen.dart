import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/logo.png', height: 40),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            // Slider
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
              items: imgList
                  .map(
                    (item) => Container(
                      margin: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        image: DecorationImage(
                          image: NetworkImage(item),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            SizedBox(height: 20),

            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'الفئات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 100,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Icon(
                            categories[index]['icon'],
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(categories[index]['name']),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // Latest Products
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'أحدث المنتجات',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/products');
                    },
                    child: Text('عرض الكل'),
                  ),
                ],
              ),
            ),

            Container(
              height: 200,
              alignment: Alignment.center,
              child: Text('قائمة المنتجات ستظهر هنا'),
            ),
          ],
        ),
      ),
    );
  }
}

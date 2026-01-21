import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import 'add_edit_product_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة التحكم - المنتجات'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-company-info');
            },
            tooltip: 'تعديل بيانات الشركة',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: DatabaseService().products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          
          if (products.isEmpty) {
            return Center(child: Text('لا يوجد منتجات حالياً'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: product.imageUrl.isNotEmpty ? NetworkImage(product.imageUrl) : null,
                    child: product.imageUrl.isEmpty ? Icon(Icons.shopping_bag) : null,
                    backgroundColor: Colors.grey[200],
                  ),
                  title: Text(product.name),
                  subtitle: Text('${product.price} ج.م'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AddEditProductScreen(product: product)),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                           await DatabaseService().deleteProduct(product.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditProductScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'إضافة منتج',
      ),
    );
  }
}

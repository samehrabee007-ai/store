import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset('assets/images/logo.png', height: 80),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('الرئيسية'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('من نحن'),
            onTap: () {
              Navigator.of(context).pushNamed('/about');
            },
          ),
          ListTile(
            leading: Icon(Icons.person_add),
            title: Text('تسجيل دخول / جديد'),
            onTap: () {
              Navigator.of(context).pushNamed('/client-login');
            },
          ),
          ListTile(
            leading: Icon(Icons.admin_panel_settings),
            title: Text('لوحة التحكم'),
            onTap: () {
              Navigator.of(context).pushNamed('/admin-login');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('سلة الشراء'),
            onTap: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('المفضلة'),
            onTap: () {
              Navigator.of(context).pushNamed('/wishlist');
            },
          ),
          ListTile(
            leading: Icon(Icons.list_alt),
            title: Text('طلباتي'),
            onTap: () {
              Navigator.of(context).pushNamed('/orders');
            },
          ),
        ],
      ),
    );
  }
}

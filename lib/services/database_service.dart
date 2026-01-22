import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/review_model.dart';

class DatabaseService {
  // 1. رابط قاعدة البيانات الخاص بسيرفر سنغافورة
  final String _databaseURL = 'https://betalab-beta-lab-store-default-rtdb.asia-southeast1.firebasedatabase.app/';

  // 2. المرجع الأساسي لقاعدة البيانات
  DatabaseReference _getRef() {
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: _databaseURL,
    ).ref();
  }

  // --- إدارة المنتجات (Products) ---
  
  Stream<List<Product>> get products {
    return _getRef().child('products').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((entry) {
        return Product.fromMap(Map<String, dynamic>.from(entry.value), entry.key);
      }).toList();
    });
  }

  Future<void> addProduct(Product product) async {
    await _getRef().child('products').push().set(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _getRef().child('products').child(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _getRef().child('products').child(id).remove();
  }

  // --- إدارة الطلبات (Orders) ---

  Future<void> placeOrder(OrderModel order) async {
    await _getRef().child('orders').push().set(order.toMap());
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _getRef().child('orders').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries
          .map((entry) => OrderModel.fromMap(Map<String, dynamic>.from(entry.value), entry.key))
          .where((order) => order.userId == userId)
          .toList();
    });
  }

  // --- عربة التسوق (Cart) ---

  // تم إضافة هذه الدالة لإصلاح خطأ cart_screen.dart
  Future<void> updateCartItemQuantity(String uid, String productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(uid, productId);
    } else {
      await _getRef().child('users').child(uid).child('cart').child(productId).update({
        'quantity': quantity,
      });
    }
  }

  Future<void> addToCart(String uid, CartItem item) async {
    final cartRef = _getRef().child('users').child(uid).child('cart').child(item.productId);
    final snapshot = await cartRef.get();
    if (snapshot.exists) {
      int currentQty = (snapshot.value as Map)['quantity'] ?? 0;
      await cartRef.update({'quantity': currentQty + item.quantity});
    } else {
      await cartRef.set(item.toMap());
    }
  }

  Future<void> removeFromCart(String uid, String productId) async {
    await _getRef().child('users').child(uid).child('cart').child(productId).remove();
  }

  Stream<List<CartItem>> getCart(String uid) {
    return _getRef().child('users').child(uid).child('cart').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.values.map((v) => CartItem.fromMap(Map<String, dynamic>.from(v))).toList();
    });
  }

  // --- إدارة العناوين (Addresses) ---

  Future<void> addAddress(String uid, String address) async {
    await _getRef().child('users').child(uid).child('addresses').push().set(address);
  }

  // تم إضافة هذه الدالة لإصلاح خطأ profile_screen.dart
  Future<void> removeAddress(String uid, String address) async {
    final ref = _getRef().child('users').child(uid).child('addresses');
    final snapshot = await ref.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (value == address) {
          ref.child(key).remove();
        }
      });
    }
  }

  Stream<List<String>> getUserAddresses(String uid) {
    return _getRef().child('users').child(uid).child('addresses').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.values.map((v) => v.toString()).toList();
    });
  }

  // --- وظائف إضافية للملف ---

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _getRef().child('users').child(uid).update(data);
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final snapshot = await _getRef().child('users').child(uid).get();
    if (snapshot.exists) return Map<String, dynamic>.from(snapshot.value as Map);
    return null;
  }

  Stream<DatabaseEvent> get companyInfoStream {
    return _getRef().child('settings/company_info').onValue;
  }

  Future<void> updateCompanyInfo(Map<String, dynamic> data) async {
    await _getRef().child('settings/company_info').update(data);
  }
}

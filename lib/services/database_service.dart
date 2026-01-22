import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/review_model.dart';

class DatabaseService {
  // 1. رابط قاعدة البيانات الخاص بسيرفر سنغافورة كما ظهر في إعداداتك
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

  // --- إعدادات بيانات الشركة (Company Info) ---

  Stream<DatabaseEvent> get companyInfoStream {
    return _getRef().child('settings/company_info').onValue;
  }

  Future<void> updateCompanyInfo(Map<String, dynamic> data) async {
    await _getRef().child('settings/company_info').update(data);
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

  Stream<List<OrderModel>> get allOrders {
    return _getRef().child('orders').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries
          .map((entry) => OrderModel.fromMap(Map<String, dynamic>.from(entry.value), entry.key))
          .toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _getRef().child('orders').child(orderId).update({
      'status': status.toString().split('.').last,
    });
  }

  // --- عربة التسوق (Cart) ---

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

  Future<void> clearCart(String uid) async {
    await _getRef().child('users').child(uid).child('cart').remove();
  }

  // --- إدارة بيانات المستخدم (User Data & Addresses) ---

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final snapshot = await _getRef().child('users').child(uid).get();
    if (snapshot.exists) return Map<String, dynamic>.from(snapshot.value as Map);
    return null;
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _getRef().child('users').child(uid).update(data);
  }

  Future<void> addAddress(String uid, String address) async {
    final ref = _getRef().child('users').child(uid).child('addresses');
    await ref.push().set(address);
  }

  Stream<List<String>> getUserAddresses(String uid) {
    return _getRef().child('users').child(uid).child('addresses').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.values.map((v) => v.toString()).toList();
    });
  }

  // --- المفضلة (Wishlist) ---

  Future<void> toggleWishlist(String uid, String productId) async {
    final ref = _getRef().child('users').child(uid).child('wishlist').child(productId);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      await ref.remove();
    } else {
      await ref.set({
        'productId': productId,
        'addedAt': ServerValue.timestamp,
      });
    }
  }

  Stream<List<String>> getWishlist(String uid) {
    return _getRef().child('users').child(uid).child('wishlist').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.keys.map((k) => k.toString()).toList();
    });
  }

  // --- المراجعات (Reviews) ---

  Future<void> addReview(String productId, Review review) async {
    await _getRef().child('products').child(productId).child('reviews').push().set(review.toMap());
  }

  Stream<List<Review>> getReviews(String productId) {
    return _getRef().child('products').child(productId).child('reviews').onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((entry) {
        return Review.fromMap(Map<String, dynamic>.from(entry.value), entry.key);
      }).toList();
    });
  }
}

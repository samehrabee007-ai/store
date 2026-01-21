import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../models/review_model.dart';

class DatabaseService {
  final CollectionReference _productsCollection = FirebaseFirestore.instance
      .collection('products');

  // Get products stream
  Stream<List<Product>> get products {
    return _productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Add product
  Future<void> addProduct(Product product) async {
    // Note: We use the product.toMap() but without ID, Firestore generates it
    await _productsCollection.add(product.toMap());
  }

  // Add product with specific ID (optional, normally auto-id is better)
  // But our addProduct screen might want to just dump data.

  // Update product
  Future<void> updateProduct(Product product) async {
    await _productsCollection.doc(product.id).update(product.toMap());
  }

  // Delete product
  Future<void> deleteProduct(String id) async {
    await _productsCollection.doc(id).delete();
  }

  // --- Company Info Settings ---
  final DocumentReference _companyInfoDoc = FirebaseFirestore.instance
      .collection('settings')
      .doc('company_info');

  Stream<DocumentSnapshot> get companyInfoStream {
    return _companyInfoDoc.snapshots();
  }

  Future<void> updateCompanyInfo(Map<String, dynamic> data) async {
    await _companyInfoDoc.set(data, SetOptions(merge: true));
  }

  // --- Order Management ---
  final CollectionReference _ordersCollection = FirebaseFirestore.instance
      .collection('orders');

  // Place Order
  Future<void> placeOrder(OrderModel order) async {
    await _ordersCollection.add(order.toMap());
  }

  // Get User Orders
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return OrderModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();
        });
  }

  // Get All Orders (Admin)
  Stream<List<OrderModel>> get allOrders {
    return _ordersCollection.orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Update Order Status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _ordersCollection.doc(orderId).update({
      'status': status.toString().split('.').last,
    });
  }

  // --- Cart & Wishlist (Simplification: using local storage or firestore user doc) ---
  // For this scale, we can store cart/wishlist in a subcollection of users or just local.
  // Let's assume we want them persistent, so we save to Firestore under users/{uid}/...

  Future<void> addToCart(String uid, CartItem item) async {
    final cartRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(item.productId);

    final doc = await cartRef.get();
    if (doc.exists) {
      // Update quantity
      int currentQty = doc.get('quantity') ?? 0;
      await cartRef.update({'quantity': currentQty + item.quantity});
    } else {
      await cartRef.set(item.toMap());
    }
  }

  Future<void> updateCartItemQuantity(
    String uid,
    String productId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      await removeFromCart(uid, productId);
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(productId)
          .update({'quantity': quantity});
    }
  }

  Future<void> removeFromCart(String uid, String productId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  // Get User Data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return doc.data();
  }

  // Update User Data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update(data);
  }

  // Add Address
  Future<void> addAddress(String uid, String address) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'addresses': FieldValue.arrayUnion([address]),
    });
  }

  // Remove Address
  Future<void> removeAddress(String uid, String address) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'addresses': FieldValue.arrayRemove([address]),
    });
  }

  // Get User Addresses Stream
  Stream<List<String>> getUserAddresses(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data()!.containsKey('addresses')) {
            return List<String>.from(snapshot.data()!['addresses']);
          }
          return [];
        });
  }

  Future<void> clearCart(String uid) async {
    final batch = FirebaseFirestore.instance.batch();
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<List<CartItem>> getCart(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => CartItem.fromMap(doc.data())).toList(),
        );
  }

  // --- Wishlist ---
  Future<void> toggleWishlist(String uid, String productId) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'productId': productId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<String>> getWishlist(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // --- Reviews ---
  Future<void> addReview(String productId, Review review) async {
    await _productsCollection
        .doc(productId)
        .collection('reviews')
        .add(review.toMap());
  }

  Stream<List<Review>> getReviews(String productId) {
    return _productsCollection
        .doc(productId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Review.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }
}

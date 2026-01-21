import 'cart_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderModel {
  final String id;
  final String userId;
  final String userName; // Denormalized for Admin ease
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime date;
  final String address;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.date,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last, // Store as string
      'date': Timestamp.fromDate(date),
      'address': address,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Unknown',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      date: (map['date'] as Timestamp).toDate(),
      address: map['address'] ?? '',
    );
  }
}

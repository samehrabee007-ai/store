import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
// import 'package:intl/intl.dart'; // Add intl dependency if needed, or format manually

class MyOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('طلباتي')),
        body: Center(child: Text('يرجى تسجيل الدخول')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('طلباتي')),
      body: StreamBuilder<List<OrderModel>>(
        stream: DatabaseService().getUserOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد طلبات سابقة'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text(
                    'طلب بتاريخ: ${order.date.toString().substring(0, 16)}',
                  ),
                  subtitle: Text(
                    'الحالة: ${_getStatusText(order.status)} - الإجمالي: ${order.totalAmount} ج.م',
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: order.items.map((item) {
                    return ListTile(
                      title: Text(item.productName),
                      subtitle: Text('${item.price} ج.م × ${item.quantity}'),
                      trailing: Text('${item.price * item.quantity} ج.م'),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.processing:
        return 'جاري التجهيز';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغي';
      default:
        return 'غير معروف';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

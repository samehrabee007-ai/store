import 'package:flutter/material.dart';
import '../../models/order_model.dart'; // Ensure this model exists and is imported correctly
import '../../services/database_service.dart';
// import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إدارة الطلبات')),
      body: StreamBuilder<List<OrderModel>>(
        stream: DatabaseService().allOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد طلبات'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('طلب من: ${order.userName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('العنوان: ${order.address}'),
                      Text(
                        'التاريخ: ${order.date.toString().substring(0, 16)}',
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text('الحالة: '),
                          _buildStatusDropdown(context, order),
                        ],
                      ),
                    ],
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

  Widget _buildStatusDropdown(BuildContext context, OrderModel order) {
    return DropdownButton<OrderStatus>(
      value: order.status,
      onChanged: (OrderStatus? newValue) {
        if (newValue != null) {
          DatabaseService().updateOrderStatus(order.id, newValue);
        }
      },
      items: OrderStatus.values.map<DropdownMenuItem<OrderStatus>>((
        OrderStatus value,
      ) {
        return DropdownMenuItem<OrderStatus>(
          value: value,
          child: Text(
            _getStatusText(value),
            style: TextStyle(color: _getStatusColor(value)),
          ),
        );
      }).toList(),
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
    }
  }
}

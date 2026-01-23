import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ضروري لتحديد هوية المستخدم
import '../../services/database_service.dart'; // استيراد الخدمة المحدثة

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // جلب المستخدم الحالي

    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الشراء')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            if (user != null) {
              try {
                // استدعاء الوظيفة التي قمنا بتعريفها في DatabaseService
                await DatabaseService().clearCart(user.uid);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت عملية الشراء بنجاح وتم مسح السلة')),
                );
                Navigator.popUntil(context, ModalRoute.withName('/'));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('حدث خطأ: $e')),
                );
              }
            }
          },
          child: const Text('تأكيد الطلب ومسح السلة'),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ClientRegisterScreen extends StatefulWidget {
  @override
  _ClientRegisterScreenState createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _verificationId;
  // --- الإصلاح هنا: تعريف متغير حالة التحميل ---
  bool _isLoading = false; 

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await AuthService().verifyPhoneNumber(
          phoneNumber: _phoneController.text.trim(),
          onCodeSent: (verificationId, resendToken) {
            setState(() {
              _isLoading = false;
              _verificationId = verificationId;
            });
            _showOtpDialog();
          },
          onVerificationFailed: (e) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('فشل التحقق من الهاتف: ${e.message}')),
            );
          },
          onCodeAutoRetrievalTimeout: (verificationId) {
            _verificationId = verificationId;
          },
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  void _showOtpDialog() {
    final TextEditingController _otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('التحقق من رقم الهاتف'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تم إرسال كود التحقق إلى ${_phoneController.text}'),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'أدخل الكود (6 أرقام)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_otpController.text.isNotEmpty) {
                  Navigator.pop(context);
                  _completeRegistration(_otpController.text.trim());
                }
              },
              child: Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }

  void _completeRegistration(String smsCode) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_verificationId == null) throw 'OTP Verification ID missing';

      await AuthService().registerUserWithPhoneAndEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التسجيل: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Image.asset('assets/images/logo.png', height: 40),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'بيانات العميل',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم بالكامل',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال الاسم' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف (مثل +2010xxxxxxxx)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    hintText: '+201xxxxxxxxx',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'الرجاء إدخال رقم الهاتف';
                    if (!value.startsWith('+')) return 'يجب أن يبدأ الرقم بـ + (كود الدولة)';
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty ? 'الرجاء إدخال البريد الإلكتروني' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'الرجاء إدخال كلمة المرور';
                    if (value.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                    return null;
                  },
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text('تحقق وإنشاء حساب'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

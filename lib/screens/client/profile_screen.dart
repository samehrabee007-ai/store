import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/app_drawer.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final user = AuthService().currentUser;
    if (user != null) {
      _email = user.email;
      // Fetch fresh data from Firestore
      final userData = await DatabaseService().getUserData(user.uid);
      if (userData != null) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
        });
      }
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = AuthService().currentUser;
        if (user != null) {
          await DatabaseService().updateUserData(user.uid, {
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('تم تحديث البيانات بنجاح')));
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(labelText: 'كلمة المرور الحالية'),
              obscureText: true,
            ),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: 'كلمة المرور الجديدة'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _changePassword();
            },
            child: Text('تغيير'),
          ),
        ],
      ),
    );
  }

  void _changePassword() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تغيير كلمة المرور: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddressDialog() {
    final TextEditingController _addressController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('إضافة عنوان جديد'),
        content: TextField(
          controller: _addressController,
          decoration: InputDecoration(labelText: 'العنوان بالتفصيل'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (_addressController.text.isNotEmpty) {
                Navigator.pop(ctx);
                final user = AuthService().currentUser;
                if (user != null) {
                  await DatabaseService().addAddress(
                    user.uid,
                    _addressController.text,
                  );
                  setState(() {}); // Refresh list
                }
              }
            },
            child: Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الملف الشخصي'), centerTitle: true),
      drawer: AppDrawer(),
      body: _isLoading && _nameController.text.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        child: Icon(Icons.person, size: 40, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'البيانات الشخصية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'الاسم'),
                      validator: (val) => val!.isEmpty ? 'مطلوب' : null,
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'رقم الهاتف'),
                      validator: (val) => val!.isEmpty ? 'مطلوب' : null,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'البريد الإلكتروني: $_email',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        child: Text('حفظ التعديلات'),
                      ),
                    ),

                    Divider(height: 40),

                    Text(
                      'الأمان',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.lock),
                      title: Text('تغيير كلمة المرور'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showChangePasswordDialog,
                    ),

                    Divider(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'العناوين المحفوظة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.green),
                          onPressed: _showAddressDialog,
                        ),
                      ],
                    ),

                    StreamBuilder<List<String>>(
                      stream: DatabaseService().getUserAddresses(
                        AuthService().currentUser?.uid ?? '',
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('لا يوجد عناوين مسجلة'),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (ctx, i) => ListTile(
                            leading: Icon(Icons.location_on),
                            title: Text(snapshot.data![i]),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await DatabaseService().removeAddress(
                                  AuthService().currentUser!.uid,
                                  snapshot.data![i],
                                );
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

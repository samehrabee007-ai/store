import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';

class EditCompanyInfoScreen extends StatefulWidget {
  @override
  _EditCompanyInfoScreenState createState() => _EditCompanyInfoScreenState();
}

class _EditCompanyInfoScreenState extends State<EditCompanyInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // We can just listen to the stream locally or fetch once. Fetch once is fine for edit form.
    final doc = await FirebaseFirestore.instance.collection('settings').doc('company_info').get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      _aboutController.text = data['about'] ?? '';
      _facebookController.text = data['facebook'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _emailController.text = data['email'] ?? '';
    } else {
       // Defaults
       _facebookController.text = 'https://www.facebook.com/BetaLabGroup1';
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _saveData() async {
     if (_formKey.currentState!.validate()) {
       setState(() { _isLoading = true; });
       
       await DatabaseService().updateCompanyInfo({
         'about': _aboutController.text,
         'facebook': _facebookController.text,
         'phone': _phoneController.text,
         'email': _emailController.text,
       });
       
       setState(() { _isLoading = false; });
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم الحفظ بنجاح')));
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تعديل معلومات الشركة')),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _aboutController,
                    decoration: InputDecoration(
                      labelText: 'نبذة عن الشركة',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _facebookController,
                    decoration: InputDecoration(
                      labelText: 'رابط فيسبوك',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.facebook),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
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
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveData,
                      child: Text('حفظ التعديلات'),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

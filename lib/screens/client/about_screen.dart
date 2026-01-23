import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/database_service.dart';
import '../../widgets/app_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
      drawer: AppDrawer(),
      body: StreamBuilder<DatabaseEvent>(
        stream: DatabaseService().companyInfoStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final data =
              (snapshot.data!.snapshot.value as Map<dynamic, dynamic>?) ?? {};

          final String aboutText =
              data['about'] ?? 'شركة بيتا لاب للمستلزمات الطبية...';
          final String facebookUrl =
              data['facebook'] ?? 'https://www.facebook.com/BetaLabGroup1';
          final String phone = data['phone'] ?? '+201000000000';
          final String email = data['email'] ?? 'info@betalab.com';

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/images/logo.png', height: 150),
                ),
                SizedBox(height: 30),
                Text(
                  'بيتا لاب جروب',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      aboutText,
                      style: TextStyle(fontSize: 16, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Divider(),
                ListTile(
                  leading: Icon(Icons.facebook, color: Colors.blue),
                  title: Text('تابعنا على فيسبوك'),
                  subtitle: Text(facebookUrl),
                  onTap: () async {
                    if (!await launchUrl(
                      Uri.parse(facebookUrl),
                      mode: LaunchMode.externalApplication,
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not launch facebook')),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.phone, color: Colors.green),
                  title: Text('اتصل بنا'),
                  subtitle: Text(phone),
                  onTap: () async {
                    final Uri launchUri = Uri(scheme: 'tel', path: phone);
                    await launchUrl(launchUri);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.email, color: Colors.red),
                  title: Text('البريد الإلكتروني'),
                  subtitle: Text(email),
                  onTap: () async {
                    final Uri launchUri = Uri(scheme: 'mailto', path: email);
                    await launchUrl(launchUri);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

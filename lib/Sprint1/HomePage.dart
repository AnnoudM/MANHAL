import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Lighter background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: DefaultTextStyle(
        style: TextStyle(
          fontFamily: 'Blabeloo',
          fontSize: 16.0,
          color: Colors.black,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Avatar
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/avatar.png'), // Ensure this asset exists
              ),
              SizedBox(height: 10),
              
              // Welcome Text
              Text(
                'مرحبًا سارة!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              
              // Menu Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      buildMenuItem('رحلة الأحرف', Colors.lightBlue[100]!, 'ض'),
                      buildMenuItem('رحلة الأرقام', Colors.purple[100]!, '١٢٣'),
                      buildMenuItem('رحلة الكلمات', Colors.yellow[100]!, 'ن ت ع ل م'),
                      buildMenuItem('القيم الأخلاقية', Colors.pink[100]!, Icons.shield),
                    ],
                  ),
                ),
              ),

              // Image Scanner Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100], // Lighter button color
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'مسح الصورة',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItem(String title, Color color, dynamic icon) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon is String
                ? Text(icon, style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white))
                : Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
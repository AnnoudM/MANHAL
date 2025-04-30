import 'package:flutter/material.dart';
import 'manage_specific_content_view.dart';

class ManageContentView extends StatelessWidget {
  final String parentId;
  final String childId;

  const ManageContentView({
    super.key,
    required this.parentId,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> categories = [
      {
        "id": "letters",
        "title": "إدارة الحروف",
        "color": Colors.lightBlue[100],
        "textColor": const Color(0xFF638297),
        "iconText": "أ ب ج",
        "fontSize": 20.0,
        "iconSize": 40.0,
      },
      {
        "id": "numbers",
        "title": "إدارة الأرقام",
        "color": Colors.purple[100],
        "textColor": const Color(0xFF7A6B7D),
        "iconText": "١٢٣",
        "fontSize": 20.0,
        "iconSize": 40.0,
      },
      {
        "id": "words",
        "title": "إدارة الكلمات",
        "color": Colors.yellow[100],
        "textColor": const Color(0xFFB1A782),
        "iconText": "نتعلم",
        "fontSize": 20.0,
        "iconSize": 50.0,
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true, 
      backgroundColor: Colors.transparent, 
      appBar: AppBar(
        title: const Text("إدارة المحتوى"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackGroundManhal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildMenuItem(
                  title: category["title"]!,
                  color: category["color"]!,
                  textColor: category["textColor"]!,
                  iconText: category["iconText"],
                  iconPath: category["iconPath"],
                  fontSize: category["fontSize"] ?? 20.0,
                  iconSize: category["iconSize"] ?? 40.0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageSpecificContentView(
                          parentId: parentId,
                          childId: childId,
                          category: category["id"]!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required Color color,
    required Color textColor,
    String? iconText,
    String? iconPath,
    double fontSize = 20,
    double iconSize = 40,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null)
              Image.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
              )
            else if (iconText != null)
              Text(
                iconText,
                style: TextStyle(
                  fontSize: iconSize,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../view/wordsListView.dart';
import '../controller/HomePageController.dart'; // ✅ تأكد من المسار الصحيح

class ArabicWordsPage extends StatelessWidget {
  final String parentId;
  final String childId;

  const ArabicWordsPage({
    super.key,
    required this.parentId,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    print("📌 ArabicWordsPage - parentId: $parentId, childId: $childId");

    return Stack(
      children: [
        // ✅ الخلفية
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/BackGroundManhal.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // ✅ المحتوى الرئيسي فوق الخلفية
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              "لنتعلم الكلمات !",
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Blabeloo',
                color: Color(0xFF3F414E),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF3F414E)),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePageController(
                        parentId: parentId,
                        childID: childId,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          body: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection("Category")
                .doc("words")
                .collection("content")
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("❌ لا توجد بيانات متاحة"));
              }

              List<Map<String, String>> categories =
                  snapshot.data!.docs.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return {
                  "name": doc.id,
                  "image":
                      data.containsKey("image") ? data["image"] as String : "",
                };
              }).toList();

              return ListView.builder(
                itemCount: categories.length,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WordsListPage(
                            parentId: parentId,
                            childId: childId,
                            category: categories[index]["name"]!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: categories[index]["image"]!.isNotEmpty
                            ? DecorationImage(
                                image:
                                    NetworkImage(categories[index]["image"]!),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  const Color.fromRGBO(255, 255, 255, 0.3),
                                  BlendMode.lighten,
                                ))
                            : null,
                        color: categories[index]["image"]!.isEmpty
                            ? Colors.grey.shade300
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          categories[index]["name"]!,
                          style: const TextStyle(
                            fontSize: 32,
                            fontFamily: 'Blabeloo',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3F414E),
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

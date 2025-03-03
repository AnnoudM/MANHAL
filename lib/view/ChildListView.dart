import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/HomePageController.dart';
import '../view/AddChildView.dart';

class ChildListView extends StatefulWidget {
  const ChildListView({super.key});

  @override
  _ChildListViewState createState() => _ChildListViewState();
}

class _ChildListViewState extends State<ChildListView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String parentId;

  @override
  void initState() {
    super.initState();
    parentId = _auth.currentUser?.uid ?? ''; // جلب معرف الوالد الحالي
  }

  Stream<QuerySnapshot> fetchChildrenStream() {
    return _firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .snapshots(); // مراقبة التغيرات في قاعدة البيانات بشكل مباشر
  }

  @override
Widget build(BuildContext context) {
  return Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          /// ✅ **إضافة الخلفية**
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackGroundManhal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// ✅ **زر الرجوع (بدون AppBar)**
          Positioned(
            top: 50, // لضبط موقع زر الرجوع مثل السابق
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          /// ✅ **العنوان**
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: const Text(
                'أطفالي',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Blabeloo',
                ),
              ),
            ),
          ),

          /// ✅ **المحتوى الرئيسي**
          Padding(
            padding: const EdgeInsets.only(top: 100, left: 20, right: 20), // ✅ لضبط المحتوى بعد العنوان وزر الرجوع
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: fetchChildrenStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('حدث خطأ أثناء تحميل البيانات');
                      } else {
                        var children = snapshot.data?.docs ?? [];

                        if (children.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'لا يوجد أطفال مسجلين',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildAddChildButton(),
                            ],
                          );
                        }

                        return GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: children.length + 1,
                          itemBuilder: (context, index) {
                            if (index == children.length) {
                              return _buildAddChildButton();
                            } else {
                              var childData = children[index].data() as Map<String, dynamic>;
                              return _buildChildAvatar(children[index].id, childData);
                            }
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  /// بناء عنصر لكل طفل
  Widget _buildChildAvatar(String childId, Map<String, dynamic> childData) {
    return GestureDetector(
      onTap: () {
        print("تم اختيار الطفل بمعرف: $childId"); // التحقق من معرف الطفل قبل الإرسال
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePageController(childID: childId),
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: childData['photoUrl']?.isNotEmpty == true
                ? AssetImage(childData['photoUrl'])
                : const AssetImage('assets/images/default_avatar.jpg') as ImageProvider,
            backgroundColor: Colors.yellow[100],
          ),
          const SizedBox(height: 10),
          Text(
            childData['name'] ?? 'غير معروف',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// بناء زر لإضافة طفل جديد
  Widget _buildAddChildButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddChildView(parentId: parentId),
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFFFE08A),
            child: const Icon(
              Icons.add,
              size: 40,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'طفل جديد',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
} 

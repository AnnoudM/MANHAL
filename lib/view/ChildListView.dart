import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controller/HomePageController.dart';
import '../view/child_info_view.dart';

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

  Future<List<Map<String, dynamic>>> fetchChildren() async {
    List<Map<String, dynamic>> children = [];
    if (parentId.isNotEmpty) {
      var snapshot = await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .get();

      for (var doc in snapshot.docs) {
        children.add({
          'id': doc.id, // معرف الطفل (Document ID)
          'data': doc.data(), // بيانات الطفل
        });
      }
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'من يستخدم منهل الآن؟',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchChildren(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text('حدث خطأ أثناء تحميل البيانات');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('لا يوجد أطفال مسجلين');
                      } else {
                        var children = snapshot.data!;
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
                              var child = children[index];
                              return _buildChildAvatar(child['id'], child['data']);
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
                ? NetworkImage(childData['photoUrl'])
                : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
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
            builder: (context) => ChildInfoView(),
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
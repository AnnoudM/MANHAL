import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../view/HomePageView.dart';
import '../view/child_info_view.dart';
import '../model/child_model.dart';

class ChildListView extends StatefulWidget {
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
    parentId = _auth.currentUser?.uid ?? '';
  }

  Future<List<Child>> fetchChildren() async {
    List<Child> children = [];
    if (parentId.isNotEmpty) {
      var snapshot = await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .get();

      for (var doc in snapshot.docs) {
        children.add(Child.fromMap(doc.data()));
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
            icon: Icon(Icons.arrow_back, color: Colors.black),
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
                  child: FutureBuilder<List<Child>>(
                    future: fetchChildren(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('حدث خطأ أثناء تحميل البيانات');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('لا يوجد أطفال مسجلين');
                      } else {
                        var children = snapshot.data!;
                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: children.length + 1,
                          itemBuilder: (context, index) {
                            if (index == children.length) {
                              return _buildAddChildButton();
                            } else {
                              return _buildChildAvatar(children[index]);
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

  Widget _buildChildAvatar(Child child) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePageView(
              userName: child.name,
              onUserNameClick: () {},
              onScanImageClick: () {},
            ),
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/default_avatar.png'), // استبدل هذا بمسار صورة الطفل
            backgroundColor: Colors.yellow[100],
          ),
          const SizedBox(height: 10),
          Text(
            child.name,
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

  Widget _buildAddChildButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildInfoView(), // تعديل حسب الحاجة
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

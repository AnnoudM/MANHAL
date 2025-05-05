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
    parentId = _auth.currentUser?.uid ?? '';
  }

  // Get real-time stream of children from Firestore
  Stream<QuerySnapshot> fetchChildrenStream() {
    return _firestore
        .collection('Parent')
        .doc(parentId)
        .collection('Children')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/BackGroundManhal.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Back button
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // Title text
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

            // List of children + add button
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
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
                            // Show message if no children
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

                          // Display children in grid + "Add" button
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

  // Widget to show a child’s avatar and name
  Widget _buildChildAvatar(String childId, Map<String, dynamic> childData) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePageController(childID: childId, parentId: parentId),
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

  // Button to add a new child
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

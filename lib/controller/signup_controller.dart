import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/signup_model.dart';
import '../model/child_model.dart';
import 'package:flutter/material.dart';
import '../view/child_info_view.dart';
import '../view/InitialView.dart';

class SignUpController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for signup form fields
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  SignUpModel? _tempParentData;

  // Temporarily store parent data
  Future<void> saveParentDataTemp(SignUpModel parent) async {
    _tempParentData = parent;
  }

  // Check if email already exists in Firestore
  Future<bool> isEmailRegistered(String email) async {
    final result = await _firestore
        .collection('Parent')
        .where('email', isEqualTo: email)
        .get();
    return result.docs.isNotEmpty;
  }

  // Save parent info to Firestore
  Future<void> saveParentData(String uid, SignUpModel parent) async {
    await _firestore.collection('Parent').doc(uid).set(parent.toMap());
  }

  // Add child under parent document
  Future<void> addChild(String parentId, Child child) async {
    try {
      await _firestore
          .collection('Parent')
          .doc(parentId)
          .collection('Children')
          .add({
        ...child.toMap(),
        'level': 1,
        'stickers': [],
        'lockedContent': {
          'letters': <String>[],
          'numbers': <String>[],
          'words': <String>[],
        },
        'progress': {
          'letters': <String>[],
          'numbers': <String>[],
          'words': <String>[],
          'EthicalValue': <String>[],
        },
        'stickersProgress': {
          'numbers': 0,
          'letters': 0,
          'videos': 0,
        }
      });
    } catch (e) {
      print('Error adding child: $e');
    }
  }

  // Send email verification link
  Future<void> sendEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      print('Verification email sent to ${user.email}');
    }
  }

  // Check if email is verified
  Future<void> checkEmailVerification(BuildContext context) async {
    await _auth.currentUser?.reload();
    User? user = _auth.currentUser;

    if (user != null && user.emailVerified) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFF8F8F8),
            title: Text('Email Verified',
                style: TextStyle(fontFamily: 'alfont')),
            content: Text('Your email has been successfully verified.',
                style: TextStyle(fontFamily: 'alfont')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InitialPage(),
                    ),
                  );
                },
                child: Text('OK', style: TextStyle(fontFamily: 'alfont')),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFF8F8F8),
            title: Text('Email Verification',
                style: TextStyle(fontFamily: 'alfont')),
            content: Text('Please verify your email using the link sent to you.',
                style: TextStyle(fontFamily: 'alfont')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK', style: TextStyle(fontFamily: 'alfont')),
              ),
            ],
          );
        },
      );
    }
  }

  // Navigate to child info form
  void proceedToChildInfo(BuildContext context, String parentId) {
    String childId = FirebaseFirestore.instance.collection('Children').doc().id;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildInfoView(
          parentData: _tempParentData,
          parentId: parentId,
          childId: childId,
        ),
      ),
    );
  }

  // Register parent and child, then send verification
  Future<void> registerParentAndChild(
      BuildContext context, Child child, SignUpModel parentData) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: parentData.email,
        password: parentData.password,
      );

      String parentId = userCredential.user!.uid;
      await saveParentData(parentId, parentData);
      await addChild(parentId, child);
      await sendEmailVerification();

      proceedToChildInfo(context, parentId);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFF8F8F8),
            title: Text('Verification Sent',
                style: TextStyle(fontFamily: 'alfont')),
            content: Text(
                'A verification link has been sent to your email. Please check your inbox.',
                style: TextStyle(fontFamily: 'alfont')),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InitialPage(),
                    ),
                  );
                },
                child: Text('OK', style: TextStyle(fontFamily: 'alfont')),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(e.toString(), style: TextStyle(fontFamily: 'alfont'))),
      );
    }
  }
}

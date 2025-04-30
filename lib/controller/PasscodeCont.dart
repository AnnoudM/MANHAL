import 'package:flutter/material.dart';
import '../model/PasscodeModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PasscodeController with ChangeNotifier {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PasscodeModel _model = PasscodeModel();
  String? _storedPasscode; // الباسكود المخزن في الداتابيس
  String enteredPasscode = "";
  String confirmPasscode = "";
  bool hasPasscode = false; // هل يوجد باسكود مخزن؟
  bool isConfirming = false; // هل نحن في مرحلة التأكيد؟
  bool isLoading = true; // ✅ حالة التحميل
  String? errorMessage;

  // ✅ جلب بيانات الباسكود عند فتح الصفحة
  Future<void> checkPasscodeStatus(String parentId) async {
    try {
      print("🔍 بدأ جلب البيانات من Firebase للوالد ID: $parentId");
      isLoading = true;
      notifyListeners();

      _storedPasscode = await _model.getStoredPasscode(parentId);
      hasPasscode = _storedPasscode != null;

      print("✅ تم جلب البيانات: ${_storedPasscode != null ? 'يوجد باسكود' : 'لا يوجد باسكود'}");

      isLoading = false; // ✅ إنهاء التحميل بعد جلب البيانات
      notifyListeners();
    } catch (e) {
      print("❌ خطأ أثناء جلب البيانات من Firestore: $e");
      isLoading = false;
      notifyListeners();
    }
  }

   Future<void> resetPasscode(String parentId, String newPasscode) async {
    await _firestore.collection('Parent').doc(parentId).update({'Passcode': newPasscode});
  }

  // ✅ تحديث إدخال المستخدم
  void updateEnteredPasscode(String value) {
    if (enteredPasscode.length < 4) {
      enteredPasscode += value;
      notifyListeners();
    }
  }

  // ✅ حذف آخر رقم
  void deleteLastDigit() {
    if (enteredPasscode.isNotEmpty) {
      enteredPasscode = enteredPasscode.substring(0, enteredPasscode.length - 1);
      notifyListeners();
    }
  }


  // ✅ معالجة إدخال الباسكود
  Future<bool> submitPasscode(String parentId) async {
    if (hasPasscode) {
      // 🔐 التحقق من الباسكود المسجل
      if (enteredPasscode == _storedPasscode) {
        return true;
      } else {
        errorMessage = "الرقم السري غير صحيح";
        enteredPasscode = "";
        notifyListeners();
        return false;
      }
    } else {
      // 🆕 إدخال باسكود جديد
      if (enteredPasscode.length < 4) {
        errorMessage = "الرجاء إدخال 4 أرقام";
        notifyListeners();
        return false;
      }

      // 🔁 التأكيد على الباسكود
      if (!isConfirming) {
        confirmPasscode = enteredPasscode;
        enteredPasscode = "";
        isConfirming = true;
        errorMessage = "أعد إدخال الرقم السري للتأكيد";
        notifyListeners();
        return false;
      }

      // ❌ إذا لم تتطابق كلمة المرور مع التأكيد
      if (confirmPasscode != enteredPasscode) {
        errorMessage = "الرقم السري غير متطابق، حاول مرة أخرى";
        enteredPasscode = "";
        confirmPasscode = "";
        isConfirming = false;
        notifyListeners();
        return false;
      }

      // ✅ حفظ الباسكود الجديد
      await _model.savePasscode(parentId, confirmPasscode);
      return true;
    }
  }
}

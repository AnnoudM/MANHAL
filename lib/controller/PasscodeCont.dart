import 'package:flutter/material.dart';
import '../model/PasscodeModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PasscodeController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PasscodeModel _model = PasscodeModel();

  String? _storedPasscode; // stored passcode from DB
  String enteredPasscode = "";
  String confirmPasscode = "";
  bool hasPasscode = false; // whether a passcode exists
  bool isConfirming = false; // used for confirmation step
  bool isLoading = true; // loading state
  String? errorMessage;

  // Load stored passcode on screen open
  Future<void> checkPasscodeStatus(String parentId) async {
    try {
      print("🔍 Fetching passcode for parent ID: $parentId");
      isLoading = true;
      notifyListeners();

      _storedPasscode = await _model.getStoredPasscode(parentId);
      hasPasscode = _storedPasscode != null;

      print("✅ Result: ${_storedPasscode != null ? 'Has passcode' : 'No passcode'}");

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("❌ Error while fetching passcode: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  // Update passcode manually in Firestore
  Future<void> resetPasscode(String parentId, String newPasscode) async {
    await _firestore.collection('Parent').doc(parentId).update({'Passcode': newPasscode});
  }

  // Update entered passcode on button tap
  void updateEnteredPasscode(String value) {
    if (enteredPasscode.length < 4) {
      enteredPasscode += value;
      notifyListeners();
    }
  }

  // Remove last digit
  void deleteLastDigit() {
    if (enteredPasscode.isNotEmpty) {
      enteredPasscode = enteredPasscode.substring(0, enteredPasscode.length - 1);
      notifyListeners();
    }
  }

  // Submit and validate passcode logic
  Future<bool> submitPasscode(String parentId) async {
    if (hasPasscode) {
      // Validate existing passcode
      if (enteredPasscode == _storedPasscode) {
        return true;
      } else {
        errorMessage = "الرقم السري غير صحيح";
        enteredPasscode = "";
        notifyListeners();
        return false;
      }
    } else {
      // Setting up new passcode
      if (enteredPasscode.length < 4) {
        errorMessage = "الرجاء إدخال 4 أرقام";
        notifyListeners();
        return false;
      }

      // Start confirmation phase
      if (!isConfirming) {
        confirmPasscode = enteredPasscode;
        enteredPasscode = "";
        isConfirming = true;
        errorMessage = "أعد إدخال الرقم السري للتأكيد";
        notifyListeners();
        return false;
      }

      // Mismatch between first and confirm passcode
      if (confirmPasscode != enteredPasscode) {
        errorMessage = "الرقم السري غير متطابق، حاول مرة أخرى";
        enteredPasscode = "";
        confirmPasscode = "";
        isConfirming = false;
        notifyListeners();
        return false;
      }

      // Save new passcode
      await _model.savePasscode(parentId, confirmPasscode);
      return true;
    }
  }
}

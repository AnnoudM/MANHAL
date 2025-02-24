import 'package:flutter/material.dart';
import '../model/PasscodeModel.dart';

class PasscodeController with ChangeNotifier {
  final PasscodeModel _model = PasscodeModel();
  String? _storedPasscode;
  String enteredPasscode = "";
  String confirmPasscode = "";
  bool isNewParent = false;
  bool isConfirming = false;
  String? errorMessage;

  Future<void> checkIfNewParent(String parentId) async {
    _storedPasscode = await _model.getStoredPasscode(parentId);
    isNewParent = _storedPasscode == null; // ✅ الآن يتم تحديث isNewParent بشكل صحيح
    notifyListeners();
  }

  void updateEnteredPasscode(String value) {
    if (enteredPasscode.length < 4) {
      enteredPasscode += value;
      notifyListeners();
    }
  }

  void deleteLastDigit() {
    if (enteredPasscode.isNotEmpty) {
      enteredPasscode = enteredPasscode.substring(0, enteredPasscode.length - 1);
      notifyListeners();
    }
  }

  Future<bool> submitPasscode(String parentId) async {
    if (isNewParent) {
      if (enteredPasscode.length < 4) {
        errorMessage = "الرجاء إدخال 4 أرقام";
        notifyListeners();
        return false;
      }

      if (!isConfirming) {
        confirmPasscode = enteredPasscode;
        enteredPasscode = "";
        isConfirming = true;
        notifyListeners();
        return false;
      }

      if (confirmPasscode != enteredPasscode) {
        errorMessage = "رمز المرور غير متطابق، حاول مرة أخرى";
        enteredPasscode = "";
        confirmPasscode = "";
        isConfirming = false;
        notifyListeners();
        return false;
      }

      await _model.savePasscode(parentId, confirmPasscode);
      return true;
    } else {
      if (enteredPasscode == _storedPasscode) {
        return true;
      } else {
        errorMessage = "رمز المرور غير صحيح";
        enteredPasscode = "";
        notifyListeners();
        return false;
      }
    }
  }
}

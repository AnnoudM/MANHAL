import 'package:flutter/material.dart';
import '../model/ProgressModel.dart';

class ProgressController extends ChangeNotifier {
  List<ProgressModel> progressList = [];
  bool isLoading = true;

  // load progress data for specific child from Firestore
  Future<void> loadProgress(String parentId, String childId) async {
    isLoading = true;
    notifyListeners();

    progressList = await ProgressModel.fetchProgress(parentId, childId);

    isLoading = false;
    notifyListeners();
  }
}

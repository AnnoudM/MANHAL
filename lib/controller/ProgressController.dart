import 'package:flutter/material.dart';
import '../model/ProgressModel.dart';

class ProgressController extends ChangeNotifier {
  List<ProgressModel> progressList = [];
  bool isLoading = true;

  Future<void> loadProgress(String parentId, String childId) async {
    isLoading = true;
    notifyListeners();

    progressList = await ProgressModel.fetchProgress(parentId, childId);

    isLoading = false;
    notifyListeners();
  }
}
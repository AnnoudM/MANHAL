import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/ProgressController.dart';

class ProgressView extends StatelessWidget {
  final String parentId;
  final String childId;

  const ProgressView({Key? key, required this.parentId, required this.childId})
      : super(key: key);

  // تحويل اسم الفئة إلى العربية
  String getArabicCategoryName(String englishName) {
    switch (englishName) {
      case 'letters':
        return 'الحروف';
      case 'numbers':
        return 'الأرقام';
      case 'words':
        return 'الكلمات';
      case 'Ethical Values':
        return 'القيم الأخلاقية';
      default:
        return englishName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressController()..loadProgress(parentId, childId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تقدم الطفل", style: TextStyle(fontFamily: 'Cairo')),
        ),
        body: Consumer<ProgressController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: controller.progressList.length,
              itemBuilder: (context, index) {
                final progress = controller.progressList[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getArabicCategoryName(progress.categoryName),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: progress.totalCount > 0 ? progress.progressCount / progress.totalCount : 0,
                          minHeight: 10,
                          color: Colors.blue,
                          backgroundColor: Colors.grey[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "اكتمل ${progress.progressCount} من ${progress.totalCount}",
                          style: const TextStyle(fontSize: 16, fontFamily: 'Cairo'),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
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

  // تحويل الأرقام إلى الأرقام العربية
  String convertToArabicNumbers(int number) {
    String englishNumbers = number.toString();
    Map<String, String> arabicNumbers = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩'
    };
    return englishNumbers.split('').map((e) => arabicNumbers[e] ?? e).join('');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressController()..loadProgress(parentId, childId),
      child: Scaffold(
        body: Stack(
          children: [
            // الخلفية الشاملة للـ AppBar وللمحتوى
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/BackGroundManhal.jpg"),
                    fit: BoxFit.cover, // تغطية الشاشة بالكامل
                  ),
                ),
              ),
            ),
            // الأب بار
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                title: const Text(
                  "تقدم الطفل",
                  style: TextStyle(fontFamily: 'alfont', fontSize: 28),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent, // الأب بار شفاف
                elevation: 0, // إزالة الظل من الأب بار
              ),
            ),
            // المحتوى
            Positioned.fill(
              top: 80, // تأكيد ترك مساحة للأب بار
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // جعل المحتوى في منتصف الصفحة
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        "هنا سيظهر تقدم طفلك في كل من الحروف، الأرقام، الكلمات والقيم الأخلاقية.",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'alfont',
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: Consumer<ProgressController>(
                        builder: (context, controller, child) {
                          if (controller.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          return ListView.builder(
                            itemCount: controller.progressList.length,
                            itemBuilder: (context, index) {
                              final progress = controller.progressList[index];
                              return Center(
                                child: Card(
                                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  color: Colors.white, // المستطيلات بيضاء
                                  elevation: 3, // إضافة ظل خفيف
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          getArabicCategoryName(progress.categoryName),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'alfont',
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        LinearProgressIndicator(
                                          value: progress.totalCount > 0
                                              ? progress.progressCount / progress.totalCount
                                              : 0,
                                          minHeight: 10,
                                          color: Colors.blue,
                                          backgroundColor: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          "اكتمل ${convertToArabicNumbers(progress.progressCount)} من ${convertToArabicNumbers(progress.totalCount)}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: 'alfont',
                                          ),
                                          textDirection: TextDirection.rtl,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
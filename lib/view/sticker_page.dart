import 'package:flutter/material.dart';
import '../controller/sticker_controller.dart';
import '../model/sticker_model.dart';

class StickerPage extends StatelessWidget {
  final StickerController stickerController = StickerController();
  final String parentId; // ✅ نحتاج معرف الوالد
  final String childId; // ✅ نحتاج معرف الطفل

  StickerPage({super.key, required this.parentId, required this.childId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ملصقاتي', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Sticker>>(
        future: stickerController.getStickersForChild(parentId, childId), // ✅ إضافة parentId
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'لا توجد ملصقات بعد!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          List<Sticker> stickers = snapshot.data!;

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: stickers.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(stickers[index].link, fit: BoxFit.cover), // ✅ عرض صورة الملصق
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

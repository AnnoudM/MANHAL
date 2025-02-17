import 'package:flutter/material.dart';
import '../controller/sticker_controller.dart';
import '../model/sticker_model.dart';

class StickerPage extends StatelessWidget {
  final StickerController stickerController = StickerController();

  @override
  Widget build(BuildContext context) {
    List<Sticker> stickers = stickerController.getStickers();

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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: stickers.isEmpty
            ? Center(
                child: Text(
                  'لا توجد ملصقات بعد!',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : GridView.builder(
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
                      child: Image.network(stickers[index].imageUrl, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

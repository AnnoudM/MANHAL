import '../model/sticker_model.dart';

class StickerController {
  // Dummy list (Later, we will replace with Firebase calls)
  List<Sticker> getStickers() {
    return [
      Sticker(id: '1', imageUrl: 'https://via.placeholder.com/100'),
      Sticker(id: '2', imageUrl: 'https://via.placeholder.com/100'),
      Sticker(id: '3', imageUrl: 'https://via.placeholder.com/100'),
      Sticker(id: '4', imageUrl: 'https://via.placeholder.com/100'),
      Sticker(id: '5', imageUrl: 'https://via.placeholder.com/100'),
    ];
  }
}

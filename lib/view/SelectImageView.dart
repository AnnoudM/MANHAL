import 'package:flutter/material.dart';
import '../controller/SelectImageController.dart';
import '../model/SelectImageModel.dart';

class SelectImageView extends StatefulWidget {
  final String? childID;

  const SelectImageView({super.key, this.childID});

  @override
  _SelectImageViewState createState() => _SelectImageViewState();
}

class _SelectImageViewState extends State<SelectImageView> {
  final SelectImageController _controller = SelectImageController();
  final SelectImageModel _model = SelectImageModel();
  String? selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackGroundManhal.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // back button
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "اختر صورة",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Blabeloo',
                ),
              ),
              const SizedBox(height: 20),
              // grid of images
              Expanded(
                child: Center(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: _model.images.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImage = _model.images[index];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedImage == _model.images[index]
                                  ? Colors.blue
                                  : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            _model.images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // save button
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF3CD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      if (selectedImage != null) {
                        if (widget.childID != null) {
                          _controller.updateChildImage(context, widget.childID!, selectedImage!);
                        } else {
                          Navigator.pop(context, selectedImage);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("❌ الرجاء اختيار صورة!"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "حفظ",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontFamily: 'Blabeloo',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../controller/ChildController.dart';
import '../model/child_model.dart';
import '../view/SelectImageView.dart';
import 'package:flutter/services.dart';

class ChildPageView extends StatefulWidget {
  final Child child;

  const ChildPageView({super.key, required this.child});

  @override
  _ChildPageViewState createState() => _ChildPageViewState();
}

class _ChildPageViewState extends State<ChildPageView> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late String? _selectedPhoto;
  final ChildController _controller = ChildController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.name);
    _ageController = TextEditingController(text: widget.child.age.toString());
    _selectedPhoto = widget.child.photoUrl;
  }

  void _updateChildInfo() async {
    Child updatedChild = widget.child.copyWith(
      name: _nameController.text,
      age: int.tryParse(_ageController.text) ?? widget.child.age,
      photoUrl: _selectedPhoto,
    );
    await _controller.updateChildInfo(updatedChild);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'معلومات الطفل',
            style: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'alfont',
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/BackGroundManhal.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final selectedPhoto = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SelectImageView()),
                        );
                        if (selectedPhoto != null) {
                          setState(() {
                            _selectedPhoto = selectedPhoto;
                          });
                          _updateChildInfo();
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(_selectedPhoto ?? 'assets/images/default_avatar.jpg'),
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.edit, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildEditableField(
                    context,
                    'الاسم',
                    widget.child.name,
                    () => _showEditDialog(
                      'تعديل الاسم',
                      widget.child.name,
                      (newName) {
                        _nameController.text = newName;
                        _updateChildInfo();
                      },
                    ),
                  ),
                  _buildEditableField(
                    context,
                    'العمر',
                    widget.child.age.toString(),
                    () => _showEditDialog(
                      'تعديل العمر',
                      widget.child.age.toString(),
                      (newAge) {
                        _ageController.text = newAge;
                        _updateChildInfo();
                      },
                    ),
                  ),
                  _buildStaticField('الجنس', widget.child.gender), // الجنس غير قابل للتعديل
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(BuildContext context, String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'alfont',
            ),
          ),
          trailing: const Icon(Icons.edit, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildStaticField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          title: Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'alfont',
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(String title, String initialValue, Function(String) onSave) {
    TextEditingController textController = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontFamily: 'alfont')),
          content: TextField(
            controller: textController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(filled: true, fillColor: Color(0xFFFFF5CC)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            TextButton(onPressed: () {
              onSave(textController.text.trim());
              Navigator.pop(context);
            }, child: const Text('حفظ')),
          ],
        );
      },
    );
  }
}
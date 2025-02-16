import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/ChildController.dart';
import '../model/child_model.dart';
import '../view/SelectImageView.dart';

class ChildPageView extends StatefulWidget {
  final Child child;

  const ChildPageView({super.key, required this.child});

  @override
  _ChildPageViewState createState() => _ChildPageViewState();
}

class _ChildPageViewState extends State<ChildPageView> {
  final ChildController _controller = ChildController();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late String? _selectedPhoto;
  late Child _child; // ✅ المتغير الجديد لتخزين بيانات الطفل

void _showEditDialog(String title, String initialValue, Function(String) onSave) {
  TextEditingController textController = TextEditingController(text: initialValue);
  final _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFF8F8F8),
        title: Text(title, style: const TextStyle(fontFamily: 'alfont')),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: textController,
            validator: (value) => value!.isEmpty ? 'يجب إدخال قيمة' : null,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFFFF5CC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              errorStyle: const TextStyle(fontFamily: 'alfont', color: Colors.red),
            ),
            style: const TextStyle(fontFamily: 'alfont'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'alfont')),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                onSave(textController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ', style: TextStyle(fontFamily: 'alfont')),
          ),
        ],
      );
    },
  );
}


@override
void initState() {
  super.initState();
  _child = widget.child; // ✅ استخدم نسخة محلية قابلة للتعديل
  _nameController = TextEditingController(text: _child.name);
  _ageController = TextEditingController(text: _child.age.toString());
  _selectedPhoto = _child.photoUrl;
}




Future<void> _fetchLatestChildData() async {
  debugPrint("🔄 جلب أحدث بيانات الطفل من Firebase...");
  Child? latestChild = await _controller.getChildInfo(_child.parentId, _child.id);

  if (latestChild != null) {
    debugPrint("✅ تم جلب البيانات الجديدة: ${latestChild.name}, ${latestChild.age}");
    setState(() {
      _child = latestChild;
      _nameController.text = _child.name;
      _ageController.text = _child.age.toString();
      _selectedPhoto = _child.photoUrl;
    });
  } else {
    debugPrint("⚠️ لم يتم العثور على بيانات الطفل المحدثة.");
  }
}



 void _updateChildInfo() async {
  if (_formKey.currentState!.validate()) {
    String newName = _nameController.text.trim();
    int newAge = int.tryParse(_ageController.text.trim()) ?? _child.age;

    setState(() {
      _child = _child.copyWith(name: newName, age: newAge, photoUrl: _selectedPhoto);
    });

    await _controller.updateChildInfo(_child, (updatedChildFromDB) {
      debugPrint("✅ البيانات تم تحديثها بنجاح!");

      // ✅ إضافة SnackBar بعد تحديث البيانات
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تعديل المعلومات بنجاح', style: TextStyle(fontFamily: 'alfont')),
          backgroundColor: Colors.green,
        ),
      );
    });
  }
}





  void _deleteChild() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F8F8),
          title: const Text('تأكيد الحذف', style: TextStyle(fontFamily: 'alfont')),
          content: const Text('هل أنت متأكد من حذف هذا الطفل؟', style: TextStyle(fontFamily: 'alfont')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'alfont')),
            ),
            TextButton(
              onPressed: () async {
                await _controller.deleteChildAndNavigate(context, widget.child.parentId, widget.child.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف الطفل بنجاح', style: TextStyle(fontFamily: 'alfont')),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('حذف', style: TextStyle(fontFamily: 'alfont', color: Colors.red)),
            ),
          ],
        );
      },
    );
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
            /// ✅ **إضافة الخلفية الصحيحة بحيث تتناسب مع باقي الصفحات**
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/BackGroundManhal.jpg'), // نفس الخلفية الموجودة في صفحة معلوماتي الشخصية
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

        // ✅ سناك بار بعد تحديث الصورة
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الصورة بنجاح', style: TextStyle(fontFamily: 'alfont')),
            backgroundColor: Colors.green,
          ),
        );
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
  'الاسم',
  _child.name,
  () => _showEditDialog(
    'تعديل الاسم',
    _child.name,
    (newName) {
      setState(() {
        _child = _child.copyWith(name: newName);
      });
      _updateChildInfo();

      // ✅ سناك بار بعد تعديل الاسم
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تعديل الاسم بنجاح', style: TextStyle(fontFamily: 'alfont')),
          backgroundColor: Colors.green,
        ),
      );
    },
  ),
),


                  _buildEditableField(
  'العمر',
  _child.age.toString(),
  () => _showEditDialog(
    'تعديل العمر',
    _ageController.text,
    (newAge) {
      setState(() {
        _child = _child.copyWith(age: int.tryParse(newAge) ?? _child.age);
      });
      _updateChildInfo();

      // ✅ سناك بار بعد تعديل العمر
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تعديل العمر بنجاح', style: TextStyle(fontFamily: 'alfont')),
          backgroundColor: Colors.green,
        ),
      );
    },
  ),
),

                  _buildStaticField('الجنس', widget.child.gender), // تمت إضافته بنفس تصميم باقي الحقول
                  const Spacer(),
                  _buildActionButton(context, 'حذف الطفل', Colors.redAccent, _deleteChild),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String value, VoidCallback onTap) {
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
          title: Text('$label: $value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'alfont')),
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
          title: Text('$label: $value', style: const TextStyle(fontSize: 18, fontFamily: 'alfont')),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 5,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'alfont'),
      ),
    );
  }
}

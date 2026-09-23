import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:food/core/constants/app_colors.dart';
import 'package:food/core/widgets/custom_text_field.dart';
import 'package:food/features/auth/domain/user_model.dart';
import 'package:food/features/profile/data/profile_repository.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  final ProfileRepository _profileRepository = ProfileRepository();
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      // 1. Upload image if selected
      if (_selectedImage != null) {
        await _profileRepository.uploadProfileImage(widget.user.id, _selectedImage!);
      }

      // 2. Update text data
      await _profileRepository.updateProfile(widget.user.id, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث الملف الشخصي بنجاح")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e"), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("تعديل الملف الشخصي"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Profile Image Picker
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60.r,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: _selectedImage != null 
                        ? FileImage(_selectedImage!) 
                        : (widget.user.profileImage != null ? NetworkImage(widget.user.profileImage!) : null) as ImageProvider?,
                    child: _selectedImage == null && widget.user.profileImage == null
                        ? Icon(Icons.person, size: 60.sp, color: AppColors.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
            CustomTextField(
              controller: _nameController,
              hintText: "الاسم الكامل",
              prefixIcon: Icons.person_outline,
            ),
            SizedBox(height: 20.h),
            CustomTextField(
              controller: _phoneController,
              hintText: "رقم الهاتف",
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("حفظ التغييرات"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

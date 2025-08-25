import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/workshop_provider.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/layout/responsive_layout.dart';
import '../../../domain/entities/workshop.dart';

/// Workshop form screen for creating and editing workshops
class WorkshopFormScreen extends StatefulWidget {
  final Workshop? workshop;

  const WorkshopFormScreen({
    this.workshop,
    super.key,
  });

  @override
  State<WorkshopFormScreen> createState() => _WorkshopFormScreenState();
}

class _WorkshopFormScreenState extends State<WorkshopFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _tagsController = TextEditingController();

  File? _selectedImage;
  String? _currentImageUrl;
  final ImagePicker _imagePicker = ImagePicker();

  bool get _isEditing => widget.workshop != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _populateFields();
    }
  }

  void _populateFields() {
    final workshop = widget.workshop!;
    _titleController.text = workshop.title;
    _descriptionController.text = workshop.description;
    _priceController.text = workshop.price.toString();
    _capacityController.text = workshop.capacity.toString();
    _tagsController.text = workshop.tags.join(', ');
    _currentImageUrl = workshop.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '워크샵 수정' : '워크샵 등록'),
        elevation: 0,
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildForm(),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),
          const SizedBox(height: 24),
          _buildBasicInfoSection(),
          const SizedBox(height: 24),
          _buildDetailsSection(),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '워크샵 이미지',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildImagePreview(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '이미지를 탭하여 선택하세요 (선택사항)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
        ),
      );
    } else if (_currentImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          _currentImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        ),
      );
    } else {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          '이미지 추가',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기본 정보',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _titleController,
          label: '워크샵 제목',
          hint: '워크샵 제목을 입력하세요',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '워크샵 제목을 입력해주세요';
            }
            if (value.trim().length < 2) {
              return '워크샵 제목은 2글자 이상이어야 합니다';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _descriptionController,
          label: '워크샵 설명',
          hint: '워크샵에 대한 자세한 설명을 입력하세요',
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '워크샵 설명을 입력해주세요';
            }
            if (value.trim().length < 10) {
              return '워크샵 설명은 10글자 이상이어야 합니다';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 정보',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _priceController,
                label: '가격 (원)',
                hint: '0',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '가격을 입력해주세요';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return '올바른 가격을 입력해주세요';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextField(
                controller: _capacityController,
                label: '정원 (명)',
                hint: '1',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '정원을 입력해주세요';
                  }
                  final capacity = int.tryParse(value);
                  if (capacity == null || capacity < 1) {
                    return '1명 이상의 정원을 입력해주세요';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _tagsController,
          label: '태그',
          hint: '태그를 쉼표로 구분하여 입력하세요 (예: 요리, 베이킹, 초급)',
          validator: (value) {
            // Tags are optional, so no validation needed
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Consumer<WorkshopProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: provider.isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppButton(
                text: _isEditing ? '수정' : '등록',
                onPressed: provider.isLoading ? null : _submitForm,
                isLoading: provider.isLoading,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<WorkshopProvider>();
    
    // Parse tags
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final workshop = Workshop(
      id: _isEditing ? widget.workshop!.id : '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      capacity: int.parse(_capacityController.text),
      imageUrl: _currentImageUrl, // Will be updated if new image is selected
      tags: tags,
      createdAt: _isEditing ? widget.workshop!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await provider.updateWorkshop(workshop, imageFile: _selectedImage);
    } else {
      success = await provider.createWorkshop(workshop, imageFile: _selectedImage);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? '워크샵이 수정되었습니다' : '워크샵이 등록되었습니다'),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? '작업에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
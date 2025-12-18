import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fastapp/domain/entity/feed/report_type.dart';
import 'package:fastapp/domain/repository/feed/feed_repository.dart';
import 'package:fastapp/presentation/views/common/image_upload_grid.dart';
import 'package:fastapp/core/services/message_service.dart';

/// 举报页面 - 统一管理举报流程
class FeedReportPage extends StatefulWidget {
  final int targetType;
  final int targetId;

  const FeedReportPage({
    super.key,
    required this.targetType,
    required this.targetId,
  });

  @override
  State<FeedReportPage> createState() => _FeedReportPageState();
}

class _FeedReportPageState extends State<FeedReportPage> {
  final _feedRepository = GetIt.instance<FeedRepository>();
  final _descriptionController = TextEditingController();

  ReportReason? _selectedReason;
  List<String> _uploadedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '举报',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '请选择举报原因',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildReasonList(),

                  if (_selectedReason != null) ...[
                    const SizedBox(height: 32),
                    const Text(
                      '详细描述',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedReason!.needDetail
                          ? '请详细描述问题（必填）'
                          : '补充说明（选填）',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDescriptionInput(),
                    const SizedBox(height: 24),
                    ImageUploadGrid(
                      maxCount: 9,
                      onImagesChanged: (images) {
                        setState(() {
                          _uploadedImages = images;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (_selectedReason != null) _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildReasonList() {
    return Column(
      children: ReportReasons.reasons.map((reason) {
        final isSelected = _selectedReason == reason;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedReason = reason;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.red.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.red.shade300 : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    reason.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isSelected ? Colors.red.shade700 : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.red.shade600,
                    size: 22,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescriptionInput() {
    return TextField(
      controller: _descriptionController,
      maxLines: 6,
      maxLength: 500,
      decoration: InputDecoration(
        hintText: '请详细描述问题...',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black87, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '提交举报',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_selectedReason == null) return;

    final description = _descriptionController.text.trim();

    // 如果是必填详情的类型，检查是否填写
    if (_selectedReason!.needDetail && description.isEmpty) {
      MessageService.error('请填写详细描述');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _feedRepository.submitReport(
        targetType: widget.targetType,
        targetId: widget.targetId,
        reportType: _selectedReason!.type.value,
        content: description.isEmpty ? _selectedReason!.text : description,
        images: _uploadedImages.isNotEmpty ? _uploadedImages : null,
      );

      if (mounted) {
        Navigator.pop(context);
        MessageService.success('我们会尽快核实你的举报');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        MessageService.error('举报失败');
      }
    }
  }
}

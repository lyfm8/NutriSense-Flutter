import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/chat_message_dto.dart';
import '../../data/models/nutrient_dto.dart';
import '../../data/models/meal_log_request.dart';
import 'package:dio/dio.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  List<ChatMessageDto> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  int? _userId;

  final Map<String, String> _mealTypeNames = {
    'breakfast': 'Bữa sáng',
    'lunch': 'Bữa trưa',
    'snack': 'Bữa nhẹ',
    'dinner': 'Bữa tối',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _userId = await SessionManager.getUserId();
    if (_userId != null) {
      try {
        final history = await _apiService.getChatHistory(_userId!);
        if (mounted) {
          setState(() {
            _messages = history;
            _isLoading = false;
          });
          _scrollToBottom();
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // 1. GỬI TIN NHẮN CHAT BÌNH THƯỜNG
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _userId == null) return;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessageDto(role: 'user', content: text, createdAt: DateTime.now().toIso8601String()));
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await _apiService.sendMessage(ChatSendRequest(userId: _userId!, message: text));
      if (mounted) {
        setState(() {
          _messages.add(response);
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
          _messages.add(ChatMessageDto(role: 'assistant', content: 'Lỗi kết nối. Vui lòng thử lại!', createdAt: DateTime.now().toIso8601String()));
        });
      }
    }
  }

  // 2. CHỤP/CHỌN ẢNH -> PHÂN TÍCH -> HIỂN THỊ KHUNG PREVIEW
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null || _userId == null) return;

    setState(() {
      _messages.add(ChatMessageDto(role: 'user', content: '[Đã gửi một hình ảnh để phân tích]', createdAt: DateTime.now().toIso8601String()));
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final bytes = await image.readAsBytes();
      // Gọi API phân tích ảnh trả về List<NutrientDto>
      final items = await _apiService.analyzeImage(
        userId: _userId!,
        imageBytes: bytes,
        filename: image.name.isNotEmpty ? image.name : 'food_image.jpg',
      );

      setState(() => _isSending = false);

      if (items.isEmpty) {
        _addBotMessage("Xin lỗi, tôi không nhận ra món ăn nào trong ảnh.");
      } else {
        // Hiển thị khung popup chi tiết dinh dưỡng để người dùng lưu
        _showImageAnalysisResultDialog(items);
      }
    } catch (e) {
      setState(() => _isSending = false);
      _addBotMessage('Lỗi phân tích ảnh: Vui lòng thử lại sau.');
    }
  }

  // 3. DIALOG KHUNG CHI TIẾT DINH DƯỠNG CHO ẢNH
  void _showImageAnalysisResultDialog(List<NutrientDto> items) {
    String selectedMeal = 'lunch';
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Kết quả phân tích', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.blue600)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: AppColors.gray50,
                            elevation: 0,
                            shape: RoundedRectangleBorder(side: const BorderSide(color: AppColors.gray200), borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.foodName ?? 'Món ăn', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildNutrientBadge('Calo', '${item.calories ?? 0} kcal', AppColors.blue600),
                                      _buildNutrientBadge('Pro', '${item.proteinG ?? 0}g', AppColors.orange600),
                                      _buildNutrientBadge('Carb', '${item.carbsG ?? 0}g', AppColors.amber600),
                                      _buildNutrientBadge('Fat', '${item.fatG ?? 0}g', AppColors.rose600),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(alignment: Alignment.centerLeft, child: Text('Chọn bữa ăn để lưu:', style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedMeal,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _mealTypeNames.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                      onChanged: (val) => setDialogState(() => selectedMeal = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: isSaving ? null : () async {
                    setDialogState(() => isSaving = true);
                    try {
                      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

                      // Chuyển đổi NutrientDto sang NutrientLogItem
                      final logItems = items.map((i) => NutrientLogItem(
                        foodName: i.foodName,
                        calories: i.calories,
                        proteinG: i.proteinG,
                        carbsG: i.carbsG,
                        fatG: i.fatG,
                      )).toList();

                      final batchRequest = MealBatchLogRequest(
                        userId: _userId!,
                        date: today,
                        mealType: selectedMeal,
                        items: logItems,
                      );

                      await _apiService.logMealBatch(batchRequest);

                      if (mounted) {
                        Navigator.pop(ctx);
                        _addBotMessage('✅ Đã phân tích và thêm thành công vào ${_mealTypeNames[selectedMeal]} hôm nay. Bạn có thể kiểm tra ở màn hình Lịch sử.');
                      }
                    } catch (e) {
                      setDialogState(() => isSaving = false);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi lưu món ăn')));
                    }
                  },
                  child: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Thêm vào nhật ký', style: TextStyle(color: AppColors.white)),
                ),
              ],
            );
          }
      ),
    );
  }

  // 4. DIALOG NHẬP TEXT ĐỂ PHÂN TÍCH VÀ LƯU TRỰC TIẾP
  void _showTextLogDialog() {
    String selectedMeal = 'lunch';
    String userInput = '';
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Ghi chép món ăn (Text)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue600)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bạn đã ăn gì? (VD: 1 bát phở bò)'),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Nhập tên món ăn...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (val) => userInput = val,
                  ),
                  const SizedBox(height: 16),
                  const Text('Chọn bữa ăn:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedMeal,
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: _mealTypeNames.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                    onChanged: (val) => setDialogState(() => selectedMeal = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue600, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: isSaving ? null : () async {
                    if (userInput.trim().isEmpty) return;
                    setDialogState(() => isSaving = true);
                    try {
                      final request = MealLogRequest(
                        userId: _userId!,
                        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        mealType: selectedMeal,
                        rawInput: userInput.trim(),
                      );

                      final savedItem = await _apiService.logMeal(request);

                      if (mounted) {
                        Navigator.pop(ctx);
                        _addBotMessage('✅ Đã thêm "${savedItem.displayName}" (${savedItem.displayCalories} kcal) vào ${_mealTypeNames[selectedMeal]}.\nProtein: ${savedItem.proteinG}g | Carbs: ${savedItem.carbsG}g | Fat: ${savedItem.fatG}g');                      }
                    } on DioException catch (e) {
                      setDialogState(() => isSaving = false);
                      // Bắt mã 422 từ Backend trả về khi AI muốn hỏi thêm
                      if (e.response?.statusCode == 422) {
                        final responseData = e.response?.data;
                        if (responseData != null && responseData['status'] == 'ask_user') {
                          if (mounted) Navigator.pop(ctx);
                          _addBotMessage(responseData['question'] ?? 'Xin vui lòng cung cấp thêm chi tiết về món ăn.');
                        }
                      } else if (e.response?.statusCode == 429) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thao tác quá nhanh, vui lòng đợi 5 giây.')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi kết nối hệ thống.')));
                      }
                    } catch (e) {
                      setDialogState(() => isSaving = false);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi phân tích hoặc hệ thống quá tải.')));
                    }
                  },
                  child: isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Phân tích & Lưu', style: TextStyle(color: AppColors.white)),
                ),
              ],
            );
          }
      ),
    );
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessageDto(role: 'assistant', content: text, createdAt: DateTime.now().toIso8601String()));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Widget _buildNutrientBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue50,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.indigo600, AppColors.blue600], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        ),
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.white),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trợ lý AI', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Luôn sẵn sàng hỗ trợ bạn', style: TextStyle(color: AppColors.white.withOpacity(0.9), fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(child: Text('Chưa có tin nhắn nào.\nHãy hỏi AI hoặc phân tích bữa ăn!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg.content ?? '', msg.isFromUser);
              },
            ),
          ),
          if (_isSending)
            const Padding(padding: EdgeInsets.all(8.0), child: Row(children: [SizedBox(width: 16), SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 8), Text('AI đang phân tích...', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))])),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.blue600 : AppColors.white,
          borderRadius: BorderRadius.circular(16).copyWith(bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16), bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Text(text, style: TextStyle(color: isUser ? AppColors.white : AppColors.textPrimary, height: 1.5)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
      child: SafeArea(
        child: Column(
          children: [
            // Row chứa nút tiện ích mở rộng (Phân tích đồ ăn)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, color: AppColors.blue600, size: 18),
                  label: const Text('Chụp ảnh món ăn', style: TextStyle(color: AppColors.blue600)),
                ),
                TextButton.icon(
                  onPressed: _showTextLogDialog,
                  icon: const Icon(Icons.edit_note, color: AppColors.orange600, size: 18),
                  label: const Text('Nhập tên món ăn', style: TextStyle(color: AppColors.orange600)),
                ),
              ],
            ),
            const Divider(height: 1),
            // Row Chat mặc định
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.image, color: AppColors.textSecondary), onPressed: () => _pickImage(ImageSource.gallery)),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.gray200)),
                    child: TextField(
                      controller: _messageController,
                      maxLines: 4, minLines: 1,
                      decoration: const InputDecoration(hintText: 'Trò chuyện với AI...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    decoration: const BoxDecoration(color: AppColors.blue600, shape: BoxShape.circle),
                    child: IconButton(icon: const Icon(Icons.send, color: AppColors.white), onPressed: _isSending ? null : _sendMessage),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
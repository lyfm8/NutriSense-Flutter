
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/chat_message_dto.dart';

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
        debugPrint('[AiAssistant] Load history error: $e');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _userId == null) return;

    _messageController.clear();
    
    // Add user message to UI immediately
    final userMsg = ChatMessageDto(
      role: 'user',
      content: text,
      createdAt: DateTime.now().toIso8601String(),
    );
    
    setState(() {
      _messages.add(userMsg);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await _apiService.sendMessage(
        ChatSendRequest(userId: _userId!, message: text),
      );
      if (mounted) {
        setState(() {
          _messages.add(response);
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('[AiAssistant] Send message error: $e');
      if (mounted) {
        setState(() {
          _isSending = false;
          _messages.add(ChatMessageDto(
            role: 'assistant',
            content: 'Xin lỗi, tôi đang gặp sự cố kết nối. Vui lòng thử lại sau!',
            createdAt: DateTime.now().toIso8601String(),
          ));
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    if (_userId == null) return;

    setState(() {
      _messages.add(ChatMessageDto(
        role: 'user',
        content: '[Đã tải lên một hình ảnh]',
        createdAt: DateTime.now().toIso8601String(),
      ));
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final bytes = await image.readAsBytes();
      final items = await _apiService.analyzeImage(
        userId: _userId!,
        imageBytes: bytes,
        filename: image.name.isNotEmpty ? image.name : 'food_image.jpg',
      );
      
      String responseText = "";
      if (items.isEmpty) {
        responseText = "Xin lỗi, tôi không nhận ra món ăn nào trong ảnh.";
      } else {
        responseText = "Tôi nhận ra các món sau trong ảnh:\n";
        for (var item in items) {
          responseText += "- ${item.foodName}: ${item.calories} kcal, ${item.proteinG}g Protein, ${item.carbsG}g Carbs, ${item.fatG}g Fat\n";
        }
        responseText += "\nBạn muốn thêm (các) món này vào bữa ăn nào?";
      }

      if (mounted) {
        setState(() {
          _messages.add(ChatMessageDto(
            role: 'assistant',
            content: responseText.trim(),
            createdAt: DateTime.now().toIso8601String(),
          ));
          _isSending = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('[AiAssistant] Analyze image error: $e');
      if (mounted) {
        setState(() {
          _messages.add(ChatMessageDto(
            role: 'assistant',
            content: 'Xin lỗi, tôi gặp lỗi khi phân tích ảnh: $e',
            createdAt: DateTime.now().toIso8601String(),
          ));
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue50,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.indigo600, AppColors.blue600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có tin nhắn nào.\nHãy hỏi AI về dinh dưỡng hôm nay!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg.isFromUser;
                          return _buildChatBubble(msg.content ?? '', isUser);
                        },
                      ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('AI đang suy nghĩ...', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.blue600 : AppColors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? AppColors.white : AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.camera_alt, color: AppColors.textSecondary),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            IconButton(
              icon: const Icon(Icons.image, color: AppColors.textSecondary),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: 4,
                  minLines: 1,
                  decoration: const InputDecoration(
                    hintText: 'Hỏi AI...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.blue600,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: AppColors.white),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/chat_message_dto.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt; // THÊM DÒNG NÀY
import 'package:lottie/lottie.dart';
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _apiService = ApiService();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late stt.SpeechToText _speechToText;
  bool _isListening = false;

  List<ChatMessageDto> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _speechToText = stt.SpeechToText(); // Khởi tạo
  }

  // --- HÀM XỬ LÝ NHẬN DIỆN GIỌNG NÓI ---
  void _listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (val) => debugPrint('Lỗi Voice: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (val) {
            setState(() {
              _chatController.text = val.recognizedWords;
            });
          },
          localeId: 'vi_VN', // Tiếng Việt
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  Future<void> _loadChatHistory() async {
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

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _userId == null) return;
    _chatController.clear();

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
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // HEADER (Đã khôi phục lại như cũ)
          Container(
            padding: const EdgeInsets.only(top: 48, left: 16, right: 16, bottom: 16),
            color: const Color(0xFF2563EB), // Màu xanh chủ đạo
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('Trợ lý AI', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 48, top: 4),
                  child: Text('Hỏi tôi bất cứ điều gì về sức khỏe & dinh dưỡng', style: TextStyle(color: Colors.white70, fontSize: 14)),
                )
              ],
            ),
          ),

          // CHAT BODY
          Expanded(
            child: Stack(
              children: [
                // Hoạt ảnh Lottie thay thế icon tĩnh
                Center(
                  child: Opacity(
                    opacity: 0.2, // Tăng opacity một chút để dễ nhìn hơn
                    child: Lottie.asset(
                      'assets/animations/chatbot.json',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                      repeat: true, // Cho phép hoạt ảnh lặp lại vô tận
                    ),
                  ),
                ),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildChatBubble(msg.content ?? '', msg.isFromUser);
                    },
                  ),
              ],
            ),
          ),

          if (_isSending)
            const Padding(padding: EdgeInsets.all(8), child: Text('AI đang phản hồi...', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))),

          // INPUT ROW (Đã cập nhật nút Mic ở đây)
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    maxLines: 4, minLines: 1,
                    decoration: const InputDecoration(hintText: 'Hỏi AI bất kỳ điều gì...', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                  ),
                ),
                // NÚT MIC ĐƯỢC CẬP NHẬT
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : AppColors.blue600),
                  onPressed: _listen,
                ),
                Container(
                  decoration: const BoxDecoration(color: AppColors.blue600, shape: BoxShape.circle),
                  child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _isSending ? null : _sendMessage),
                ),
              ],
            ),
          )
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
          color: isUser ? const Color(0xFF2563EB) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
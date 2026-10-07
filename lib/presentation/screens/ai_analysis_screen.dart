import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/theme/app_colors.dart';
import '../../core/utils/session_manager.dart';
import '../../data/api/api_service.dart';
import '../../data/models/nutrient_dto.dart';
import '../../data/models/meal_log_request.dart';
import '../../data/models/ai_analyze_result.dart'; // Import model mới

class AiAnalysisScreen extends StatefulWidget {
  const AiAnalysisScreen({super.key});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  final _apiService = ApiService();
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  bool _isLoading = false;
  int? _userId;

  List<NutrientDto>? _imageResults;

  // Biến lưu trữ kết quả phân tích tạm thời để user chỉnh sửa
  FoodItem? _analyzedFoodItem;
  // Bản gốc (theo gram AI ước lượng) làm mốc để scale mọi chất khi user đổi gram
  FoodItem? _baseItem;
  double _baseWeight = 100;

  final Map<String, String> _mealTypeNames = {
    'breakfast': 'Bữa sáng',
    'lunch': 'Bữa trưa',
    'snack': 'Bữa nhẹ',
    'dinner': 'Bữa tối',
  };

  @override
  void initState() {
    super.initState();
    _loadUser();
    _speechToText = stt.SpeechToText();
  }

  Future<void> _loadUser() async {
    _userId = await SessionManager.getUserId();
  }

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
              _inputController.text = val.recognizedWords;
            });
          },
          localeId: 'vi_VN',
        );
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  Future<void> _processText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _userId == null) return;

    setState(() {
      _isLoading = true;
      _analyzedFoodItem = null;
      _imageResults = null;
    });
    FocusScope.of(context).unfocus();

    try {
      final result = await _apiService.analyzeText(userId: _userId!, userInput: text);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result.isAskUser) {
            _showBotQuestionDialog(result.question ?? 'Hãy cho tôi biết thêm chi tiết.');
          } else if (result.foodItems != null && result.foodItems!.isNotEmpty) {
            _analyzedFoodItem = result.foodItems!.first;

            double initialWeight = _analyzedFoodItem!.servingSize ?? 100.0;
            _weightController.text = initialWeight.toStringAsFixed(0);

            _baseWeight = initialWeight > 0 ? initialWeight : 100.0;
            _baseItem = _analyzedFoodItem!.copy();
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi phân tích từ AI.')));
    }
  }

  void _recalculateNutrients(String weightStr) {
    final weight = double.tryParse(weightStr);
    if (weight == null || weight <= 0 || _analyzedFoodItem == null || _baseItem == null) return;

    final r = weight / _baseWeight;
    double? sc(double? v) => v == null ? null : v * r;

    setState(() {
      final f = _analyzedFoodItem!;
      final b = _baseItem!;
      f.servingSize = weight;
      f.calories = sc(b.calories);
      f.proteinG = sc(b.proteinG);
      f.carbsG = sc(b.carbsG);
      f.fatG = sc(b.fatG);
      f.fiberG = sc(b.fiberG);
      f.vitaminAMcg = sc(b.vitaminAMcg);
      f.vitaminB12Mcg = sc(b.vitaminB12Mcg);
      f.vitaminCMg = sc(b.vitaminCMg);
      f.vitaminDMcg = sc(b.vitaminDMcg);
      f.ironMg = sc(b.ironMg);
      f.calciumMg = sc(b.calciumMg);
      f.potassiumMg = sc(b.potassiumMg);
    });
  }

  Future<void> _saveAnalyzedItemToJournal() async {
    if (_analyzedFoodItem == null || _userId == null) return;

    final selectedMeal = await _showMealSelectionDialog();
    if (selectedMeal == null) return;

    setState(() => _isLoading = true);

    try {
      await _apiService.saveMealItemDirectly(
        userId: _userId!,
        mealType: selectedMeal,
        foodItem: _analyzedFoodItem!,
        rawInput: _inputController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _analyzedFoodItem = null;
        });
        _inputController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Đã thêm vào ${_mealTypeNames[selectedMeal]} thành công!'))
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi lưu vào nhật ký.')));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null || _userId == null) return;

    setState(() {
      _isLoading = true;
      _analyzedFoodItem = null;
      _imageResults = null;
    });

    try {
      final bytes = await image.readAsBytes();
      final items = await _apiService.analyzeImage(
        userId: _userId!,
        imageBytes: bytes,
        filename: image.name.isNotEmpty ? image.name : 'food_image.jpg',
      );

      if (mounted) {
        setState(() {
          _imageResults = items;
          _isLoading = false;
        });
        if (items.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không nhận diện được món ăn nào trong ảnh.')));
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi phân tích ảnh.')));
    }
  }

  Future<void> _saveImageResults() async {
    if (_imageResults == null || _imageResults!.isEmpty || _userId == null) return;

    final selectedMeal = await _showMealSelectionDialog();
    if (selectedMeal == null) return;

    setState(() => _isLoading = true);

    try {
      final logItems = _imageResults!
          .map((i) => NutrientLogItem.fromNutrient(i, source: 'image'))
          .toList();

      final batchRequest = MealBatchLogRequest(
        userId: _userId!,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        mealType: selectedMeal,
        items: logItems,
      );

      await _apiService.logMealBatch(batchRequest);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _imageResults = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Đã thêm vào ${_mealTypeNames[selectedMeal]}')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi lưu món ăn')));
    }
  }

  Future<String?> _showMealSelectionDialog() {
    String selectedMeal = 'lunch';
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Chọn bữa ăn', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.blue600)),
              content: DropdownButtonFormField<String>(
                value: selectedMeal,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: _mealTypeNames.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: (val) => setDialogState(() => selectedMeal = val!),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Hủy')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue600),
                  onPressed: () => Navigator.pop(ctx, selectedMeal),
                  child: const Text('Tiếp tục', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
      ),
    );
  }

  void _showBotQuestionDialog(String question) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.orange600),
            SizedBox(width: 8),
            Text('AI cần làm rõ', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(question),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue600),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đã hiểu', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.indigo600, AppColors.blue600], begin: Alignment.topLeft, end: Alignment.bottomRight),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white),
                      SizedBox(width: 8),
                      Text('AI Phân Tích', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text('Nhập món ăn hoặc chụp ảnh để phân tích', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // INPUT AREA
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),                      child: Column(
                        children: [
                          TextField(
                            controller: _inputController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Hôm nay bạn ăn gì?',
                              filled: true,
                              fillColor: isDark ? Theme.of(context).scaffoldBackgroundColor : AppColors.gray50,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildIconButton(Icons.camera_alt, () => _pickImage(ImageSource.camera)),
                              const SizedBox(width: 8),
                              _buildIconButton(Icons.image, () => _pickImage(ImageSource.gallery)),
                              const SizedBox(width: 8),
                              _buildIconButton(
                                _isListening ? Icons.mic : Icons.mic_none,
                                _listen,
                                iconColor: _isListening ? Colors.red : AppColors.blue600,
                                bgColor: _isListening ? Colors.red.withOpacity(0.1) : null,
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue600,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _isLoading ? null : _processText,
                                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                                label: const Text('Phân tích', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // RESULT AREA
                    if (_isLoading)
                      _buildLoadingCard()
                    else if (_analyzedFoodItem != null)
                      _buildAnalyzedResultCard()
                    else if (_imageResults != null && _imageResults!.isNotEmpty)
                        Column(
                          children: [
                            ..._imageResults!.map((item) => _buildResultCard(
                              name: item.foodName ?? 'Món ăn',
                              rawInput: 'Phân tích từ ảnh',
                              calories: item.calories ?? 0,
                              protein: item.proteinG,
                              carbs: item.carbsG,
                              fat: item.fatG,
                            )),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue100, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                onPressed: _saveImageResults,
                                child: const Text('Thêm tất cả vào nhật ký', style: TextStyle(color: AppColors.blue600, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        )
                      else
                        _buildEmptyState(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tách riêng Card hiển thị kết quả phân tích có thể chỉnh sửa
  Widget _buildAnalyzedResultCard() {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(_analyzedFoodItem!.name ?? 'Món ăn', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.blue600, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Text((_analyzedFoodItem!.calories ?? 0).toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('kcal', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Text('Khẩu phần (g): ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    onChanged: _recalculateNutrients,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const Text(' g', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                _buildMacroBox('Protein', _analyzedFoodItem!.proteinG, AppColors.orange600),
                const SizedBox(width: 8),
                _buildMacroBox('Carbs', _analyzedFoodItem!.carbsG, AppColors.amber600),
                const SizedBox(width: 8),
                _buildMacroBox('Chất béo', _analyzedFoodItem!.fatG, AppColors.red600),
              ],
            ),

            if (_analyzedFoodItem!.source == 'gemini_ai')
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Text('Dữ liệu do AI ước lượng', style: TextStyle(fontSize: 12, color: Colors.orange, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue100,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveAnalyzedItemToJournal,
                child: const Text('Lưu vào nhật ký', style: TextStyle(color: AppColors.blue600, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {Color? iconColor, Color? bgColor}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: bgColor ?? Colors.transparent,
            border: Border.all(color: AppColors.blue100),
            borderRadius: BorderRadius.circular(12)
        ),
        child: Icon(icon, color: iconColor ?? AppColors.blue600),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.blue600),
            SizedBox(width: 16),
            Text('Đang phân tích bằng AI...', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Icon(Icons.smart_toy_outlined, size: 64, color: AppColors.blue600.withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text('Chưa có phân tích nào', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Nhập món ăn hoặc chụp ảnh để bắt đầu', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildResultCard({required String name, String? rawInput, required double calories, double? protein, double? carbs, double? fat}) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.blue600, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Text(calories.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const Text('kcal', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
            if (rawInput != null && rawInput.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).scaffoldBackgroundColor
                        : AppColors.gray50,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Text('"$rawInput"', style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMacroBox('Protein', protein, AppColors.orange600),
                const SizedBox(width: 8),
                _buildMacroBox('Carbs', carbs, AppColors.amber600),
                const SizedBox(width: 8),
                _buildMacroBox('Chất béo', fat, AppColors.red600),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBox(String label, double? value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text((value ?? 0).toStringAsFixed(1), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                Text('g', style: TextStyle(fontSize: 12, color: color)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
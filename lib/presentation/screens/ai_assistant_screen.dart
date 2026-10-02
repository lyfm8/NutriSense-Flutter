import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(top: 48, left: 20, right: 20, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.indigo600, AppColors.blue600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Trợ lý AI',
                        style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nhập món ăn hoặc chụp ảnh để phân tích',
                    style: TextStyle(color: AppColors.white.withOpacity(0.9), fontSize: 14),
                  ),
                ],
              ),
            ),

            // Input Area
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.white,
              child: Column(
                children: [
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Hôm nay bạn ăn gì?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.gray200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.gray200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.blue600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildIconButton(Icons.camera_alt),
                      const SizedBox(width: 8),
                      _buildIconButton(Icons.image),
                      const SizedBox(width: 8),
                      _buildIconButton(Icons.mic),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.send, color: AppColors.white),
                        label: const Text('Gửi', style: TextStyle(color: AppColors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue600,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Results Area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: AppColors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bữa sáng',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.orange600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: const [
                                Text('450', style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                Text('kcal', style: TextStyle(color: AppColors.white, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gray50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: const Text(
                          '"1 bát phở bò, 1 cốc cà phê sữa đá"',
                          style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildNutrientMacro('Protein', '20', AppColors.orange600),
                          const SizedBox(width: 8),
                          _buildNutrientMacro('Carbs', '50', AppColors.amber600),
                          const SizedBox(width: 8),
                          _buildNutrientMacro('Chất béo', '15', AppColors.red),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Vi chất dinh dưỡng (ước tính):', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      const Text('• Vitamin C: 12 mg\n• Canxi: 150 mg', style: TextStyle(color: AppColors.textPrimary)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue100,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Thêm vào nhật ký', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.blue600),
        onPressed: () {},
      ),
    );
  }

  Widget _buildNutrientMacro(String name, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
                Text('g', style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

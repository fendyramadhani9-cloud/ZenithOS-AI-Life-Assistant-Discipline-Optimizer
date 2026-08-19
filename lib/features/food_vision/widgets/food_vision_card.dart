import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../models/meal_nutrition_entry.dart';
import '../services/food_vision_service.dart';
import 'macro_ring_widget.dart';

class FoodVisionCard extends StatefulWidget {
  const FoodVisionCard({super.key});

  @override
  State<FoodVisionCard> createState() => _FoodVisionCardState();
}

class _FoodVisionCardState extends State<FoodVisionCard> {
  final FoodVisionService _service = FoodVisionService();
  bool _isAnalyzing = false;
  MealNutritionEntry? _latestScan;
  String? _errorMessage;

  Future<void> _pickAndScanPlate() async {
    setState(() {
      _errorMessage = null;
    });

    final bytes = await _service.pickMealImage();
    if (bytes == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final scanResult = await _service.scanPlate(bytes);
      setState(() {
        _latestScan = scanResult;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCalories = _service.getTodayTotalCalories();
    final totalProtein = _service.getTodayTotalProtein();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.nutritionAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.camera,
                      color: AppColors.nutritionAccent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Smart Food Vision', style: AppTypography.h3),
                      Text(
                        'Deficit Tracker & Macro Estimation',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _isAnalyzing ? null : _pickAndScanPlate,
                icon: const Icon(LucideIcons.uploadCloud, size: 14),
                label: const Text('Scan Plate'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Macro & Calorie Ring Tracker
          MacroRingWidget(
            currentCalories: totalCalories > 0 ? totalCalories : 1420,
            targetCalories: 2100,
            currentProtein: totalProtein > 0 ? totalProtein : 128.0,
            targetProtein: 160.0,
          ),
          const SizedBox(height: 14),

          // Image Scanning / Preview State
          if (_isAnalyzing)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.nutritionAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Multimodal Vision Active',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Estimating calories, protein, carbs & fats from plate image...',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningCutoff.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warningCutoff.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 16,
                    color: AppColors.warningCutoff,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warningCutoff,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Latest Scan Breakdown Card
          if (_latestScan != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.nutritionAccent.withOpacity(0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _latestScan!.foodName,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_latestScan!.calories} kcal',
                        style: AppTypography.timeStamp,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'P: ${_latestScan!.proteinGrams}g',
                        style: AppTypography.caption,
                      ),
                      Text(
                        'C: ${_latestScan!.carbsGrams}g',
                        style: AppTypography.caption,
                      ),
                      Text(
                        'F: ${_latestScan!.fatGrams}g',
                        style: AppTypography.caption,
                      ),
                      Text(
                        'Score: ${_latestScan!.healthScore}/10',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.nutritionAccent,
                        ),
                      ),
                    ],
                  ),
                  if (_latestScan!.insights.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      _latestScan!.insights,
                      style: AppTypography.caption.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

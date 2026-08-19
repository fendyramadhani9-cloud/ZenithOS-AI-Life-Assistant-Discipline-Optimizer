import 'package:flutter_test/flutter_test.dart';
import 'package:zenith_os/core/constants/app_colors.dart';

void main() {
  test('ZenithOS Theme & Palette Smoke Test', () {
    expect(AppColors.background.value, 0xFF0A0D14);
    expect(AppColors.surface.value, 0xFF121722);
    expect(AppColors.accentPrimary.value, 0xFF38BDF8);
  });
}

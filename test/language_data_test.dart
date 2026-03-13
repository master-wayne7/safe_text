import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safe_text/src/safe_text_filter.dart';
import 'package:safe_text/src/models/language.dart';
import 'package:safe_text/constants/badwords.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Language Data Integrity Tests', () {
    test('Kannada data moved to kn.txt and is reachable', () async {
      await SafeTextFilter.init(languages: [Language.kannada]);
      // 'ಅತ್ಯಾಚಾರ' (Atthyachara - rape) is one of the Kannada words
      expect(await SafeTextFilter.containsBadWord(text: 'ಅತ್ಯಾಚಾರ'), true);
      // Ensure it doesn't match single characters often found in truncated lists
      expect(await SafeTextFilter.containsBadWord(text: 'ಅ'), false);
    });

    test('Khmer data in kh.txt is replaced with real content', () async {
      await SafeTextFilter.init(languages: [Language.khmer]);
      // 'ចុយ' (Choy - fuck) is one of the new Khmer words
      expect(await SafeTextFilter.containsBadWord(text: 'ចុយ'), true);
      // Ensure the old Kannada word is no longer in kh.txt
      expect(await SafeTextFilter.containsBadWord(text: 'ಅತ್ಯಾಚಾರ'), false);
    });

    test('Arabic data has no single-character tokens', () async {
      await SafeTextFilter.init(languages: [Language.arabic]);
      expect(await SafeTextFilter.containsBadWord(text: 'أ'), false);
      expect(await SafeTextFilter.containsBadWord(text: 'ا'), false);
    });

    test('Persian data has no single-character tokens', () async {
      await SafeTextFilter.init(languages: [Language.persian]);
      expect(await SafeTextFilter.containsBadWord(text: 'ب'), false);
      expect(await SafeTextFilter.containsBadWord(text: 'ی'), false);
    });

    test('Italian data encoding artifacts are removed', () async {
      await SafeTextFilter.init(languages: [Language.italian]);
      expect(
          await SafeTextFilter.containsBadWord(
              text: 'che te pozzino ammazzãƒâ'),
          false);
      expect(await SafeTextFilter.containsBadWord(text: 'fare unaš'), false);
    });

    test('Spanish data English UI terms are removed', () async {
      await SafeTextFilter.init(languages: [Language.spanish]);
      expect(
          await SafeTextFilter.containsBadWord(text: 'contact github'), false);
      expect(
          await SafeTextFilter.containsBadWord(text: 'conversation 0'), false);
      expect(await SafeTextFilter.containsBadWord(text: 'file filter'), false);
    });

    test('Estonian Mojibake is fixed', () async {
      await SafeTextFilter.init(languages: [Language.estonian]);
      expect(await SafeTextFilter.containsBadWord(text: 'minge põrgu'), true);
      expect(await SafeTextFilter.containsBadWord(text: 'minge pãµrgu'), false);
      expect(await SafeTextFilter.containsBadWord(text: 'sul on väike munn'),
          true);
    });

    test('Czech neutral words are removed', () async {
      debugPrint(
          'DEBUG: badWords contains bodnutí: ${badWords.contains('bodnutí')}');
      debugPrint('DEBUG: badWords length: ${badWords.length}');
      await SafeTextFilter.init(languages: [Language.czech]);
      final isBad = await SafeTextFilter.containsBadWord(text: 'bodnutí');
      final filtered = SafeTextFilter.filterText(text: 'bodnutí');
      debugPrint('DEBUG: Czech bodnutí: isBad=$isBad, filtered=$filtered');
      expect(isBad, false);
      expect(await SafeTextFilter.containsBadWord(text: 'děloha'), false);
      expect(await SafeTextFilter.containsBadWord(text: 'knoflík'), false);
      expect(await SafeTextFilter.containsBadWord(text: 'peklo'), false);
    });

    test('Hindi/Japanese/Korean/Chinese neutral words are removed', () async {
      await SafeTextFilter.init(languages: [Language.hindi]);
      expect(await SafeTextFilter.containsBadWord(text: 'सबसे अच्छा'), false);
      expect(await SafeTextFilter.containsBadWord(text: 'साहस'), false);

      await SafeTextFilter.init(languages: [Language.japanese]);
      expect(await SafeTextFilter.containsBadWord(text: '女の子'), false);
      expect(await SafeTextFilter.containsBadWord(text: 'のどか'), false);

      await SafeTextFilter.init(languages: [Language.korean]);
      expect(await SafeTextFilter.containsBadWord(text: '개발자'), false);
      expect(await SafeTextFilter.containsBadWord(text: '대상'), false);

      await SafeTextFilter.init(languages: [Language.chinese]);
      expect(await SafeTextFilter.containsBadWord(text: '系统'), false);
      expect(await SafeTextFilter.containsBadWord(text: '官方'), false);
    });
  });
}

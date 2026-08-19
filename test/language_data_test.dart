import 'package:safe_text/constants/badwords.dart';
import 'package:safe_text/src/models/language.dart';
import 'package:safe_text/src/safe_text_filter.dart';
import 'package:test/test.dart';

void main() {
  group('Language Data Integrity Tests', () {
    test('Kannada data moved to kn.txt and is reachable', () async {
      SafeTextFilter.init(languages: [Language.kannada]);
      // 'ಅತ್ಯಾಚಾರ' (Atthyachara - rape) is one of the Kannada words
      expect(SafeTextFilter.containsBadWord(text: 'ಅತ್ಯಾಚಾರ'), true);
      // Ensure it doesn't match single characters often found in truncated lists
      expect(SafeTextFilter.containsBadWord(text: 'ಅ'), false);
    });

    test('Khmer data in kh.txt is replaced with real content', () async {
      SafeTextFilter.init(languages: [Language.khmer]);
      // 'ចុយ' (Choy - fuck) is one of the new Khmer words
      expect(SafeTextFilter.containsBadWord(text: 'ចុយ'), true);
      // Ensure the old Kannada word is no longer in kh.txt
      expect(SafeTextFilter.containsBadWord(text: 'ಅತ್ಯಾಚಾರ'), false);
    });

    test('Arabic data has no single-character tokens', () async {
      SafeTextFilter.init(languages: [Language.arabic]);
      expect(SafeTextFilter.containsBadWord(text: 'أ'), false);
      expect(SafeTextFilter.containsBadWord(text: 'ا'), false);
    });

    test('Persian data has no single-character tokens', () async {
      SafeTextFilter.init(languages: [Language.persian]);
      expect(SafeTextFilter.containsBadWord(text: 'ب'), false);
      expect(SafeTextFilter.containsBadWord(text: 'ی'), false);
    });

    test('Italian data encoding artifacts are removed', () async {
      SafeTextFilter.init(languages: [Language.italian]);
      expect(SafeTextFilter.containsBadWord(text: 'che te pozzino ammazzãƒâ'),
          false);
      expect(SafeTextFilter.containsBadWord(text: 'fare unaš'), false);
    });

    test('Spanish data English UI terms are removed', () async {
      SafeTextFilter.init(languages: [Language.spanish]);
      expect(SafeTextFilter.containsBadWord(text: 'contact github'), false);
      expect(SafeTextFilter.containsBadWord(text: 'conversation 0'), false);
      expect(SafeTextFilter.containsBadWord(text: 'file filter'), false);
    });

    test('Estonian Mojibake is fixed', () async {
      SafeTextFilter.init(languages: [Language.estonian]);
      expect(SafeTextFilter.containsBadWord(text: 'minge põrgu'), true);
      expect(SafeTextFilter.containsBadWord(text: 'minge pãµrgu'), false);
      expect(SafeTextFilter.containsBadWord(text: 'sul on väike munn'), true);
    });

    test('Czech neutral words are removed', () async {
      print(
          'DEBUG: badWords contains bodnutí: ${badWords.contains('bodnutí')}');
      print('DEBUG: badWords length: ${badWords.length}');
      SafeTextFilter.init(languages: [Language.czech]);
      final isBad = SafeTextFilter.containsBadWord(text: 'bodnutí');
      final filtered = SafeTextFilter.filterText(text: 'bodnutí');
      print('DEBUG: Czech bodnutí: isBad=$isBad, filtered=$filtered');
      expect(isBad, false);
      expect(SafeTextFilter.containsBadWord(text: 'děloha'), false);
      expect(SafeTextFilter.containsBadWord(text: 'knoflík'), false);
      expect(SafeTextFilter.containsBadWord(text: 'peklo'), false);
    });

    test('Hindi/Japanese/Korean/Chinese neutral words are removed', () async {
      SafeTextFilter.init(languages: [Language.hindi]);
      expect(SafeTextFilter.containsBadWord(text: 'सबसे अच्छा'), false);
      expect(SafeTextFilter.containsBadWord(text: 'साहस'), false);

      SafeTextFilter.init(languages: [Language.japanese]);
      expect(SafeTextFilter.containsBadWord(text: '女の子'), false);
      expect(SafeTextFilter.containsBadWord(text: 'のどか'), false);

      SafeTextFilter.init(languages: [Language.korean]);
      expect(SafeTextFilter.containsBadWord(text: '개발자'), false);
      expect(SafeTextFilter.containsBadWord(text: '대상'), false);

      SafeTextFilter.init(languages: [Language.chinese]);
      expect(SafeTextFilter.containsBadWord(text: '系统'), false);
      expect(SafeTextFilter.containsBadWord(text: '官方'), false);
    });
  });
}

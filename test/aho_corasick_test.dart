import 'package:flutter_test/flutter_test.dart';
import 'package:safe_text/src/aho_corasick.dart';

void main() {
  group('AhoCorasick Unicode Search', () {
    late AhoCorasick ac;

    setUp(() {
      ac = AhoCorasick();
    });

    test('finds basic ASCII words', () {
      ac.addWord('apple');
      ac.addWord('banana');
      ac.buildFailureLinks();

      final matches = ac.search('I like apple and banana');

      // 'apple' ends at rune index 11
      // 'banana' ends at rune index 22
      expect(matches[11], contains('apple'));
      expect(matches[22], contains('banana'));
    });

    test('finds words with non-BMP characters (emojis)', () {
      // 💩 is U+1F4A9
      // 🖕 is U+1F595
      ac.addWord('💩');
      ac.addWord('🖕');
      ac.buildFailureLinks();

      final text = 'You are a 💩 and a 🖕';
      final matches = ac.search(text);

      // Rune indices:
      // Y(0) o(1) u(2)  (3) a(4) r(5) e(6)  (7) a(8)  (9) 💩(10)  (11) a(12) n(13) d(14)  (15) a(16)  (17) 🖕(18)

      expect(matches.containsKey(10), true);
      expect(matches[10], contains('💩'));

      expect(matches.containsKey(18), true);
      expect(matches[18], contains('🖕'));
    });

    test('handles mixed emojis and text', () {
      ac.addWord('bad💩');
      ac.addWord('word');
      ac.buildFailureLinks();

      final text = 'This is a bad💩 word';
      final matches = ac.search(text);

      // bad💩 ends at rune index 13
      // word ends at rune index 18
      expect(matches[13], contains('bad💩'));
      expect(matches[18], contains('word'));
    });

    test('case-insensitive search with Unicode', () {
      ac.addWord('💩');
      ac.buildFailureLinks();

      // Note: most emojis don't have case, but this tests the pipeline
      final matches = ac.search('POOP 💩');
      expect(matches[5], contains('💩'));
    });

    test('handles overlapping matches with runes', () {
      ac.addWord('ab');
      ac.addWord('abc');
      ac.buildFailureLinks();

      final matches = ac.search('abcd');
      expect(matches[1], contains('ab'));
      expect(matches[2], contains('abc'));
    });
  });
}

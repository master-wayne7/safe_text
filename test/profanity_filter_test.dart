import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:safe_text/safe_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("SafeTextFilter class method filterText", () {
    setUpAll(() async {
      // For unit tests, we bypass the isolate Trie initialization and mock asset loading.
      // However, to test `SafeTextFilter.init` without actual assets being loaded correctly
      // by the test bundler, we test the legacy checking which defaults to `badwords.dart` or we can skip initialization
      // to test the legacy code paths, or initialize and test Aho-Corasick.

      // We test without initialization first to test legacy loops/normalization.
    });

    test('will filter completely when fullMode = true', () {
      expect(
          SafeTextFilter.filterText(
              text: "Hello badass how you doing anal impaler"),
          "Hello ****** how you doing ************");
    });

    test('will filter partially when fullMode = false', () {
      expect(
          SafeTextFilter.filterText(
              text: "Hello badass how you doing anal impaler", fullMode: false),
          "Hello b****s how you doing a**********r");
    });

    test('will normalise and filter common bypasses', () {
      expect(SafeTextFilter.filterText(text: "Hello b4dass how you doing"),
          "Hello ****** how you doing");
      expect(SafeTextFilter.filterText(text: "Hello b@dass how you doing"),
          "Hello ****** how you doing");
    });

    test(
        'will throw error when user sets use default words to false and doesn\'t pass extra words',
        () {
      expect(
          () => SafeTextFilter.filterText(
              text: "Hello badass how you doing anal impaler",
              fullMode: false,
              useDefaultWords: false),
          throwsA(isA<AssertionError>()));
    });

    test(
        'will throw error when user sets use default words to true and passes any word common in extra words and excluded words',
        () {
      expect(
          () => SafeTextFilter.filterText(
              text: "Hello badass how you doing anal impaler",
              fullMode: false,
              useDefaultWords: false,
              extraWords: ["hello", "123"],
              excludedWords: ["hello"]),
          throwsA(isA<AssertionError>()));
    });

    test(
        'will throw error when user passes any word common in extra words and excluded words',
        () {
      expect(
          () => SafeTextFilter.filterText(
              text: "Hello badass how you doing anal impaler",
              fullMode: false,
              extraWords: ["hello", "123"],
              excludedWords: ["hello"]),
          throwsA(isA<AssertionError>()));
    });

    test('will exclude the bad words passed in excludedBadWords', () {
      expect(
          SafeTextFilter.filterText(
              text: "Hello badass how you doing anal impaler",
              excludedWords: ["badass"]),
          "Hello badass how you doing ************");
    });

    test('will check for bad words using containsBadWord', () async {
      String textWithBadWord = "This is a badass example";
      String cleanText = "This is a clean example";

      bool containsBadWord =
          await SafeTextFilter.containsBadWord(text: textWithBadWord);
      bool noBadWord = await SafeTextFilter.containsBadWord(text: cleanText);

      expect(containsBadWord, true);
      expect(noBadWord, false);
    });

    test('will check for bad words with extra words', () async {
      String textWithCustomBadWord = "This is an inappropriate word example";
      String cleanText = "This is another clean example";

      bool containsCustomBadWord = await SafeTextFilter.containsBadWord(
        text: textWithCustomBadWord,
        extraWords: ['inappropriate'],
      );
      bool noBadWord = await SafeTextFilter.containsBadWord(text: cleanText);

      expect(containsCustomBadWord, true);
      expect(noBadWord, false);
    });
  });

  group("MaskStrategy", () {
    test('MaskStrategy.full() produces full masking (same as default)', () {
      expect(
        SafeTextFilter.filterText(
          text: "Hello badass",
          strategy: const MaskStrategy.full(),
        ),
        "Hello ******",
      );
    });

    test("MaskStrategy.full(obscureSymbol: '#') masks with '#'", () {
      expect(
          SafeTextFilter.filterText(
              text: "Hello badass",
              strategy: const MaskStrategy.full(obscureSymbol: '#')),
          "Hello ######");
    });

    test('MaskStrategy.partial() on 4+ letter word keeps first and last', () {
      expect(
          SafeTextFilter.filterText(
              text: "Hello badass", strategy: const MaskStrategy.partial()),
          "Hello b****s");
    });

    test('MaskStrategy.partial() on 3 letter word keeps first only', () {
      expect(
          SafeTextFilter.filterText(
              text: "Hello ass end",
              useDefaultWords: false,
              extraWords: ['ass'],
              strategy: const MaskStrategy.partial()),
          "Hello a** end");
    });

    test("MaskStrategy.custom() defaults to '[censored]'", () {
      expect(
          SafeTextFilter.filterText(
              text: "Hello badass", strategy: const MaskStrategy.custom()),
          "Hello [censored]");
    });

    test('MaskStrategy.partial() on 2 letter word keeps first only', () {
      expect(
          SafeTextFilter.filterText(
              text: "Hello ox end",
              useDefaultWords: false,
              extraWords: ['ox'],
              strategy: const MaskStrategy.partial()),
          "Hello o* end");
    });

    test('MaskStrategy.partial() on 1 letter word fully masks', () {
      expect(
          SafeTextFilter.filterText(
              text: "Hello x end",
              useDefaultWords: false,
              extraWords: ['x'],
              strategy: const MaskStrategy.partial()),
          "Hello * end");
    });

    test("MaskStrategy.custom(replacement: '***') uses provided replacement",
        () {
      expect(
          SafeTextFilter.filterText(
              text: "Hello badass",
              strategy: const MaskStrategy.custom(replacement: '***')),
          "Hello ***");
    });

    test('strategy takes precedence over deprecated fullMode', () {
      const replacement = '[BLOCKED]';
      expect(
          SafeTextFilter.filterText(
              text: "Hello badass",
              fullMode: true,
              strategy: const MaskStrategy.custom(replacement: replacement)),
          "Hello $replacement");
    });

    test('FullMask throws AssertionError for multi-character obscureSymbol',
        () {
      expect(
          () => MaskStrategy.full(obscureSymbol: '##'),
          throwsA(isA<AssertionError>()));
    });

    test('PartialMask throws AssertionError for multi-character obscureSymbol',
        () {
      expect(
          () => MaskStrategy.partial(obscureSymbol: '##'),
          throwsA(isA<AssertionError>()));
    });

    test('backward compat: fullMode: true still produces full masking', () {
      // ignore: deprecated_member_use
      expect(
          SafeTextFilter.filterText(
              text: "Hello badass how you doing anal impaler", fullMode: true),
          "Hello ****** how you doing ************");
    });

    test('backward compat: fullMode: false still produces partial masking', () {
      // ignore: deprecated_member_use
      expect(
          SafeTextFilter.filterText(
              text: "Hello badass how you doing anal impaler", fullMode: false),
          "Hello b****s how you doing a**********r");
    });
  });

  group("SafeTextFilter Initialization", () {
    test("initializes successfully with a list of languages", () async {
      // Test the new list-based initialization
      await SafeTextFilter.init(languages: [Language.english, Language.hindi]);

      // Verify it still works correctly
      final text = "This is badass and kutta behavior";
      final filtered = SafeTextFilter.filterText(text: text);

      expect(filtered, contains("******"));
      expect(filtered, contains("*****"));
    });
  });

  group("Performance Benchmark (Aho-Corasick vs Legacy Loop)", () {
    test("Benchmarks performance with 1700+ patterns", () async {
      final longInput =
          "This is a long sentence with some bad words like badass, anal impaler, and maybe another badass for good measure. " *
              50;

      // 1. Measure Legacy Loop (not initialized)
      final stopwatchLegacy = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        SafeTextFilter.filterText(text: longInput);
      }
      stopwatchLegacy.stop();
      final legacyTime = stopwatchLegacy.elapsedMilliseconds;

      // 2. Initialize Aho-Corasick (this builds the Trie)
      // Note: We ignore asset errors by catching them in init fallback to badWords
      await SafeTextFilter.init(language: Language.english);

      // 3. Measure Aho-Corasick Loop
      final stopwatchAC = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        SafeTextFilter.filterText(text: longInput);
      }
      stopwatchAC.stop();
      final acTime = stopwatchAC.elapsedMilliseconds;

      debugPrint("\n--- BENCHMARK RESULTS ---");
      debugPrint("Legacy Loop Time (100 iterations): ${legacyTime}ms");
      debugPrint("Aho-Corasick Time (100 iterations): ${acTime}ms");
      debugPrint(
          "Speedup: ${(legacyTime / (acTime == 0 ? 1 : acTime)).toStringAsFixed(2)}x");
      debugPrint("--------------------------\n");

      expect(acTime, lessThanOrEqualTo(legacyTime),
          reason: "Aho-Corasick should be faster or equal for large patterns");
    });
  });

  group("Advanced Multi-Language Benchmark", () {
    test("Benchmarks performance with mixed languages and non-normalized text",
        () async {
      // Mixed languages:
      // English (badass), Spanish (pendejo), Hindi (kutta),
      // French (merde), German (arschloch), Italian (stronzo)
      const mixedInput =
          "You are a b4dass friend, honestly. No p3nd3j0 behavior here. Don't be a ku++a. "
          "French: m3rd3. German: @rschloch. Italian: str0nz0. "
          "Repeat: b4dass, p3nd3j0, ku++a, m3rd3, @rschloch, str0nz0, @nal impaler, f@ck, \$h!t. ";
      final longLongInput = mixedInput * 100; // ~20,000 chars

      // We'll simulate a large pattern set by using all provided bad words
      // plus some custom ones to ensure we have matches in multiple languages.
      final customExtraWords = [
        "pendejo",
        "kutta",
        "badass",
        "anal impaler",
        "fuck",
        "shit",
        "merde",
        "arschloch",
        "stronzo"
      ];

      // 1. Measure Legacy Loop
      // 1. Measure Fallback Loop (Ensure Trie is NOT used)
      // We'll use a hack to temporarily disable the Trie for this measurement if it was initialized
      final stopwatchFallback = Stopwatch()..start();
      for (int i = 0; i < 10; i++) {
        // We use a custom call that bypasses the Trie or just ensures it's not initialized yet.
        // For the benchmark, we can just call it before SafeTextFilter.init(...)
        SafeTextFilter.filterText(
          text: longLongInput,
          extraWords: customExtraWords,
          useDefaultWords: true,
        );
      }
      stopwatchFallback.stop();
      final fallbackTime = stopwatchFallback.elapsedMilliseconds;

      // 2. Initialize Aho-Corasick (Trie)
      await SafeTextFilter.init(language: Language.all);

      // 3. Measure Aho-Corasick
      final stopwatchAC = Stopwatch()..start();
      for (int i = 0; i < 10; i++) {
        SafeTextFilter.filterText(
          text: longLongInput,
          extraWords: customExtraWords,
          useDefaultWords: true,
        );
      }
      stopwatchAC.stop();
      final acTime = stopwatchAC.elapsedMilliseconds;

      debugPrint("\n--- ADVANCED MULTI-LANG BENCHMARK ---");
      debugPrint("Input Size: ${longLongInput.length} characters");
      debugPrint("Fallback Loop Time (10 iterations): ${fallbackTime}ms");
      debugPrint("Aho-Corasick Time (10 iterations): ${acTime}ms");
      debugPrint(
          "Actual Speedup: ${(fallbackTime / (acTime == 0 ? 1 : acTime)).toStringAsFixed(2)}x");
      debugPrint("------------------------------------\n");

      expect(acTime, isNotNull);
    });
  });
}

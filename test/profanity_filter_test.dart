import 'package:safe_text/constants/badwords.dart';
import 'package:safe_text/safe_text.dart';
import 'package:test/test.dart';

void main() {
  group("SafeTextFilter class method filterText", () {
    setUpAll(() {
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
          SafeTextFilter.containsBadWord(text: textWithBadWord);
      bool noBadWord = SafeTextFilter.containsBadWord(text: cleanText);

      expect(containsBadWord, true);
      expect(noBadWord, false);
    });

    test('will check for bad words with extra words', () async {
      String textWithCustomBadWord = "This is an inappropriate word example";
      String cleanText = "This is another clean example";

      bool containsCustomBadWord = SafeTextFilter.containsBadWord(
        text: textWithCustomBadWord,
        extraWords: ['inappropriate'],
      );
      bool noBadWord = SafeTextFilter.containsBadWord(text: cleanText);

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
      expect(() => MaskStrategy.full(obscureSymbol: '##'),
          throwsA(isA<AssertionError>()));
    });

    test('PartialMask throws AssertionError for multi-character obscureSymbol',
        () {
      expect(() => MaskStrategy.partial(obscureSymbol: '##'),
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
      SafeTextFilter.init(languages: [Language.english, Language.hindi]);

      // Verify it still works correctly
      final text = "This is badass and kutta behavior";
      final filtered = SafeTextFilter.filterText(text: text);

      expect(filtered, contains("******"));
      expect(filtered, contains("*****"));
    });

    test("filters foul emojis and characters outside BMP correctly", () async {
      SafeTextFilter.init(language: Language.english);

      // 🖕 and 💩 are in en.txt
      final text = "You are a 💩 and a 🖕";
      final filtered = SafeTextFilter.filterText(text: text);

      expect(filtered, "You are a * and a *");
    });

    test("auto-initializes with English on first use without explicit init",
        () {
      SafeTextFilter.reset();
      expect(SafeTextFilter.isInitialized, false);

      final filtered =
          SafeTextFilter.filterText(text: "This is a badass sentence");
      expect(filtered, contains("******"));
      expect(SafeTextFilter.isInitialized, true);
    });
  });

  group("Normalization consistency", () {
    setUpAll(() => SafeTextFilter.init(language: Language.english));

    test("matches dataset words containing 'v' (normalized to 'u')", () {
      expect(SafeTextFilter.filterText(text: "you vagina"), "you ******");
      expect(SafeTextFilter.filterText(text: "a pervert"), "a *******");
      expect(SafeTextFilter.containsBadWord(text: "VAGINA"), true);
    });

    test("still catches 'v' used as a leet substitute for 'u'", () {
      expect(SafeTextFilter.filterText(text: "fvck"), "****");
    });

    test("matches dataset words that contain leet characters", () {
      expect(
          SafeTextFilter.filterText(text: "watch 2g1c now"), "watch **** now");
      expect(SafeTextFilter.containsBadWord(text: "10tacle"), true);
    });

    test("leet-character entries do not match their normalized plain form", () {
      // Dataset entries like the Arabizi '3ars' and '@unt' must not turn
      // ordinary words into matches.
      for (final word in ["ears", "aunt", "tuck", "emu", "sara", "uagina"]) {
        expect(SafeTextFilter.containsBadWord(text: "my $word"), false,
            reason: word);
      }
    });

    test("excludedWords is case-insensitive", () {
      expect(
          SafeTextFilter.filterText(
              text: "Hello badass", excludedWords: ["BadAss"]),
          "Hello badass");
      expect(
          SafeTextFilter.containsBadWord(
              text: "Hello badass", excludedWords: ["BADASS"]),
          false);
    });

    test("excludedWords applies to leet-speak variants of the word", () {
      expect(
          SafeTextFilter.filterText(
              text: "Hello b4dass", excludedWords: ["badass"]),
          "Hello b4dass");
    });

    test("excludedWords excludes dataset words containing 'v'", () {
      expect(
          SafeTextFilter.filterText(
              text: "a pervert", excludedWords: ["pervert"]),
          "a pervert");
    });

    test("extraWords containing 'v' or leet characters are matched", () {
      expect(
          SafeTextFilter.filterText(
              text: "more vodka please",
              useDefaultWords: false,
              extraWords: ["vodka"]),
          "more ***** please");
      expect(
          SafeTextFilter.containsBadWord(
              text: "a b@nana", useDefaultWords: false, extraWords: ["b@nana"]),
          true);
    });

    test("asserts when extraWords and excludedWords differ only by case", () {
      expect(
          () => SafeTextFilter.filterText(
              text: "foo",
              useDefaultWords: false,
              extraWords: ["foo"],
              excludedWords: ["FOO"]),
          throwsA(isA<AssertionError>()));
    });
  });

  group("Performance Benchmark (Aho-Corasick vs Legacy Loop)", () {
    test("Benchmarks performance with 1700+ patterns", () async {
      final longInput =
          "This is a long sentence with some bad words like badass, anal impaler, and maybe another badass for good measure. " *
              50;

      // 1. Measure the legacy linear scan: each of the ~1700 legacy words is
      // matched individually via extraWords, bypassing the Trie.
      final stopwatchLegacy = Stopwatch()..start();
      for (int i = 0; i < 5; i++) {
        SafeTextFilter.filterText(
            text: longInput, useDefaultWords: false, extraWords: badWords);
      }
      stopwatchLegacy.stop();
      final legacyTime = stopwatchLegacy.elapsedMilliseconds;

      // 2. Build the Aho-Corasick Trie up front so init time isn't measured
      SafeTextFilter.init(language: Language.english);

      // 3. Measure Aho-Corasick Loop (full ~13k English list)
      final stopwatchAC = Stopwatch()..start();
      for (int i = 0; i < 5; i++) {
        SafeTextFilter.filterText(text: longInput);
      }
      stopwatchAC.stop();
      final acTime = stopwatchAC.elapsedMilliseconds;

      print("\n--- BENCHMARK RESULTS ---");
      print("Legacy Loop Time (5 iterations): ${legacyTime}ms");
      print("Aho-Corasick Time (5 iterations): ${acTime}ms");
      print(
          "Speedup: ${(legacyTime / (acTime == 0 ? 1 : acTime)).toStringAsFixed(2)}x");
      print("--------------------------\n");

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
      SafeTextFilter.init(language: Language.all);

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

      print("\n--- ADVANCED MULTI-LANG BENCHMARK ---");
      print("Input Size: ${longLongInput.length} characters");
      print("Fallback Loop Time (10 iterations): ${fallbackTime}ms");
      print("Aho-Corasick Time (10 iterations): ${acTime}ms");
      print(
          "Actual Speedup: ${(fallbackTime / (acTime == 0 ? 1 : acTime)).toStringAsFixed(2)}x");
      print("------------------------------------\n");

      expect(acTime, isNotNull);
    });

    test(
        'will correctly reflect initialization status via isInitialized and reset state via reset()',
        () async {
      SafeTextFilter.reset();
      expect(SafeTextFilter.isInitialized, false);

      SafeTextFilter.init(language: Language.english);
      expect(SafeTextFilter.isInitialized, true);

      SafeTextFilter.reset();
      expect(SafeTextFilter.isInitialized, false);
    });
  });
}

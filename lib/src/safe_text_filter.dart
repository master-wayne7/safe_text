import 'package:safe_text/constants/badwords.dart';

import 'aho_corasick.dart';
import 'models/language.dart';
import 'models/mask_strategy.dart';

/// Core filter class that uses Aho-Corasick trie for efficient searching
class SafeTextFilter {
  /// Entries without leet-speak characters, searched against normalized text
  /// so that obfuscated variants (e.g. `f@ck`, `fvck`) are caught.
  static AhoCorasick? _trie;

  /// Entries that contain leet-speak characters (e.g. `vagina`, `2g1c`),
  /// searched against lowercased text so they only match as written.
  /// Normalizing these instead would turn entries like the Arabizi `3ars`
  /// into ordinary words (`ears`).
  static AhoCorasick? _literalTrie;

  static bool _isInitialized = false;

  /// Whether [SafeTextFilter] has been initialized via [init].
  static bool get isInitialized => _isInitialized;

  /// Resets the internal state of [SafeTextFilter], clearing the loaded Trie
  /// word lists. Useful when dynamically switching languages or freeing memory.
  static void reset() {
    _trie = null;
    _literalTrie = null;
    _isInitialized = false;
  }

  /// Matches any Unicode letter or digit (covers all scripts: Latin, Arabic,
  /// Devanagari, CJK, Hangul, Cyrillic, Hebrew, Thai, etc.)
  static final RegExp _unicodeLetterOrDigit =
      RegExp(r'\p{L}|\p{N}', unicode: true);

  // Normalization map to catch leet-speak and common variations
  static final Map<int, int> _normalizationMap = {
    '@'.codeUnitAt(0): 'a'.codeUnitAt(0),
    '4'.codeUnitAt(0): 'a'.codeUnitAt(0),
    '8'.codeUnitAt(0): 'b'.codeUnitAt(0),
    '('.codeUnitAt(0): 'c'.codeUnitAt(0),
    '3'.codeUnitAt(0): 'e'.codeUnitAt(0),
    '1'.codeUnitAt(0): 'i'.codeUnitAt(0),
    '!'.codeUnitAt(0): 'i'.codeUnitAt(0),
    '0'.codeUnitAt(0): 'o'.codeUnitAt(0),
    '\$'.codeUnitAt(0): 's'.codeUnitAt(0),
    '5'.codeUnitAt(0): 's'.codeUnitAt(0),
    '7'.codeUnitAt(0): 't'.codeUnitAt(0),
    '+'.codeUnitAt(0): 't'.codeUnitAt(0),
    'v'.codeUnitAt(0): 'u'.codeUnitAt(0),
    '#'.codeUnitAt(0): 'h'.codeUnitAt(0),
  };

  /// Initializes the SafeTextFilter.
  /// You can provide a single [language] or a list of [languages].
  /// If [languages] is provided, it takes precedence over [language].
  /// Defaults to [Language.english] if both are null.
  static void init({Language? language, List<Language>? languages}) {
    final words = _loadWords(language: language, languages: languages);

    // Building the Trie locally is fast and avoids serialization overhead
    final trie = AhoCorasick();
    final literalTrie = AhoCorasick();
    for (var word in words) {
      final lower = word.toLowerCase();
      (_hasMappedChar(lower.runes) ? literalTrie : trie).addWord(lower);
    }
    _trie = trie..buildFailureLinks();
    _literalTrie = literalTrie..buildFailureLinks();

    _isInitialized = true;
  }

  static void _ensureInitialized() {
    if (_trie == null) init();
  }

  static List<String> _loadWords({
    Language? language,
    List<Language>? languages,
  }) {
    final List<String> words = [];

    if (languages != null && languages.isNotEmpty) {
      for (var l in languages) {
        words.addAll(l.words);
      }
    } else {
      final lang = language ?? Language.english;
      words.addAll(lang.words);
    }

    if (words.isEmpty) {
      words.addAll(badWords);
    }
    return words.toSet().toList();
  }

  /// Normalizes text by replacing leet-speak with standard alphabets.
  static String normalizeText(String text) {
    if (text.isEmpty) return text;
    final runes = _normalizeToRunes(text);
    return String.fromCharCodes(runes);
  }

  static List<int> _normalizeToRunes(String text) =>
      _normalizeRunes(text.toLowerCase().runes.toList());

  /// Returns a copy of [lowerRunes] with leet-speak characters replaced.
  static List<int> _normalizeRunes(List<int> lowerRunes) {
    final runes = List<int>.of(lowerRunes);
    for (int i = 0; i < runes.length; i++) {
      final replacement = _normalizationMap[runes[i]];
      if (replacement != null) {
        runes[i] = replacement;
      }
    }
    return runes;
  }

  static bool _hasMappedChar(Iterable<int> runes) =>
      runes.any(_normalizationMap.containsKey);

  /// Static method to check if a string contains any bad words.
  static bool containsBadWord({
    required String text,
    List<String>? extraWords,
    List<String>? excludedWords,
    bool useDefaultWords = true,
  }) {
    if (text.isEmpty) return false;

    return _collectMatches(
      text,
      extraWords: extraWords,
      excludedWords: excludedWords,
      useDefaultWords: useDefaultWords,
    ).isNotEmpty;
  }

  /// Finds the rune ranges of every bad word in [text].
  ///
  /// Words without leet-speak characters are matched against the normalized
  /// text; words containing them are matched literally against the lowercased
  /// text (see [_literalTrie]).
  static List<_Range> _collectMatches(
    String text, {
    List<String>? extraWords,
    List<String>? excludedWords,
    required bool useDefaultWords,
  }) {
    final lowerRunes = text.toLowerCase().runes.toList();
    final normalizedRunes = _normalizeRunes(lowerRunes);
    final hasMapped = _hasMappedChar(lowerRunes);
    final matchRanges = <_Range>[];

    final excludedNormalized = {
      for (final word in excludedWords ?? const <String>[]) normalizeText(word)
    };
    final excludedLiteral = {
      for (final word in excludedWords ?? const <String>[]) word.toLowerCase()
    };

    if (useDefaultWords) {
      _ensureInitialized();
      _addTrieMatches(_trie!, normalizedRunes, excludedNormalized, matchRanges);
      if (hasMapped) {
        _addTrieMatches(
            _literalTrie!, lowerRunes, excludedLiteral, matchRanges);
      }
    }

    for (final word in extraWords ?? const <String>[]) {
      final lower = word.toLowerCase();
      if (!_hasMappedChar(lower.runes)) {
        if (excludedNormalized.contains(lower)) continue;
        _addMatchesForWord(normalizedRunes, lower, matchRanges);
      } else if (hasMapped && !excludedLiteral.contains(lower)) {
        _addMatchesForWord(lowerRunes, lower, matchRanges);
      }
    }

    return matchRanges;
  }

  static void _addTrieMatches(AhoCorasick trie, List<int> runes,
      Set<String> excluded, List<_Range> matches) {
    trie.searchRunes(runes).forEach((endIndex, words) {
      for (final word in words) {
        if (excluded.contains(word)) continue;
        final startIndex = endIndex - word.runes.length + 1;
        if (_isWordBoundary(runes, startIndex, endIndex + 1)) {
          matches.add(_Range(startIndex, endIndex + 1));
        }
      }
    });
  }

  /// This method will filter out the bad words from your provided [string].
  static String filterText({
    required String text,
    List<String>? extraWords,
    List<String>? excludedWords,
    bool useDefaultWords = true,
    @Deprecated('Use strategy instead.') bool fullMode = true,
    @Deprecated(
      'Use strategy instead. Pass obscureSymbol via MaskStrategy.full() or MaskStrategy.partial().',
    )
    String obscureSymbol = "*",
    MaskStrategy? strategy,
  }) {
    if (useDefaultWords == false && extraWords == null) {
      assert(false, "extraWords can't be null for usingDefaultWords = false");
    }

    assert(() {
      final excluded = {for (final w in excludedWords ?? []) w.toLowerCase()};
      return !(extraWords ?? []).any((w) => excluded.contains(w.toLowerCase()));
    }(), "Can't have same words in excludedWords and extraWords");

    // Derive the effective masking strategy. When the caller passes an explicit
    // [strategy] it takes precedence. Otherwise fall back to the legacy
    // [fullMode] / [obscureSymbol] pair so that existing call sites continue to
    // work without modification.
    final MaskStrategy maskStrategy = strategy ??
        (fullMode
            ? MaskStrategy.full(obscureSymbol: obscureSymbol)
            : MaskStrategy.partial(obscureSymbol: obscureSymbol));

    if (text.isEmpty) return text;

    final textRunes = text.runes.toList();

    // Step 1: Collect match ranges
    final matchRanges = _collectMatches(
      text,
      extraWords: extraWords,
      excludedWords: excludedWords,
      useDefaultWords: useDefaultWords,
    );

    if (matchRanges.isEmpty) return text;

    // Step 2: Sort and merge ranges
    matchRanges.sort((a, b) => a.start.compareTo(b.start));
    final List<_Range> merged = [];
    if (matchRanges.isNotEmpty) {
      _Range current = matchRanges[0];
      for (int i = 1; i < matchRanges.length; i++) {
        if (matchRanges[i].start < current.end) {
          if (matchRanges[i].end > current.end) {
            current = _Range(current.start, matchRanges[i].end);
          }
        } else {
          merged.add(current);
          current = matchRanges[i];
        }
      }
      merged.add(current);
    }

    // Step 3: Single-pass string building
    final buffer = StringBuffer();
    int lastAppended = 0;

    for (final range in merged) {
      buffer.write(
          String.fromCharCodes(textRunes.sublist(lastAppended, range.start)));

      final matchLength = range.end - range.start;
      switch (maskStrategy) {
        // Full: replace every character with the obscure symbol
        case FullMask(:final obscureSymbol):
          buffer.write(obscureSymbol * matchLength);

        // Partial: keep first char visible, mask the rest.
        // For 4+ letter words, also keep the last char visible.
        case PartialMask(:final obscureSymbol):
          if (matchLength == 1) {
            buffer.write(obscureSymbol);
          } else {
            final showLast = matchLength >= 4;
            final maskCount = matchLength - 1 - (showLast ? 1 : 0);
            buffer
              ..write(String.fromCharCode(textRunes[range.start]))
              ..write(obscureSymbol * maskCount);
            if (showLast) {
              buffer.write(String.fromCharCode(textRunes[range.end - 1]));
            }
          }

        // Custom: replace entire word with the replacement string
        case CustomMask(:final replacement):
          buffer.write(replacement);
      }
      lastAppended = range.end;
    }

    if (lastAppended < textRunes.length) {
      buffer.write(String.fromCharCodes(textRunes.sublist(lastAppended)));
    }

    return buffer.toString();
  }

  static void _addMatchesForWord(
      List<int> runes, String lowerWord, List<_Range> matches) {
    final wordRunes = lowerWord.runes.toList();
    if (wordRunes.isEmpty) return;

    for (int i = 0; i <= runes.length - wordRunes.length; i++) {
      bool match = true;
      for (int j = 0; j < wordRunes.length; j++) {
        if (runes[i + j] != wordRunes[j]) {
          match = false;
          break;
        }
      }

      if (match) {
        final endIndex = i + wordRunes.length;
        if (_isWordBoundary(runes, i, endIndex)) {
          matches.add(_Range(i, endIndex));
        }
      }
    }
  }

  static bool _isWordBoundary(List<int> runes, int start, int end) {
    if (start > 0) {
      final rune = runes[start - 1];
      if (_isAlphanumeric(rune)) return false;
    }
    if (end < runes.length) {
      final rune = runes[end];
      if (_isAlphanumeric(rune)) return false;
    }
    return true;
  }

  static bool _isAlphanumeric(int rune) {
    // ASCII fast path; the regex is only needed for other scripts.
    if (rune < 0x80) {
      return (rune >= 0x30 && rune <= 0x39) || // 0-9
          (rune >= 0x41 && rune <= 0x5A) || // A-Z
          (rune >= 0x61 && rune <= 0x7A); // a-z
    }
    return _unicodeLetterOrDigit.hasMatch(String.fromCharCode(rune));
  }
}

class _Range {
  final int start;
  final int end;
  _Range(this.start, this.end);
}

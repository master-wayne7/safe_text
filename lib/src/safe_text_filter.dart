import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:safe_text/constants/badwords.dart';

import 'aho_corasick.dart';
import 'models/language.dart';
import 'models/mask_strategy.dart';

/// Core filter class that uses Aho-Corasick trie for efficient searching
class SafeTextFilter {
  static AhoCorasick? _trie;
  static bool _isInitialized = false;

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
  static Future<void> init(
      {Language? language, List<Language>? languages}) async {
    final words = await _loadWords(language: language, languages: languages);

    // Building the Trie locally is fast and avoids serialization overhead
    _trie = AhoCorasick();
    for (var word in words) {
      _trie!.addWord(word);
    }
    _trie!.buildFailureLinks();

    _isInitialized = true;
  }

  static Future<List<String>> _loadWords(
      {Language? language, List<Language>? languages}) async {
    List<String> words = [];
    final List<Language> targetLanguages = [];

    if (languages != null && languages.isNotEmpty) {
      targetLanguages.addAll(languages);
    } else {
      final lang = language ?? Language.english;
      if (lang == Language.all) {
        targetLanguages.addAll(Language.values.where((l) => l != Language.all));
      } else {
        targetLanguages.add(lang);
      }
    }

    List<Future<String>> futures = [];
    for (var l in targetLanguages) {
      futures.add(
          _safeLoadAsset('packages/safe_text/assets/data/${l.fileCode}.txt'));
    }

    final results = await Future.wait(futures);
    for (var content in results) {
      if (content.isNotEmpty) {
        words.addAll(content
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty));
      }
    }

    if (words.isEmpty) {
      words.addAll(badWords);
    }
    return words.toSet().toList();
  }

  static Future<String> _safeLoadAsset(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      return '';
    }
  }

  /// Normalizes text by replacing leet-speak with standard alphabets.
  static String normalizeText(String text) {
    if (text.isEmpty) return text;
    final runes = _normalizeToRunes(text);
    return String.fromCharCodes(runes);
  }

  static List<int> _normalizeToRunes(String text) {
    final runes = text.toLowerCase().runes.toList();
    for (int i = 0; i < runes.length; i++) {
      final replacement = _normalizationMap[runes[i]];
      if (replacement != null) {
        runes[i] = replacement;
      }
    }
    return runes;
  }

  /// Static method to check if a string contains any bad words.
  static Future<bool> containsBadWord({
    required String text,
    List<String>? extraWords,
    List<String>? excludedWords,
    bool useDefaultWords = true,
  }) async {
    if (text.isEmpty) return false;

    final normalizedRunes = _normalizeToRunes(text);

    // Optimized sync check if initialized
    if (_isInitialized && useDefaultWords) {
      final normalized = String.fromCharCodes(normalizedRunes);
      final matches = _trie!.search(normalized);
      for (final entry in matches.entries) {
        final endIndex = entry.key;
        for (final word in entry.value) {
          if (excludedWords != null && excludedWords.contains(word)) continue;
          final wordRuneLength = word.runes.length;
          if (_isWordBoundary(
              normalizedRunes, endIndex - wordRuneLength + 1, endIndex + 1)) {
            return true;
          }
        }
      }
    } else if (useDefaultWords) {
      // Fallback or legacy path
      final normalized = String.fromCharCodes(normalizedRunes);
      for (final word in badWords) {
        if (excludedWords != null && excludedWords.contains(word)) continue;
        if (_hasMatch(normalized, word)) return true;
      }
    }

    if (extraWords != null) {
      final normalized = String.fromCharCodes(normalizedRunes);
      for (final word in extraWords) {
        if (excludedWords != null && excludedWords.contains(word)) continue;
        if (_hasMatch(normalized, word)) return true;
      }
    }

    return false;
  }

  static bool _hasMatch(String normalizedText, String word) {
    final wordLower = word.toLowerCase();
    final normalizedRunes = normalizedText.runes.toList();
    final wordRunes = wordLower.runes.toList();

    // Simple pattern matching on runes
    for (int i = 0; i <= normalizedRunes.length - wordRunes.length; i++) {
      bool match = true;
      for (int j = 0; j < wordRunes.length; j++) {
        if (normalizedRunes[i + j] != wordRunes[j]) {
          match = false;
          break;
        }
      }

      if (match && _isWordBoundary(normalizedRunes, i, i + wordRunes.length)) {
        return true;
      }
    }
    return false;
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

    if (extraWords != null && excludedWords != null) {
      for (final word in extraWords) {
        if (excludedWords.contains(word)) {
          assert(
              false, "Can't have same words in excludedWords and extraWords");
        }
      }
    }

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
    final normalizedRunes = _normalizeToRunes(text);
    final List<_Range> matchRanges = [];

    // Step 1: Collect match ranges
    if (_isInitialized && useDefaultWords) {
      final normalized = String.fromCharCodes(normalizedRunes);
      final trieMatches = _trie!.search(normalized);
      trieMatches.forEach((endIndex, words) {
        for (final word in words) {
          if (excludedWords != null && excludedWords.contains(word)) continue;
          final wordRuneLength = word.runes.length;
          final startIndex = endIndex - wordRuneLength + 1;
          if (_isWordBoundary(normalizedRunes, startIndex, endIndex + 1)) {
            matchRanges.add(_Range(startIndex, endIndex + 1));
          }
        }
      });
    } else if (useDefaultWords) {
      for (final word in badWords) {
        if (excludedWords != null && excludedWords.contains(word)) continue;
        _addMatchesForWord(normalizedRunes, word, matchRanges);
      }
    }

    if (extraWords != null) {
      for (final word in extraWords) {
        if (excludedWords != null && excludedWords.contains(word)) continue;
        _addMatchesForWord(normalizedRunes, word, matchRanges);
      }
    }

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
      List<int> normalizedRunes, String word, List<_Range> matches) {
    final wordRunes = word.toLowerCase().runes.toList();
    if (wordRunes.isEmpty) return;

    for (int i = 0; i <= normalizedRunes.length - wordRunes.length; i++) {
      bool match = true;
      for (int j = 0; j < wordRunes.length; j++) {
        if (normalizedRunes[i + j] != wordRunes[j]) {
          match = false;
          break;
        }
      }

      if (match) {
        final endIndex = i + wordRunes.length;
        if (_isWordBoundary(normalizedRunes, i, endIndex)) {
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
    return _unicodeLetterOrDigit.hasMatch(String.fromCharCode(rune));
  }
}

class _Range {
  final int start;
  final int end;
  _Range(this.start, this.end);
}

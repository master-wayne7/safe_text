import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:safe_text/constants/badwords.dart';

import 'aho_corasick.dart';
import 'models/language.dart';

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
  static Future<void> init({Language? language, List<Language>? languages}) async {
    final words = await _loadWords(language: language, languages: languages);
    
    // Building the Trie locally is fast and avoids serialization overhead
    _trie = AhoCorasick();
    for (var word in words) {
        _trie!.addWord(word);
    }
    _trie!.buildFailureLinks();
    
    _isInitialized = true;
  }

  static Future<List<String>> _loadWords({Language? language, List<Language>? languages}) async {
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
      futures.add(_safeLoadAsset('packages/safe_text/assets/data/${l.fileCode}.txt'));
    }

    final results = await Future.wait(futures);
    for (var content in results) {
      if (content.isNotEmpty) {
        words.addAll(content.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty));
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
    final units = List<int>.from(text.toLowerCase().codeUnits);
    for (int i = 0; i < units.length; i++) {
        final replacement = _normalizationMap[units[i]];
        if (replacement != null) {
            units[i] = replacement;
        }
    }
    return String.fromCharCodes(units);
  }

  /// Static method to check if a string contains any bad words.
  static Future<bool> containsBadWord({
    required String text,
    List<String>? extraWords,
    List<String>? excludedWords,
    bool useDefaultWords = true,
  }) async {
    if (text.isEmpty) return false;
    
    final normalized = normalizeText(text);

    // Optimized sync check if initialized
    if (_isInitialized && useDefaultWords) {
        final matches = _trie!.search(normalized);
        for (final entry in matches.entries) {
            final endIndex = entry.key;
            for (final word in entry.value) {
                if (excludedWords != null && excludedWords.contains(word)) continue;
                if (_isWordBoundary(normalized, endIndex - word.length + 1, endIndex + 1)) {
                    return true;
                }
            }
        }
    } else if (useDefaultWords) {
        // Fallback or legacy path
        for (final word in badWords) {
            if (excludedWords != null && excludedWords.contains(word)) continue;
            if (_hasMatch(normalized, word)) return true;
        }
    }

    if (extraWords != null) {
        for (final word in extraWords) {
            if (excludedWords != null && excludedWords.contains(word)) continue;
            if (_hasMatch(normalized, word)) return true;
        }
    }

    return false;
  }

  static bool _hasMatch(String normalizedText, String word) {
      final wordLower = word.toLowerCase();
      int index = normalizedText.indexOf(wordLower);
      while (index != -1) {
          if (_isWordBoundary(normalizedText, index, index + wordLower.length)) {
              return true;
          }
          index = normalizedText.indexOf(wordLower, index + 1);
      }
      return false;
  }

  /// This method will filter out the bad words from your provided [string].
  static String filterText({
    required String text,
    List<String>? extraWords,
    List<String>? excludedWords,
    bool useDefaultWords = true,
    bool fullMode = true,
    String obscureSymbol = "*",
  }) {
    if (useDefaultWords == false && extraWords == null) {
      assert(false, "extraWords can't be null for usingDefaultWords = false");
    }

    if (extraWords != null && excludedWords != null) {
      for (final word in extraWords) {
        if (excludedWords.contains(word)) {
          assert(false, "Can't have same words in excludedWords and extraWords");
        }
      }
    }

    if (text.isEmpty) return text;

    final normalizedText = normalizeText(text);
    final List<_Range> matchRanges = [];

    // Step 1: Collect match ranges
    if (_isInitialized && useDefaultWords) {
      final trieMatches = _trie!.search(normalizedText);
      trieMatches.forEach((endIndex, words) {
        for (final word in words) {
          if (excludedWords != null && excludedWords.contains(word)) continue;
          final startIndex = endIndex - word.length + 1;
          if (_isWordBoundary(normalizedText, startIndex, endIndex + 1)) {
            matchRanges.add(_Range(startIndex, endIndex + 1));
          }
        }
      });
    } else if (useDefaultWords) {
      for (final word in badWords) {
        if (excludedWords != null && excludedWords.contains(word)) continue;
        _addMatchesForWord(normalizedText, word, matchRanges);
      }
    }

    if (extraWords != null) {
      for (final word in extraWords) {
        if (excludedWords != null && excludedWords.contains(word)) continue;
        _addMatchesForWord(normalizedText, word, matchRanges);
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
      buffer.write(text.substring(lastAppended, range.start));

      final matchLength = range.end - range.start;
      if (fullMode) {
        buffer.write(obscureSymbol * matchLength);
      } else {
        if (matchLength > 2) {
          buffer.write(text[range.start]);
          buffer.write(obscureSymbol * (matchLength - 2));
          buffer.write(text[range.end - 1]);
        } else {
          buffer.write(text.substring(range.start, range.end));
        }
      }
      lastAppended = range.end;
    }

    if (lastAppended < text.length) {
      buffer.write(text.substring(lastAppended));
    }

    return buffer.toString();
  }

  static void _addMatchesForWord(String normalizedText, String word, List<_Range> matches) {
      final wordLower = word.toLowerCase();
      int index = normalizedText.indexOf(wordLower);
      while (index != -1) {
          final endIndex = index + wordLower.length;
          if (_isWordBoundary(normalizedText, index, endIndex)) {
              matches.add(_Range(index, endIndex));
          }
          index = normalizedText.indexOf(wordLower, index + 1);
      }
  }

  static bool _isWordBoundary(String text, int start, int end) {
    if (start > 0) {
      final charCode = text.codeUnitAt(start - 1);
      if (_isAlphanumeric(charCode)) return false;
    }
    if (end < text.length) {
      final charCode = text.codeUnitAt(end);
      if (_isAlphanumeric(charCode)) return false;
    }
    return true;
  }

  static bool _isAlphanumeric(int charCode) {
    return _unicodeLetterOrDigit.hasMatch(String.fromCharCode(charCode));
  }
}

class _Range {
  final int start;
  final int end;
  _Range(this.start, this.end);
}

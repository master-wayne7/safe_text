class PhoneNumberChecker {
  static final Map<String, String> numberWords = {
    'zero': '0',
    'one': '1',
    'two': '2',
    'three': '3',
    'four': '4',
    'five': '5',
    'six': '6',
    'seven': '7',
    'eight': '8',
    'nine': '9',
  };

  static final Map<String, int> multiplierWords = {
    'double': 2,
    'triple': 3,
    'quadruple': 4,
    'quintuple': 5,
    'sextuple': 6,
    'septuple': 7,
    'octuple': 8,
    'nonuple': 9,
    'decuple': 10,
  };

  /// Public method to check if a given text contains a phone number in digits, words, or mixed format.
  ///
  /// Runs on the calling thread on every platform (including web): the check
  /// is linear and takes about 2ms even for ~87k characters, well within a
  /// frame. The `Future` return type is kept for backwards compatibility.
  static Future<bool> containsPhoneNumber({
    required String text,
    int minLength = 7,
    int maxLength = 15,
  }) async {
    return _containsPhoneNumberInMixedFormat(text, minLength, maxLength);
  }

  static final RegExp _unicodeLetter = RegExp(r'\p{L}', unicode: true);

  /// Splits text into digit runs and letter runs; punctuation and whitespace
  /// (e.g. `-`, `.`, `(`, `)`, `+`) act only as separators.
  ///
  /// Hand-written rather than a regex: this is several times faster on long
  /// input, which keeps the check cheap enough to run on the UI thread.
  static List<String> _tokenize(String text) {
    final tokens = <String>[];
    int start = -1;
    int kind = 0; // 0 = separator, 1 = digit, 2 = letter

    int kindOf(int c) {
      if (c >= 0x30 && c <= 0x39) return 1;
      if (c < 0x80) {
        return (c >= 0x61 && c <= 0x7A) || (c >= 0x41 && c <= 0x5A) ? 2 : 0;
      }
      // Non-BMP characters (emoji etc.) arrive as surrogate halves, which
      // never match \p{L}, so they act as separators.
      return _unicodeLetter.hasMatch(String.fromCharCode(c)) ? 2 : 0;
    }

    for (int i = 0; i <= text.length; i++) {
      final k = i < text.length ? kindOf(text.codeUnitAt(i)) : 0;
      if (k == kind) continue;
      if (kind != 0) tokens.add(text.substring(start, i));
      kind = k;
      start = i;
    }
    return tokens;
  }

  /// Private method to check for phone numbers in mixed format (digits + words).
  ///
  /// Digits are collected from consecutive number tokens (digit runs, number
  /// words, and multiplier phrases like "triple four"). Any other word ends the
  /// current candidate, so unrelated numbers in a sentence are not combined.
  static bool _containsPhoneNumberInMixedFormat(
      String text, int minLength, int maxLength) {
    final tokens = _tokenize(text.toLowerCase());
    final candidate = StringBuffer();

    bool isCandidateValid() =>
        candidate.length >= minLength && candidate.length <= maxLength;

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final digits = _digitsFor(token);

      if (digits != null) {
        candidate.write(digits);
        continue;
      }

      final multiplier = multiplierWords[token];
      if (multiplier != null && i + 1 < tokens.length) {
        final nextDigits = _digitsFor(tokens[i + 1]);
        if (nextDigits != null) {
          candidate.write(nextDigits * multiplier);
          i++; // Skip the next token since we're processing it now
          continue;
        }
      }

      // A non-number word ends the current candidate.
      if (isCandidateValid()) return true;
      candidate.clear();
    }

    return isCandidateValid();
  }

  /// Returns the digits [token] represents, or `null` if it is not a number.
  static String? _digitsFor(String token) {
    final word = numberWords[token];
    if (word != null) return word;
    final first = token.codeUnitAt(0);
    return first >= 0x30 && first <= 0x39 ? token : null;
  }
}

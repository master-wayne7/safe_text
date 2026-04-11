import 'package:flutter/foundation.dart';

/// Detects phone numbers embedded in plain text, including digit-only,
/// word-only, and mixed formats.
///
/// The checker understands spoken representations such as `"triple five"`,
/// `"double zero"`, and combinations like `"555 double 0 123"`, in addition
/// to standard numeric strings.
///
/// ## Usage
///
/// ```dart
/// final found = await PhoneNumberChecker.containsPhoneNumber(
///   text: 'Call me at 555 triple two 9',
/// ); // true
/// ```
///
/// The check runs in a separate isolate via `compute` so it does not block
/// the main thread.
class PhoneNumberChecker {
  /// Maps English number words to their single-digit string equivalents.
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

  /// Maps English multiplier words to their integer values.
  ///
  /// Used to expand phrases like `"triple five"` into `"555"`.
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

  /// Returns `true` if [text] contains what appears to be a phone number.
  ///
  /// Detects phone numbers written as digits, English number words, multiplier
  /// phrases, or any combination of the above. Examples that are detected:
  ///
  /// - `"Call 07700900123"` — digit-only
  /// - `"Call zero seven seven zero zero nine"` — word-only
  /// - `"Call 077 double zero 9"` — mixed with multiplier
  ///
  /// Parameters:
  /// - [text] — the string to inspect.
  /// - [minLength] — minimum digit count for a sequence to be considered a
  ///   phone number. Defaults to `7`.
  /// - [maxLength] — maximum digit count. Defaults to `15`.
  ///
  /// ```dart
  /// await PhoneNumberChecker.containsPhoneNumber(
  ///   text: 'My number is 07700 900 123',
  /// ); // true
  ///
  /// await PhoneNumberChecker.containsPhoneNumber(
  ///   text: 'Hello world',
  /// ); // false
  /// ```
  ///
  /// The computation runs in a separate isolate via `compute` to avoid
  /// blocking the main thread.
  static Future<bool> containsPhoneNumber({
    required String text,
    int minLength = 7,
    int maxLength = 15,
  }) async {
    // Use compute to run the heavy logic in a separate isolate
    return await compute(_checkPhoneNumberInIsolate, {
      'text': text,
      'minLength': minLength,
      'maxLength': maxLength,
    });
  }

  /// Entry point executed inside the isolate spawned by [containsPhoneNumber].
  static bool _checkPhoneNumberInIsolate(Map<String, dynamic> params) {
    String text = params['text'];
    int minLength = params['minLength'];
    int maxLength = params['maxLength'];

    // Check for mixed format phone numbers (digits + words)
    if (_containsPhoneNumberInMixedFormat(text, minLength, maxLength)) {
      return true;
    }

    return false;
  }

  /// Scans [text] for a sequence of number tokens (digits, number words, or
  /// multiplier phrases) whose combined digit count falls within
  /// [[minLength], [maxLength]].
  static bool _containsPhoneNumberInMixedFormat(
      String text, int minLength, int maxLength) {
    text = text.toLowerCase();

    // Instead of splitting by regex `\s+` which is slower, we use standard split and trim
    // Or we simply iterate through the string.
    List<String> words = text.split(RegExp(r'\s+'));
    StringBuffer phoneNumberBuffer = StringBuffer();

    for (int i = 0; i < words.length; i++) {
      String word = words[i];

      if (numberWords.containsKey(word)) {
        phoneNumberBuffer.write(numberWords[word]);
      } else if (RegExp(r'\d').hasMatch(word)) {
        phoneNumberBuffer.write(word.replaceAll(RegExp(r'\D'), ''));
      } else if (multiplierWords.containsKey(word)) {
        // Check if the next word is a number word or digit
        if (i + 1 < words.length) {
          String nextWord = words[i + 1];
          String digitToRepeat = '';

          if (numberWords.containsKey(nextWord)) {
            digitToRepeat = numberWords[nextWord]!;
            i++; // Skip the next word since we're processing it now
          } else if (RegExp(r'^\d+$').hasMatch(nextWord)) {
            digitToRepeat = nextWord;
            i++; // Skip the next word since we're processing it now
          }

          if (digitToRepeat.isNotEmpty) {
            int multiplier = multiplierWords[word]!;
            // Repeat the digit 'multiplier' times
            for (int k = 0; k < multiplier; k++) {
              phoneNumberBuffer.write(digitToRepeat);
            }
          }
        }
      }
    }

    String potentialPhoneNumber = phoneNumberBuffer.toString();
    return potentialPhoneNumber.length >= minLength &&
        potentialPhoneNumber.length <= maxLength;
  }
}

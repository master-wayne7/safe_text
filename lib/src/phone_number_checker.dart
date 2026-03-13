import 'package:flutter/foundation.dart';

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
  /// This method runs in a separate isolate using the `compute` function.
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

  /// Helper function to run in a separate isolate
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

  /// Private method to check for phone numbers in mixed format (digits + words)
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

// ignore_for_file: prefer_interpolation_to_compose_strings

library safe_text;

import 'package:flutter/foundation.dart';
import 'package:safe_text/constants/badwords.dart';

/// A safe  text class to check if a string contains any bad  words or not.
class SafeText {
  /// This method will filter  out the bad words from your provided [string].
  static String filterText(
      {
      /// Text to be filtered out
      required String text,

      /// List of extra Bad Words that you want to filter out. Defaults to [badWords] constant list.
      List<String>? extraWords,

      /// List of Bad Words that you don't want to filter out.
      List<String>? excludedWords,

      /// Whether you want to use the default words for filter or not. If set false it will only consider the [extraWords]. Defaults to true
      bool useDefaultWords = true,

      /// Whether to fully filter out the word or only the middle part except first and last alphabet
      bool fullMode = true,

      /// the symbol used to obscure the bad word
      String obscureSymbol = "*"}) {
    List<String> allWords = [];

    /// will throw error if useDefaultWords == false and no extra words provided
    if (useDefaultWords == false && extraWords == null) {
      assert(false, "extraWords can't be null for usingDefaultWords = false");
    } else if (useDefaultWords == false && extraWords != null) {
      /// if excluded words and extrawords have something in common
      if (excludedWords != null && _hasCommonString(excludedWords, extraWords)) {
        assert(false, "Can't have same words in excludedWords and extraWords");
      }

      /// will only use the words provided by the user
      else {
        for (var word in extraWords) {
          if (word.split(" ").length > 1) {
            allWords.insert(0, word);
          } else {
            allWords.insert(allWords.length, word);
          }
        }
      }
    } else {
      /// This will add all the extraWords
      if (extraWords != null) {
        /// if excluded words and extrawords have something in common
        if (excludedWords != null && _hasCommonString(excludedWords, extraWords)) {
          assert(false, "Can't have same words in excludedWords and extraWords");
        }

        /// will remove all the excluded words
        else if (excludedWords != null) {
          allWords = [
            ...badWords
          ];
          for (var word in excludedWords) {
            if (allWords.contains(word)) {
              allWords.remove(word);
            }
          }

          for (var word in extraWords) {
            if (word.split(" ").length > 1) {
              allWords.insert(0, word);
            } else {
              allWords.insert(allWords.length, word);
            }
          }
        }

        /// will add extra words and badwords
        else {
          allWords = [
            ...badWords
          ];

          for (var word in extraWords) {
            if (word.split(" ").length > 1) {
              allWords.insert(0, word);
            } else {
              allWords.insert(allWords.length, word);
            }
          }
        }
      } else {
        if (excludedWords != null) {
          allWords = [
            ...badWords
          ];
          for (var word in excludedWords) {
            if (allWords.contains(word)) {
              allWords.remove(word);
            }
          }
        } else {
          allWords = badWords;
        }
      }
    }

    for (var badWord in allWords) {
      if (text.toLowerCase().contains(badWord.toLowerCase())) {
        if (fullMode) {
          text = text.replaceAll(RegExp(r'\b' + badWord + r'\b', caseSensitive: false), obscureSymbol * badWord.length);
        } else {
          if (badWord.length > 2) {
            final replacement = badWord[0] + obscureSymbol * (badWord.length - 2) + badWord[badWord.length - 1];
            text = text.replaceAll(RegExp(r'\b' + badWord + r'\b', caseSensitive: false), replacement);
          }
        }
      }
    }
    return text;
  }

  static bool _hasCommonString(List<String> list1, List<String> list2) {
    for (var str1 in list1) {
      if (list2.contains(str1)) {
        return true; // Found a common string
      }
    }
    return false; // No common string found
  }

  /// Method to detect if a string contains any bad words.
  static Future<bool> containsBadWord({
    /// Text for checking for profanity
    required String text,

    /// List of extra Bad Words that you want to filter out. Defaults to [badWords] constant list
    List<String>? extraWords,

    /// List of Bad Words that you don't want to filter out.
    List<String>? excludedWords,

    /// Whether you want to use the default words for filter or not. If set false it will only consider the [extraWords]. Defaults to true
    bool useDefaultWords = true,
  }) async {
    // Running the check in a separate isolate (thread)
    return await compute(_checkBadWords, {
      'text': text,
      'extraWords': extraWords,
      'excludedWords': excludedWords,
      'useDefaultWords': useDefaultWords
    });
  }

  /// Helper method for checking bad words in a separate isolate
  static bool _checkBadWords(Map<String, dynamic> args) {
    String text = args['text'];
    List<String>? extraWords = args['extraWords'];
    List<String>? excludedWords = args['excludedWords'];
    bool useDefaultWords = args['useDefaultWords'];

    List<String> allWords = [];

    if (useDefaultWords == false && extraWords == null) {
      throw ArgumentError("extraWords can't be null for usingDefaultWords = false");
    } else if (useDefaultWords == false && extraWords != null) {
      if (excludedWords != null && _hasCommonString(excludedWords, extraWords)) {
        throw ArgumentError("Can't have same words in excludedWords and extraWords");
      } else {
        allWords = [
          ...extraWords
        ];
      }
    } else {
      if (extraWords != null) {
        if (excludedWords != null && _hasCommonString(excludedWords, extraWords)) {
          throw ArgumentError("Can't have same words in excludedWords and extraWords");
        } else if (excludedWords != null) {
          allWords = [
            ...badWords
          ];
          for (var word in excludedWords) {
            if (allWords.contains(word)) {
              allWords.remove(word);
            }
          }
          allWords.addAll(extraWords);
        } else {
          allWords = [
            ...badWords,
            ...extraWords
          ];
        }
      } else {
        allWords = badWords;
        if (excludedWords != null) {
          for (var word in excludedWords) {
            if (allWords.contains(word)) {
              allWords.remove(word);
            }
          }
        }
      }
    }

    for (var badWord in allWords) {
      if (text.toLowerCase().contains(badWord.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

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

  /// Detects if a given text contains a phone number in digits or words.
  static bool containsPhoneNumber({
    required String text,
    int minLength = 7,
    int maxLength = 15,
  }) {
    // Check for digit-based phone numbers
    if (_containsDigitPhoneNumber(text, minLength, maxLength)) {
      return true;
    }

    // Check for word-based phone numbers
    if (_containsWordPhoneNumber(text, minLength, maxLength)) {
      return true;
    }

    // Check for digit-based, word-based, or mixed phone numbers
    if (_containsPhoneNumberInMixedFormat(text, minLength, maxLength)) {
      return true;
    }

    return false;
  }

  /// Private method to check for phone numbers in mixed format (digits + words)
  static bool _containsPhoneNumberInMixedFormat(String text, int minLength, int maxLength) {
    // Normalize the text to lowercase
    text = text.toLowerCase();

    // Split the text into words
    List<String> words = text.split(RegExp(r'\s+'));

    // Create a buffer to store converted digits
    StringBuffer phoneNumberBuffer = StringBuffer();

    for (var word in words) {
      // Check if the word is a digit or can be mapped from words to digits
      if (numberWords.containsKey(word)) {
        phoneNumberBuffer.write(numberWords[word]);
      } else if (RegExp(r'\d').hasMatch(word)) {
        // If the word contains digits, add them directly
        phoneNumberBuffer.write(word.replaceAll(RegExp(r'\D'), ''));
      }
    }

    // Extract the final phone number and check its length
    String potentialPhoneNumber = phoneNumberBuffer.toString();
    return potentialPhoneNumber.length >= minLength && potentialPhoneNumber.length <= maxLength;
  }

  /// Private method to check for digit-based phone numbers using regex
  static bool _containsDigitPhoneNumber(String text, int minLength, int maxLength) {
    // Regular expression to match phone numbers with a length between minLength and maxLength
    final RegExp digitPhoneRegex = RegExp(r'\b\d{' + minLength.toString() + ',' + maxLength.toString() + r'}\b');
    return digitPhoneRegex.hasMatch(text);
  }

  /// Private method to check for word-based phone numbers
  static bool _containsWordPhoneNumber(String text, int minLength, int maxLength) {
    // Normalize the text to lowercase
    text = text.toLowerCase();

    // Replace number words with digits
    String normalizedText = text;
    numberWords.forEach((word, digit) {
      // Replace words with corresponding digits
      normalizedText = normalizedText.replaceAll(RegExp(r'\b' + word + r'\b'), digit);
    });

    // Remove any non-digit characters (like spaces) from the normalized string
    normalizedText = normalizedText.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if we now have a number with a length between minLength and maxLength
    return normalizedText.length >= minLength && normalizedText.length <= maxLength;
  }
}

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
      if (excludedWords != null &&
          _hasCommonString(excludedWords, extraWords)) {
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
        if (excludedWords != null &&
            _hasCommonString(excludedWords, extraWords)) {
          assert(
              false, "Can't have same words in excludedWords and extraWords");
        }

        /// will remove all the excluded words
        else if (excludedWords != null) {
          allWords = [...badWords];
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
          allWords = [...badWords];

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
          allWords = [...badWords];
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
      final badWordPattern =
          RegExp(r'\b' + RegExp.escape(badWord) + r'\b', caseSensitive: false);
      if (badWordPattern.hasMatch(text)) {
        if (fullMode) {
          text = text.replaceAll(
              RegExp(r'\b' + badWord + r'\b', caseSensitive: false),
              obscureSymbol * badWord.length);
        } else {
          if (badWord.length > 2) {
            final replacement = badWord[0] +
                obscureSymbol * (badWord.length - 2) +
                badWord[badWord.length - 1];
            text = text.replaceAll(
                RegExp(r'\b' + badWord + r'\b', caseSensitive: false),
                replacement);
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
      throw ArgumentError(
          "extraWords can't be null for usingDefaultWords = false");
    } else if (useDefaultWords == false && extraWords != null) {
      if (excludedWords != null &&
          _hasCommonString(excludedWords, extraWords)) {
        throw ArgumentError(
            "Can't have same words in excludedWords and extraWords");
      } else {
        allWords = [...extraWords];
      }
    } else {
      if (extraWords != null) {
        if (excludedWords != null &&
            _hasCommonString(excludedWords, extraWords)) {
          throw ArgumentError(
              "Can't have same words in excludedWords and extraWords");
        } else if (excludedWords != null) {
          allWords = [...badWords];
          for (var word in excludedWords) {
            if (allWords.contains(word)) {
              allWords.remove(word);
            }
          }
          allWords.addAll(extraWords);
        } else {
          allWords = [...badWords, ...extraWords];
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
      final badWordPattern =
          RegExp(r'\b' + RegExp.escape(badWord) + r'\b', caseSensitive: false);
      if (badWordPattern.hasMatch(text)) {
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
            phoneNumberBuffer.write(digitToRepeat * multiplier);
          }
        }
      }
    }

    String potentialPhoneNumber = phoneNumberBuffer.toString();
    return potentialPhoneNumber.length >= minLength &&
        potentialPhoneNumber.length <= maxLength;
  }
}

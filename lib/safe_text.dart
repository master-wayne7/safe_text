library safe_text;

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
      if (text.toLowerCase().contains(badWord.toLowerCase())) {
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
}

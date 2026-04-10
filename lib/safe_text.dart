export 'src/models/language.dart';
export 'src/models/mask_strategy.dart';
export 'src/safe_text_filter.dart';
export 'src/phone_number_checker.dart';

// Maintaining backwards compatibility by redirecting original `SafeText` to the new implementations
import 'src/models/mask_strategy.dart';
import 'src/safe_text_filter.dart';
import 'src/phone_number_checker.dart';

/// Legacy facade that delegates to [SafeTextFilter] and [PhoneNumberChecker].
///
/// > **Deprecated.** Use [SafeTextFilter] and [PhoneNumberChecker] directly.
/// > They offer better modularity, higher performance via the Aho-Corasick
/// > trie, and explicit initialization via [SafeTextFilter.init].
///
/// Migration guide:
///
/// | Old call | New call |
/// |---|---|
/// | `SafeText.filterText(...)` | `SafeTextFilter.filterText(...)` |
/// | `SafeText.containsBadWord(...)` | `SafeTextFilter.containsBadWord(...)` |
/// | `SafeText.containsPhoneNumber(...)` | `PhoneNumberChecker.containsPhoneNumber(...)` |
@Deprecated(
    'Use SafeTextFilter and PhoneNumberChecker directly for better modularity and high performance.')
class SafeText {
  /// Filters profanity from [text].
  ///
  /// > **Deprecated.** Use [SafeTextFilter.filterText] instead.
  @Deprecated('Use SafeTextFilter.filterText instead.')
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
    return SafeTextFilter.filterText(
      text: text,
      extraWords: extraWords,
      excludedWords: excludedWords,
      useDefaultWords: useDefaultWords,
      fullMode: fullMode,
      obscureSymbol: obscureSymbol,
      strategy: strategy,
    );
  }

  /// Returns `true` if [text] contains a bad word.
  ///
  /// > **Deprecated.** Use [SafeTextFilter.containsBadWord] instead.
  @Deprecated('Use SafeTextFilter.containsBadWord instead.')
  static Future<bool> containsBadWord({
    required String text,
    List<String>? extraWords,
    List<String>? excludedWords,
    bool useDefaultWords = true,
  }) async {
    return SafeTextFilter.containsBadWord(
      text: text,
      extraWords: extraWords,
      excludedWords: excludedWords,
      useDefaultWords: useDefaultWords,
    );
  }

  /// Returns `true` if [text] contains a phone number.
  ///
  /// > **Deprecated.** Use [PhoneNumberChecker.containsPhoneNumber] instead.
  @Deprecated('Use PhoneNumberChecker.containsPhoneNumber instead.')
  static Future<bool> containsPhoneNumber({
    required String text,
    int minLength = 7,
    int maxLength = 15,
  }) async {
    return PhoneNumberChecker.containsPhoneNumber(
      text: text,
      minLength: minLength,
      maxLength: maxLength,
    );
  }
}

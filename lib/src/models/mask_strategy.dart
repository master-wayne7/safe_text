/// The default character used to mask profanity in [FullMask] and [PartialMask] strategies.
const kDefaultObscureSymbol = '*';

/// The default replacement string used by [CustomMask] when no custom value is provided.
const kDefaultReplacement = '[censored]';

/// Controls how detected profanity is masked in filtered text.
///
/// Three strategies are available:
/// - [MaskStrategy.full] — replaces every character with the obscure symbol.
/// - [MaskStrategy.partial] — keeps the first character visible and masks the rest;
///   for words with 4+ characters, also keeps the last character visible.
/// - [MaskStrategy.custom] — replaces the entire word with a custom string.
sealed class MaskStrategy {
  const MaskStrategy();

  /// Replaces every character with [obscureSymbol].
  ///
  /// Example: `"badass"` → `"******"`
  const factory MaskStrategy.full({String obscureSymbol}) = FullMask;

  /// Keeps the first character visible and masks the rest. For words with
  /// 4 or more characters, also keeps the last character visible.
  /// Single-character matches are fully replaced with the obscure symbol.
  ///
  /// Examples:
  /// - `"damn"` → `"d**n"` (4+ letters: first & last visible)
  /// - `"ass"` → `"a**"` (2–3 letters: first visible only)
  /// - `"x"` → `"*"` (1 letter: fully masked)
  const factory MaskStrategy.partial({String obscureSymbol}) = PartialMask;

  /// Replaces the entire matched word with [replacement].
  ///
  /// Defaults to `"[censored]"` if no replacement is provided.
  ///
  /// Example: `"badass"` → `"[censored]"`
  const factory MaskStrategy.custom({String replacement}) = CustomMask;
}

/// Masks every character of the matched word with [obscureSymbol].
class FullMask extends MaskStrategy {
  /// The character used to replace each letter of the matched word.
  final String obscureSymbol;

  const FullMask({this.obscureSymbol = kDefaultObscureSymbol});
}

/// Partially masks the matched word, keeping the first character visible.
/// For words with 4+ characters, also keeps the last character visible.
class PartialMask extends MaskStrategy {
  /// The character used to replace masked letters.
  final String obscureSymbol;

  const PartialMask({this.obscureSymbol = kDefaultObscureSymbol});
}

/// Replaces the entire matched word with a fixed [replacement] string.
class CustomMask extends MaskStrategy {
  /// The string that replaces the matched word.
  final String replacement;

  const CustomMask({this.replacement = kDefaultReplacement});
}

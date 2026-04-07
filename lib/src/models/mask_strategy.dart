/// The default character used to mask profanity in [FullMask] and [PartialMask] strategies.
const kDefaultObscureSymbol = '*';

/// The default replacement string used by [CustomMask] when no custom value is provided.
const kDefaultReplacement = '[censored]';

/// {@template obscure_symbol_constraint}
/// [obscureSymbol] must be exactly one character (e.g. `'*'`, `'#'`, `'X'`),
/// defaults to [kDefaultObscureSymbol].
/// {@endtemplate}
///
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
  /// {@macro obscure_symbol_constraint}
  ///
  /// Example: `"badass"` → `"******"`
  const factory MaskStrategy.full({String obscureSymbol}) = FullMask;

  /// Keeps the first character visible and masks the rest. For words with
  /// 4 or more characters, also keeps the last character visible.
  /// Single-character matches are fully replaced with the obscure symbol.
  ///
  /// {@macro obscure_symbol_constraint}
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

/// Base class for strategies that mask with a single [obscureSymbol] character.
///
/// {@macro obscure_symbol_constraint}
sealed class ObscureSymbolStrategy extends MaskStrategy {
  /// {@macro obscure_symbol_constraint}
  final String obscureSymbol;

  const ObscureSymbolStrategy({this.obscureSymbol = kDefaultObscureSymbol})
      : assert(obscureSymbol.length == 1,
            'obscureSymbol must be a single character');
}

/// Masks every character of the matched word with [obscureSymbol].
///
/// {@macro obscure_symbol_constraint}
class FullMask extends ObscureSymbolStrategy {
  const FullMask({super.obscureSymbol});
}

/// Partially masks the matched word, keeping the first character visible.
/// For words with 4+ characters, also keeps the last character visible.
///
/// {@macro obscure_symbol_constraint}
class PartialMask extends ObscureSymbolStrategy {
  const PartialMask({super.obscureSymbol});
}

/// Replaces the entire matched word with a fixed [replacement] string.
class CustomMask extends MaskStrategy {
  /// The string that replaces the matched word.
  final String replacement;

  const CustomMask({this.replacement = kDefaultReplacement});
}

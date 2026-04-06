<p align="center">
  <img src="https://raw.githubusercontent.com/master-wayne7/safe_text/refs/heads/main/assets/image/safeText.png" alt="SafeText Banner">
</p>

<p align="center">
  <a href="https://pub.dev/packages/safe_text"><img src="https://img.shields.io/pub/v/safe_text.svg" alt="pub version"></a>
  <a href="https://pub.dev/packages/safe_text"><img src="https://img.shields.io/pub/likes/safe_text?logo=flutter" alt="pub likes"></a>
  <a href="https://pub.dev/packages/safe_text/score"><img src="https://img.shields.io/pub/points/safe_text?logo=flutter" alt="pub points"></a>
  <a href="https://github.com/master-wayne7/safe_text/actions"><img src="https://github.com/master-wayne7/safe_text/actions/workflows/ci.yml/badge.svg" alt="CI"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT license"></a>
</p>

<p align="center">
  <a href="https://pub.dev/packages/safe_text"><img src="https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20linux%20%7C%20windows-lightgrey" alt="platforms"></a>
</p>

A high-performance Flutter package for filtering offensive language (profanity) and detecting phone numbers. Powered by the **Aho-Corasick** algorithm for `O(N)` single-pass scanning across 75+ languages and 55,000+ curated words.

---

## Table of Contents

- [Table of Contents](#table-of-contents)
- [What's New in 2.0.0](#whats-new-in-200)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
  - [`SafeTextFilter.init`](#safetextfilterinit)
  - [`SafeTextFilter.filterText`](#safetextfilterfiltertext)
  - [`SafeTextFilter.containsBadWord`](#safetextfiltercontainsbadword)
  - [`PhoneNumberChecker.containsPhoneNumber`](#phonenumbercheckercontainsphonenumber)
- [Supported Languages](#supported-languages)
- [How it Works](#how-it-works)
- [Migrating from v1.x](#migrating-from-v1x)
- [Limitations](#limitations)
- [Contributing](#contributing)
- [Data Source](#data-source)
- [Authors](#authors)

---

## What's New in 2.0.0

- **Aho-Corasick Algorithm** — Near-instant multi-pattern search in `O(N)` complexity.
- **Up to 20x faster** than the legacy regex-loop approach.
- **75+ languages** — Full human-readable enum names (e.g., `Language.hindi`, `Language.spanish`).
- **Modular API** — `SafeTextFilter` for profanity, `PhoneNumberChecker` for phone numbers.
- **Memory efficient** — Single-pass string building via `StringBuffer`.
- **Leet-speak normalization** — Catches bypasses like `f@ck` or `b4d` with zero extra overhead.

---

## Features

- Scans thousands of bad words in a single pass of the input text.
- Catches common character substitutions: `@→a`, `4→a`, `3→e`, `0→o`, `$→s`, and more.
- Detects phone numbers in digits, words, mixed formats, and multiplier words (e.g., "triple five").
- Multiple masking strategies — full (`******`), partial (`f**k`), or custom replacement (`[censored]`).
- Customizable — add your own words or exclude specific phrases.
- Non-blocking — `PhoneNumberChecker` runs in a separate isolate via `compute`.
- Works on Android, iOS, Web, macOS, Linux, and Windows.

---

## Installation

Add `safe_text` to your project using the Flutter CLI:

```bash
flutter pub add safe_text
```

Or manually add it to your `pubspec.yaml`:

```yaml
dependencies:
  safe_text: ^2.0.1
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

```dart
import 'package:safe_text/safe_text.dart';

void main() async {
  // Initialize once at app startup
  await SafeTextFilter.init(language: Language.english);

  // Filter profanity (full masking — default)
  final clean = SafeTextFilter.filterText(text: "What the f@ck!");
  print(clean); // "What the ****!"

  // Partial masking — keeps first & last characters for 4+ letter words
  final partial = SafeTextFilter.filterText(
    text: "What the f@ck!",
    strategy: const MaskStrategy.partial(),
  );
  print(partial); // "What the f**k!"

  // Custom replacement
  final custom = SafeTextFilter.filterText(
    text: "What the f@ck!",
    strategy: const MaskStrategy.custom(replacement: '[redacted]'),
  );
  print(custom); // "What the [redacted]!"

  // Check for bad words
  final hasBad = await SafeTextFilter.containsBadWord(text: "Some bad input");
  print(hasBad); // true or false

  // Detect phone numbers
  final hasPhone = await PhoneNumberChecker.containsPhoneNumber(
    text: "Call me at nine 7 eight 3 triple four",
  );
  print(hasPhone); // true
}
```

---

## API Reference

### `SafeTextFilter.init`

Must be called **once** before using `filterText` or `containsBadWord`. Builds the Aho-Corasick trie from the selected word list(s).

```dart
// Single language
await SafeTextFilter.init(language: Language.english);

// Custom combination
await SafeTextFilter.init(languages: [Language.english, Language.hindi, Language.spanish]);

// All 75+ languages
await SafeTextFilter.init(language: Language.all);
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `language` | `Language?` | `Language.english` | A single language to load. Use `Language.all` to load every language. Ignored when `languages` is provided. |
| `languages` | `List<Language>?` | `null` | A custom list of languages. Takes precedence over `language`. |

> **Note:** If neither parameter is provided, the filter defaults to `Language.english`.

---

### `SafeTextFilter.filterText`

Synchronous. Returns the input text with matched bad words masked according to the chosen `MaskStrategy`.

```dart
// Full masking (default)
String result = SafeTextFilter.filterText(
  text: "Hello b4dass world!",
  extraWords: ["badterm"],      // optional: add custom words
  excludedWords: ["bass"],      // optional: never filter these
  useDefaultWords: true,        // use the built-in word list
);
// Result: "Hello ****** world!"

// Partial masking
String partial = SafeTextFilter.filterText(
  text: "Hello b4dass world!",
  strategy: const MaskStrategy.partial(),
);
// Result: "Hello b****s world!"

// Custom replacement
String custom = SafeTextFilter.filterText(
  text: "Hello b4dass world!",
  strategy: const MaskStrategy.custom(), // defaults to "[censored]"
);
// Result: "Hello [censored] world!"
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `text` | `String` | **required** | The input string to process. |
| `extraWords` | `List<String>?` | `null` | Additional words to filter on top of (or instead of) the built-in list. |
| `excludedWords` | `List<String>?` | `null` | Words that must never be filtered, even if they appear in the list. |
| `useDefaultWords` | `bool` | `true` | Include the built-in language word list. Set to `false` to use only `extraWords`. |
| `strategy` | `MaskStrategy?` | `null` (defaults to `MaskStrategy.full()`) | Masking strategy. See [Masking Strategies](#masking-strategies) below. |
| `fullMode` | `bool` | `true` | **Deprecated.** Use `strategy` instead. `true` maps to `MaskStrategy.full()`, `false` maps to `MaskStrategy.partial()`. |
| `obscureSymbol` | `String` | `*` | **Deprecated.** Pass `obscureSymbol` via `MaskStrategy.full()` or `MaskStrategy.partial()` instead. |

#### Masking Strategies

| Strategy | Constructor | Output Example | Description |
|---|---|---|---|
| Full | `MaskStrategy.full(obscureSymbol: '*')` | `badass` → `******` | Replaces every character with the obscure symbol. |
| Partial | `MaskStrategy.partial(obscureSymbol: '*')` | `fuck` → `f**k`, `ass` → `a**` | Keeps first character visible. For 4+ letter words, also keeps the last character. |
| Custom | `MaskStrategy.custom(replacement: '[censored]')` | `badass` → `[censored]` | Replaces the entire word with a fixed string. |

---

### `SafeTextFilter.containsBadWord`

Asynchronous. Returns `true` if the text contains at least one filtered word.

```dart
bool hasBadWord = await SafeTextFilter.containsBadWord(
  text: "Don't be a pendejo",
  extraWords: ["badterm"],   // optional
  excludedWords: ["pend"],   // optional
  useDefaultWords: true,     // optional
);
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `text` | `String` | **required** | The input string to check. |
| `extraWords` | `List<String>?` | `null` | Additional words to check against. |
| `excludedWords` | `List<String>?` | `null` | Words to ignore even if matched. |
| `useDefaultWords` | `bool` | `true` | Include the built-in word list in the check. |

---

### `PhoneNumberChecker.containsPhoneNumber`

Asynchronous. Runs in a **separate isolate** via Flutter's `compute` function so it never blocks the UI thread.

Detects phone numbers expressed as:
- Pure digits: `9783444`
- Word-based: `nine seven eight three four four four`
- Mixed: `9 seven 8 3444`
- Multiplier words: `nine seven eight three triple four`

Supported multiplier words: `double`, `triple`, `quadruple`, `quintuple`, `sextuple`, `septuple`, `octuple`, `nonuple`, `decuple`.

```dart
bool hasPhone = await PhoneNumberChecker.containsPhoneNumber(
  text: "Call me at nine 7 eight 3 triple four",
  minLength: 7,   // minimum digit count to be considered a phone number
  maxLength: 15,  // maximum digit count
);
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `text` | `String` | **required** | The input string to check. |
| `minLength` | `int` | `7` | Minimum number of digits for a valid phone number. |
| `maxLength` | `int` | `15` | Maximum number of digits for a valid phone number. |

---

## Supported Languages

Pass any of these `Language` enum values to `SafeTextFilter.init`. Use `Language.all` to load every language simultaneously.

<details>
<summary>View all 77 supported languages</summary>

| Enum | Language |
|---|---|
| `Language.afrikaans` | Afrikaans |
| `Language.amharic` | Amharic |
| `Language.arabic` | Arabic |
| `Language.azerbaijani` | Azerbaijani |
| `Language.belarusian` | Belarusian |
| `Language.bulgarian` | Bulgarian |
| `Language.catalan` | Catalan |
| `Language.cebuano` | Cebuano |
| `Language.czech` | Czech |
| `Language.welsh` | Welsh |
| `Language.danish` | Danish |
| `Language.german` | German |
| `Language.dzongkha` | Dzongkha |
| `Language.greek` | Greek |
| `Language.english` | English |
| `Language.esperanto` | Esperanto |
| `Language.spanish` | Spanish |
| `Language.estonian` | Estonian |
| `Language.basque` | Basque |
| `Language.persian` | Persian |
| `Language.finnish` | Finnish |
| `Language.filipino` | Filipino |
| `Language.french` | French |
| `Language.scottishGaelic` | Scottish Gaelic |
| `Language.galician` | Galician |
| `Language.hindi` | Hindi |
| `Language.croatian` | Croatian |
| `Language.hungarian` | Hungarian |
| `Language.armenian` | Armenian |
| `Language.indonesian` | Indonesian |
| `Language.icelandic` | Icelandic |
| `Language.italian` | Italian |
| `Language.japanese` | Japanese |
| `Language.kabyle` | Kabyle |
| `Language.kannada` | Kannada |
| `Language.khmer` | Khmer |
| `Language.korean` | Korean |
| `Language.latin` | Latin |
| `Language.lithuanian` | Lithuanian |
| `Language.latvian` | Latvian |
| `Language.maori` | Maori |
| `Language.macedonian` | Macedonian |
| `Language.malayalam` | Malayalam |
| `Language.mongolian` | Mongolian |
| `Language.marathi` | Marathi |
| `Language.malay` | Malay |
| `Language.maltese` | Maltese |
| `Language.burmese` | Burmese |
| `Language.dutch` | Dutch |
| `Language.norwegian` | Norwegian |
| `Language.norfuk` | Norfuk / Pitcairn |
| `Language.piapoco` | Piapoco |
| `Language.polish` | Polish |
| `Language.portuguese` | Portuguese |
| `Language.romanian` | Romanian |
| `Language.kriol` | Kriol |
| `Language.russian` | Russian |
| `Language.slovak` | Slovak |
| `Language.slovenian` | Slovenian |
| `Language.samoan` | Samoan |
| `Language.albanian` | Albanian |
| `Language.serbian` | Serbian |
| `Language.swedish` | Swedish |
| `Language.tamil` | Tamil |
| `Language.telugu` | Telugu |
| `Language.tetum` | Tetum |
| `Language.thai` | Thai |
| `Language.klingon` | Klingon |
| `Language.tongan` | Tongan |
| `Language.turkish` | Turkish |
| `Language.ukrainian` | Ukrainian |
| `Language.uzbek` | Uzbek |
| `Language.vietnamese` | Vietnamese |
| `Language.yiddish` | Yiddish |
| `Language.chinese` | Chinese |
| `Language.zulu` | Zulu |
| `Language.all` | All of the above |

</details>

---

## How it Works

**Legacy approach (v1.x):** For each bad word in a list of 10,000+ words, run a separate regex scan over the entire input — `O(W × N)` where W is the word count.

**v2.0.0 approach:** The Aho-Corasick algorithm builds a Finite State Automaton (Trie) once from the entire word list. The engine then scans the input **exactly once**, matching all patterns simultaneously in `O(N)` time where N is the length of the text — regardless of how many words are in the list.

```
Input text  ──► [Normalizer] ──► [Aho-Corasick FSA] ──► Match ranges ──► [StringBuffer] ──► Filtered text
                  (leet-speak)     (single O(N) pass)    (merged)         (single-pass)
```

---

## Migrating from v1.x

The original `SafeText` class is still available but marked `@Deprecated`. It internally delegates to the new classes. Migrate when ready:

| v1.x | v2.0.0 |
|---|---|
| `await SafeTextFilter.init(...)` | Required — call once at startup |
| `SafeText.filterText(text: ...)` | `SafeTextFilter.filterText(text: ...)` |
| `await SafeText.containsBadWord(text: ...)` | `await SafeTextFilter.containsBadWord(text: ...)` |
| `await SafeText.containsPhoneNumber(text: ...)` | `await PhoneNumberChecker.containsPhoneNumber(text: ...)` |

**Before:**
```dart
// v1.x — no init required, but slow
bool bad = await SafeText.containsBadWord(text: "some input");
```

**After:**
```dart
// v2.0.0 — init once, then use anywhere
await SafeTextFilter.init(language: Language.english); // once, e.g. in main()
bool bad = await SafeTextFilter.containsBadWord(text: "some input");
```

---

## Limitations

- **`SafeTextFilter.init` must be called before use.** Calling `filterText` or `containsBadWord` before `init` will fall back to a small built-in word list without the full multilingual dataset.
- **Phone number detection is English-word based.** Words like "nine", "triple", etc. are English only — the detector does not parse written numbers in other languages.
- **False positives on technical terms.** Short words in the filter list may match substrings of unrelated technical terms. Use `excludedWords` to suppress known false positives.
- **`Language.all` increases init time.** Loading all 75+ language files is I/O-heavy. For most apps a targeted language list is faster.

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for the full guidelines. The short version:

1. Clone the repo and check out the `develop` branch.
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Add tests for any new behaviour.
4. Run checks before submitting:
   ```bash
   flutter analyze
   flutter test
   ```
5. Open a pull request targeting `develop`. Ensure CI passes.

For major changes, please open an issue first to discuss the approach.

---

## Data Source

SafeText uses the [List of Dirty, Naughty, Obscene, and Otherwise Bad Words](https://github.com/LDNOOBWV2/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words_V2) dataset:

- **75+ dialects and languages**
- **55,000+ curated words**

We are grateful to the contributors of this dataset for providing a robust multilingual foundation.

---

## Authors

<p align="center">
  <a href="https://github.com/master-wayne7">
    <img src="https://github.com/master-wayne7.png" width="100" height="100" style="border-radius:50%" alt="Ronit Rameja">
    <br />
    <sub><b>Ronit Rameja</b></sub>
  </a>
</p>

<p align="center">
  <a href="https://www.linkedin.com/in/ronit-rameja-8a708b252/">LinkedIn</a> •
  <a href="https://github.com/master-wayne7/safe_text/issues">Report an Issue</a> •
  <a href="https://github.com/master-wayne7/safe_text/discussions">Discussions</a> •
  <a href="https://www.buymeacoffee.com/ronitrameja">Buy me a coffee</a>
</p>

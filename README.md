<p align="center">
  <img src="https://raw.githubusercontent.com/master-wayne7/safe_text/refs/heads/master/assets/image/safeText.png" alt="SafeText Banner">
</p>

Safe Text is a high-performance Flutter package designed to filter out offensive language (profanity) and detect phone numbers. Version 2.0.0 introduces a state-of-the-art **Aho-Corasick** engine for near-instant filtering across multiple languages.

## 🚀 What's New in 2.0.0
- **Aho-Corasick Algorithm**: Near-instant multi-pattern search (`O(N)` complexity).
- **Extreme Speed**: Up to 20x faster than legacy regex loops.
- **Multilingual Excellence**: Support for 75+ languages using full human-readable names.
- **Modular API**: Separate trackers for profanity (`SafeTextFilter`) and phone numbers (`PhoneNumberChecker`).
- **Memory Efficient**: Single-pass string building using `StringBuffer`.

## Features

- **Blazing Fast Profanity Filtering**: Scans thousands of bad words in a single pass of the text.
- **Advanced Normalization**: Catches common bypasses like `f@ck` or `b4dass` with zero overhead.
- **Comprehensive Phone Detection**: Detects numbers in digits, words, mixed formats, and repeats (e.g., "triple five").
- **Customizable**: Add your own extra words or exclude specific phrases.
- **Non-blocking**: Phone detection and heavy filtering can run in separate isolates.

## Getting started

Add `safe_text` to your `pubspec.yaml`:

```yaml
dependencies:
  safe_text: ^2.0.0
```

### 1. Profanity Filtering (`SafeTextFilter`)

The new `SafeTextFilter` class is the high-performance replacement for the legacy `SafeText` logic.

#### Initialization
Initialize with your desired language (defaults to English) to build the search Trie:

```dart
import 'package:safe_text/safe_text.dart';

void main() async {
  // Option 1: Initialize with a specific language
  await SafeTextFilter.init(language: Language.english);

  // Option 2: Initialize with a custom list of languages
  await SafeTextFilter.init(languages: [Language.english, Language.hindi, Language.spanish]);

  // Option 3: Initialize with ALL supported languages
  await SafeTextFilter.init(language: Language.all);
}
```

#### Filtering Text
```dart
String filtered = SafeTextFilter.filterText(
  text: "Hello b4dass!",
  extraWords: ["example"], // Optional
  excludedWords: ["friend"], // Optional
  useDefaultWords: true,
  fullMode: true,
  obscureSymbol: "*",
);
// Result: "Hello ******!"
```

#### Checking for Bad Words
```dart
bool hasBadWord = await SafeTextFilter.containsBadWord(
  text: "Don't be a pendejo",
);
```

### 2. Phone Number Detection (`PhoneNumberChecker`)

```dart
bool hasPhone = await PhoneNumberChecker.containsPhoneNumber(
  text: "Call me at nine 7 eight 3 triple four",
  minLength: 7,
  maxLength: 15,
);
```

### 3. Legacy Support (`SafeText`)
The original `SafeText` class is still available but marked as **@Deprecated**. It internally redirects to the new modular classes. We recommend migrating to the new API for a better developer experience.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `text` | `String` | **Required** | The input string to process. |
| `extraWords` | `List<String>?`| `null` | Add custom patterns to the filter list. |
| `excludedWords`| `List<String>?`| `null` | Phrases that should NOT be filtered. |
| `useDefaultWords`| `bool` | `true` | Include the built-in language patterns. |
| `fullMode` | `bool` | `true` | `true`: `****`, `false`: `f**k`. |
| `obscureSymbol`| `String` | `*` | Symbol used for obscuring. |

## Why is v2.0.0 so fast?

Legacy versions used a nested loop approach (for every bad word, run a regex). With 10,000+ words, this grew exponentially slow. 

**Aho-Corasick** builds a Finite State Automaton (Trie) from the word list. The engine then scans your text **exactly once**, matching all possible patterns simultaneously in `O(N)` time where N is the length of your text.

## Contributing

Pull requests are welcome. For major changes, please open an issue first.

## Data Source

SafeText uses the comprehensive [List of Dirty, Naughty, Obscene, and Otherwise Bad Words](https://github.com/LDNOOBWV2/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words_V2) repository. This dataset includes:
- **75+ Dialects/Languages**
- **55,000+ curated words**

We are grateful to the contributors of this dataset for providing a robust foundation for profanity filtering.

## Authors

<p align="center">
  <a href="https://github.com/master-wayne7">
    <img src="https://github.com/master-wayne7.png" width="100" height="100" style="border-radius:50%" alt="Ronit Rameja">
    <br />
    <sub><b>Ronit Rameja</b></sub>
  </a>
</p>

Connect on LinkedIn: [Ronit Rameja](https://www.linkedin.com/in/ronit-rameja-8a708b252/)

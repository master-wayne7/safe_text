## 2.1.2

### Added
- **5 new languages**: Bengali (`Language.bengali`), Gujarati (`Language.gujarati`), Punjabi (`Language.punjabi`), Swahili (`Language.swahili`), and Urdu (`Language.urdu`).
- Language count now reaches **82 supported languages** (including `Language.all`).

## 2.1.1

### Changed
- Refactored `FullMask` and `PartialMask` to extend a shared `ObscureSymbolStrategy` base class, eliminating duplicated `obscureSymbol` field logic.
- Added assertion that `obscureSymbol` must be exactly one character, giving a clear error message on misuse.

## 2.1.0

### Added
- **`MaskStrategy` API**: New sealed class with three strategies for controlling how profanity is masked:
  - `MaskStrategy.full({obscureSymbol})` — replaces every character (e.g. `"badass"` → ``"******"`).
  - `MaskStrategy.partial({obscureSymbol})` — keeps first (and last, for 4+ char words) visible (e.g. `"damn"` → `"d**n"`).
  - `MaskStrategy.custom({replacement})` — replaces the entire word with a fixed string (e.g. `"[censored]"`).
- `strategy` parameter on `SafeTextFilter.filterText` and the deprecated `SafeText.filterText` to accept a `MaskStrategy`.

### Changed
- Legacy `fullMode` and `obscureSymbol` parameters on `filterText` are now deprecated in favour of `MaskStrategy`. Existing call sites continue to work unchanged.
- `MaskStrategy` is exported from the top-level `safe_text.dart` barrel file.

## 2.0.1

### Documentation
- Rewrote README with pub.dev badges, full API reference tables, supported languages list, migration guide from v1.x, How it Works section, and Limitations section.
- Fixed CHANGELOG entries for 1.0.5–1.0.7: corrected `Added` category to `Fixed`/`Changed` for bug fix and refactor entries.

## 2.0.0

### Added
- **Aho-Corasick Engine**: Replaced legacy regex loops with a high-performance Trie-based search engine for `O(N)` search complexity.
- **Extreme Performance**: Up to 20x faster for large pattern sets and mixed language inputs.
- **Flexible Initialization**: `SafeTextFilter.init` now supports either a single `language` or a list of `languages` for custom combinations.
- **Multilingual Support**: Support for 75+ languages with full names (e.g., `Language.english`, `Language.hindi`).
- **Modular API**: Separated functionality into `SafeTextFilter` for profanity and `PhoneNumberChecker` for phone detection.
- **Single-Pass Replacement**: Optimized string building avoids multiple copies during filtering.

### Deprecated
- **SafeText Class**: The monolithic `SafeText` class is now deprecated. Use `SafeTextFilter` and `PhoneNumberChecker` directly for better performance and modularity.

## 1.0.8

### Added

- Added support for detecting phone numbers with repeated digits using multiplier words (e.g., "double five" → "55", "triple four" → "444").

## 1.0.7

### Fixed

- Improved time complexity of the phone number detector.

## 1.0.6

### Fixed

- Fixed the filtering and matching function.

## 1.0.5

### Changed

- Moved the phone number checker into an isolate to avoid blocking the main thread.


## 1.0.4

### Added

- A method to check whether the given String contains any phone number or not both in words and digits and in mixed format also.


## 1.0.3

### Added

- A method to check whether the given String contains any bad words or not. Process will run in new thread to avoid blocking of main thread. 


## 1.0.2

### Added

- Made some changes in formatting.


## 1.0.1

### Added

- Made some changes in documentation.


## 1.0.0

### Published

- Initial release of the BadWordFilter package.
- Implemented the `SafeText` class with the `filterText` method for filtering out bad words from text inputs.
- Provided customizable options for filtering bad words, including extraWords, excludedWords, useDefaultWords, fullMode, and obscureSymbol.
- Included an example Flutter app demonstrating the usage of the BadWordFilter package.
- Added a README.md file with instructions on getting started, usage, example, and author information.

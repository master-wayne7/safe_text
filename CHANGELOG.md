## 1.0.7

### Added

- Fixed the time complexity of phone number detector.
  
## 1.0.6

### Added

- Fixed the filtering aur matching function.

## 1.0.5

### Added

- Moved the phone number checker in an isolate to aboid blocking of main thread.


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

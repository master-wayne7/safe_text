import 'package:flutter_test/flutter_test.dart';

import 'package:safe_text/safe_text.dart';

void main() {
  group("safe text class method filter text", () {
    test('will filter completely when fullMode  = true', () {
      expect(SafeText.filterText(text: "Hello badass how you doing anal impaler"), "Hello ****** how you doing ************");
    });
    test('will filter partially when fullMode  = false', () {
      expect(SafeText.filterText(text: "Hello badass how you doing anal impaler", fullMode: false), "Hello b****s how you doing a**********r");
    });
    test('will throw error when user sets use default words to false and dosen\'t passes extra words', () {
      expect(() => SafeText.filterText(text: "Hello badass how you doing anal impaler", fullMode: false, useDefaultWords: false), throwsA(isA<AssertionError>()));
    });
    test('will throw error when user sets use default words to true and passes any word common in extra words and excluded words', () {
      expect(
          () => SafeText.filterText(text: "Hello badass how you doing anal impaler", fullMode: false, useDefaultWords: false, extraWords: [
                "hello",
                "123"
              ], excludedWords: [
                "hello"
              ]),
          throwsA(isA<AssertionError>()));
    });
    test('will throw error when user passes any word common in extra words and excluded words', () {
      expect(
          () => SafeText.filterText(text: "Hello badass how you doing anal impaler", fullMode: false, extraWords: [
                "hello",
                "123"
              ], excludedWords: [
                "hello"
              ]),
          throwsA(isA<AssertionError>()));
    });
    test('will exclude the bad words passed in excludedBadWords', () {
      expect(
          SafeText.filterText(text: "Hello badass how you doing anal impaler", excludedWords: [
            "badass"
          ]),
          "Hello badass how you doing ************");
    });
  });
}

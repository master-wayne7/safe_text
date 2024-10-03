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
    test('will check for bad words', () async {
      String textWithBadWord = "This is a badass example";
      String cleanText = "This is a clean example";

      bool containsBadWord = await SafeText.containsBadWord(text: textWithBadWord);
      bool noBadWord = await SafeText.containsBadWord(text: cleanText);

      expect(containsBadWord, true);
      expect(noBadWord, false);
    });

    test('will check for bad words with extra words', () async {
      String textWithCustomBadWord = "This is an inappropriate word example";
      String cleanText = "This is another clean example";

      bool containsCustomBadWord = await SafeText.containsBadWord(
        text: textWithCustomBadWord,
        extraWords: [
          'inappropriate'
        ],
      );
      bool noBadWord = await SafeText.containsBadWord(text: cleanText);

      expect(containsCustomBadWord, true);
      expect(noBadWord, false);
    });
  });
  group('Ssfe text class method phone number detector ', () {
    test('will return invalid if there is phone number in text', () {
      String textWithPhone = "Contact me at 9876543210";
      expect(
        SafeText.containsPhoneNumber(
          text: textWithPhone,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return invalid if number is there in words', () {
      String textWithWordPhone = "My number is nine eight seven six five four three two one zero";
      expect(
        SafeText.containsPhoneNumber(
          text: textWithWordPhone,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return valid if length is less than min', () {
      String shortPhone = "Call me at 123456";
      expect(
        SafeText.containsPhoneNumber(
          text: shortPhone,
          minLength: 7,
          maxLength: 15,
        ),
        false,
      );
    });

    test('will retrun valid if length more than max', () {
      String longPhone = "My international number is 1234567890123456";
      expect(
        SafeText.containsPhoneNumber(
          text: longPhone,
          minLength: 7,
          maxLength: 15,
        ),
        false,
      );
    });

    test('will return valid if no phone number', () {
      String textWithoutPhone = "I don't have a valid phone number in this sentence.";
      expect(
        SafeText.containsPhoneNumber(
          text: textWithoutPhone,
          minLength: 7,
          maxLength: 15,
        ),
        false,
      );
    });

    test('will return invalid if phone number at boundary minLength', () {
      String textWithMinLengthPhone = "Call at 1234567";
      expect(
        SafeText.containsPhoneNumber(
          text: textWithMinLengthPhone,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return invalid if number length is between bracket', () {
      String textWithMaxLengthPhone = "International contact: 123456789012345";
      expect(
        SafeText.containsPhoneNumber(
          text: textWithMaxLengthPhone,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return invalid if number length is between bracket for words', () {
      String complexWordPhone = "You can call me at one two three four five six seven eight nine zero";
      expect(
        SafeText.containsPhoneNumber(
          text: complexWordPhone,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return valid if number length is less than min', () {
      String partialWordPhone = "My number is nine eight seven";
      expect(
        SafeText.containsPhoneNumber(
          text: partialWordPhone,
          minLength: 7,
          maxLength: 15,
        ),
        false,
      );
    });
    test('will return invalid if mixed format phone number (digits and words)', () {
      String mixedPhoneNumber = "Call me at nine eight seven 65 43210";
      expect(
        SafeText.containsPhoneNumber(
          text: mixedPhoneNumber,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return invalid if mixed format with numbers in words and digits', () {
      String mixedPhoneNumber = "My number is nine eight seven 654 three two one zero";
      expect(
        SafeText.containsPhoneNumber(
          text: mixedPhoneNumber,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return valid if incomplete mixed phone number', () {
      String incompleteMixedPhoneNumber = "My number is nine eight seven six";
      expect(
        SafeText.containsPhoneNumber(
          text: incompleteMixedPhoneNumber,
          minLength: 7,
          maxLength: 15,
        ),
        false,
      );
    });

    test('will return invalid if phone number with mixed format and special characters', () {
      String mixedPhoneWithSpecialChars = "Reach me at 9-eight-7-six five 4 3210!";
      expect(
        SafeText.containsPhoneNumber(
          text: mixedPhoneWithSpecialChars,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:safe_text/src/phone_number_checker.dart';

void main() {
  group('PhoneNumberChecker tests', () {
    test('will return invalid if there is phone number in text', () async {
      String textWithPhone = "Contact me at 9876543210";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: textWithPhone,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return invalid if number is there in words', () async {
      String textWithWordPhone =
          "My number is nine eight seven six five four three two one zero";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: textWithWordPhone,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return valid if length is less than min', () async {
      String shortPhone = "Call me at 123456";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: shortPhone,
          minLength: 7,
          maxLength: 15,
        ),
        false,
      );
    });

    test('will retrun valid if length more than max', () async {
      String longPhone = "My international number is 1234567890123456";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: longPhone,
          minLength: 7,
          maxLength: 15,
        ),
        false,
      );
    });

    test('will return valid if no phone number', () async {
      String textWithoutPhone =
          "I don't have a valid phone number in this sentence.";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: textWithoutPhone,
          minLength: 7,
          maxLength: 15,
        ),
        false,
      );
    });

    test('will return invalid if phone number at boundary minLength', () async {
      String textWithMinLengthPhone = "Call at 1234567";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: textWithMinLengthPhone,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return invalid if number length is between bracket', () async {
      String textWithMaxLengthPhone = "International contact: 123456789012345";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: textWithMaxLengthPhone,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return invalid if number length is between bracket for words',
        () async {
      String complexWordPhone =
          "You can call me at one two three four five six seven eight nine zero";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: complexWordPhone,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return valid if number length is less than min', () async {
      String partialWordPhone = "My number is nine eight seven";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: partialWordPhone,
          minLength: 7,
          maxLength: 15,
        ),
        false,
      );
    });

    test('will return invalid if mixed format phone number (digits and words)',
        () async {
      String mixedPhoneNumber = "Call me at nine eight seven 65 43210";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: mixedPhoneNumber,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return invalid if mixed format with numbers in words and digits',
        () async {
      String mixedPhoneNumber =
          "My number is nine eight seven 654 three two one zero";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: mixedPhoneNumber,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return valid if incomplete mixed phone number', () async {
      String incompleteMixedPhoneNumber = "My number is nine eight seven six";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: incompleteMixedPhoneNumber,
          minLength: 7,
          maxLength: 15,
        ),
        false,
      );
    });

    test(
        'will return invalid if phone number with mixed format and special characters',
        () async {
      String mixedPhoneWithSpecialChars =
          "Reach me at 9-eight-7-six five 4 3210!";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: mixedPhoneWithSpecialChars,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test(
        'will return invalid if phone number contains multiplier words like double and triple',
        () async {
      String phoneWithMultipliers = "My number is nine 7 eight 3 triple four";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: phoneWithMultipliers,
          minLength: 7,
          maxLength: 15,
        ),
        true,
      );
    });

    test('will return valid if multiplier word without following number',
        () async {
      String textWithOnlyMultiplier = "I said double but no number after";
      expect(
        await PhoneNumberChecker.containsPhoneNumber(
          text: textWithOnlyMultiplier,
          minLength: 7,
          maxLength: 15,
        ),
        false,
      );
    });
  });
}

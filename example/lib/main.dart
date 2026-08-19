import 'dart:io';

import 'package:safe_text/safe_text.dart';

Future<void> main() async {
  SafeTextFilter.init(language: Language.english);

  stdout.writeln('SafeText — Dart CLI demo');
  stdout.writeln('Profanity filtering + bad-word and phone-number detection.');
  stdout.writeln('Type a sentence and press Enter. Press Enter on an empty');
  stdout.writeln('line or type "quit" to exit.');
  stdout.writeln();

  const sample = 'This is a shitty example with 123-456-7890.';
  stdout.writeln('Sample text : $sample');
  stdout.writeln('Full mask   : '
      '${SafeTextFilter.filterText(text: sample, strategy: MaskStrategy.full())}');
  stdout.writeln('Partial mask: '
      '${SafeTextFilter.filterText(text: sample, strategy: MaskStrategy.partial())}');
  stdout.writeln('Custom mask : '
      '${SafeTextFilter.filterText(text: sample, strategy: MaskStrategy.custom(replacement: '[censored]'))}');
  stdout.writeln();
  stdout.writeln('Now type your own input:');
  stdout.writeln();

  while (true) {
    stdout.write('> ');
    final line = stdin.readLineSync();
    if (line == null) break;

    final input = line.trim();
    if (input.isEmpty || input.toLowerCase() == 'quit') break;

    final filtered = SafeTextFilter.filterText(text: input);
    final hasBadWord = SafeTextFilter.containsBadWord(text: input);
    final hasPhoneNumber =
        await PhoneNumberChecker.containsPhoneNumber(text: input);

    stdout.writeln('Filtered      : $filtered');
    stdout.writeln('Contains bad word  : ${hasBadWord ? 'yes' : 'no'}');
    stdout.writeln('Contains phone no. : ${hasPhoneNumber ? 'yes' : 'no'}');
    stdout.writeln();
  }

  stdout.writeln('Goodbye!');
}

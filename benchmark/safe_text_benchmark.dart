// Benchmarks for safe_text. Compile AOT for stable numbers:
//
//   dart compile exe benchmark/safe_text_benchmark.dart -o bench.exe
//   ./bench.exe
//
// Reports the median time per operation over several rounds.
import 'package:safe_text/safe_text.dart';

const _rounds = 7;

void main() async {
  const shortText =
      'Hey, that was a badass move but you are such a b4dass idiot, honestly.';
  const cleanText =
      'The quick brown fox jumps over the lazy dog near the river bank today.';
  final longText = ('You are a b4dass friend, honestly. No p3nd3j0 behavior '
          'here. Don\'t be a ku++a. French: m3rd3. German: @rschloch. '
          'Italian: str0nz0. A vivid, vivacious, very clean sentence. ') *
      100;

  print('safe_text benchmark (median of $_rounds rounds)\n');

  _report('init(english)', 20, () {
    SafeTextFilter.reset();
    SafeTextFilter.init(language: Language.english);
  });
  _report('init(all)', 3, () {
    SafeTextFilter.reset();
    SafeTextFilter.init(language: Language.all);
  });

  for (final lang in [Language.english, Language.all]) {
    SafeTextFilter.init(language: lang);
    final name = lang.name;
    _report('filterText short ($name)', 20000,
        () => SafeTextFilter.filterText(text: shortText));
    _report('filterText clean ($name)', 20000,
        () => SafeTextFilter.filterText(text: cleanText));
    _report('containsBadWord short ($name)', 20000,
        () => SafeTextFilter.containsBadWord(text: shortText));
    _report('filterText long ${longText.length} chars ($name)', 50,
        () => SafeTextFilter.filterText(text: longText));
  }

  // A messy chat message: numbers, number words, multipliers and separators.
  const complexChat = 'Order #4521 for 3 items (2 large, 1 small) at 7:45pm, '
      'call me on nine eight seven double six 5-4-3 or +1 (555) 012-3456, '
      'flat 12B, PIN 560034, born 1990, triple seven lucky!! ';
  final phoneInputs = {
    'short (${shortText.length} chars)': shortText,
    'complex chat (${complexChat.length} chars)': complexChat,
    'complex x50 (${complexChat.length * 50} chars)': complexChat * 50,
    'complex x500 (${complexChat.length * 500} chars)': complexChat * 500,
  };
  for (final MapEntry(:key, :value) in phoneInputs.entries) {
    await _reportAsync(
        'containsPhoneNumber $key',
        value.length > 10000 ? 20 : 200,
        () => PhoneNumberChecker.containsPhoneNumber(text: value));
  }
}

void _report(String name, int iterations, void Function() body) {
  for (int i = 0; i < iterations ~/ 10 + 1; i++) {
    body(); // warm-up
  }
  final samples = <double>[];
  for (int r = 0; r < _rounds; r++) {
    final sw = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      body();
    }
    samples.add(sw.elapsedMicroseconds / iterations);
  }
  _print(name, samples);
}

Future<void> _reportAsync(
    String name, int iterations, Future<Object?> Function() body) async {
  for (int i = 0; i < iterations ~/ 10 + 1; i++) {
    await body(); // warm-up
  }
  final samples = <double>[];
  for (int r = 0; r < _rounds; r++) {
    final sw = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      await body();
    }
    samples.add(sw.elapsedMicroseconds / iterations);
  }
  _print(name, samples);
}

void _print(String name, List<double> samples) {
  samples.sort();
  final median = samples[samples.length ~/ 2];
  final formatted = median >= 1000
      ? '${(median / 1000).toStringAsFixed(2)} ms'
      : '${median.toStringAsFixed(2)} µs';
  print('${name.padRight(48)} $formatted');
}

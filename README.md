<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

Safe Text is a Flutter package designed to filter out offensive and abusive language from text inputs within your application. With its easy-to-use interface, you can integrate powerful profanity filtering capabilities to ensure a safer and more inclusive user experience. Simply integrate BadWordFilter into your Flutter project to automatically detect and replace inappropriate language with asterisks (\*) or customize it to suit your application's needs.

## Features

- **Profanity Filtering**: Automatically detects and filters out offensive language from text inputs.
- **Customizable**: Customize the filtering behavior and replacement characters to suit your application's requirements.
- **Easy Integration**: Simple integration with Flutter projects, making it seamless to implement the profanity filtering functionality.
- **Enhanced User Experience**: Promotes a safer and more inclusive user experience by removing inappropriate language from text inputs.

## Getting started

To use the `SafeText` class for filtering out bad words from your text inputs, follow these steps:

1. Add the BadWordFilter package to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     safe_text: ^0.0.2 # Replace with the latest version
   ```

2. Import the package in your Dart file:

   ```dart
   import 'package:safe_text/safe_text.dart';
   ```

3. Use the `filterText` method to filter out bad words from your text inputs. Here's an example of how to use it:

   ```dart
   String filteredText = SafeText.filterText(
     text: "Your input text here",
     extraWords: ["extra", "bad", "words"],
     excludedWords: ["exclude", "these", "words"],
     useDefaultWords: true,
     fullMode: true,
     obscureSymbol: "*",
   );
   ```

4. Parameters:

   - `text` (required): The text to be filtered.
   - `extraWords` (optional): List of extra bad words to filter out (defaults to the standard list of bad words).
   - `excludedWords` (optional): List of bad words that should not be filtered out.
   - `useDefaultWords` (optional): Whether to use the default list of bad words in addition to the extra words (defaults to `true`).
   - `fullMode` (optional): Whether to fully filter out the bad word or only obscure the middle part, leaving the first and last characters visible (defaults to `true`).
   - `obscureSymbol` (optional): The symbol used to obscure the bad word (defaults to `*`).

5. Enjoy a safer and more inclusive user experience by filtering out offensive language from your application's text inputs!

## Example

Check out the example below to see how to integrate the `SafeText` class into your Flutter app:

```dart
import 'package:flutter/material.dart';
import 'package:safe_text/safe_text.dart'; // Import the safe_text package

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'BadWordFilter Demo',
      home: SafeTextDemo(), // Set the home to SafeTextDemo widget
    );
  }
}

class SafeTextDemo extends StatefulWidget {
  const SafeTextDemo({super.key});

  @override
  State<SafeTextDemo> createState() => _SafeTextDemoState();
}

class _SafeTextDemoState extends State<SafeTextDemo> {
  String _textInput = ''; // Variable to store user input text

  // Method to filter out bad words from the user input
  void _filterText() {
    setState(() {
      // Call the filterText method from the SafeText class
      _textInput = SafeText.filterText(
        text: _textInput, // Pass the user input text
        extraWords: [
          'extra',
          'bad',
          'words'
        ], // Additional bad words to filter
        excludedWords: [
          'exclude',
          'these',
          'words'
        ], // Words to be excluded from filtering
        useDefaultWords: true, // Whether to use the default list of bad words
        fullMode: true, // Whether to fully filter out the bad word or only obscure the middle part
        obscureSymbol: '*', // Symbol used to obscure the bad word
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BadWordFilter Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  setState(() {
                    _textInput = value; // Update the user input text
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your text here...', // Placeholder text for the TextField
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _filterText, // Call _filterText method when button is pressed
                child: const Text('Filter Bad Words'), // Button text
              ),
              const SizedBox(height: 20),
              const Text(
                'Filtered Text:', // Text to display above the filtered text
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(_textInput), // Display the filtered text
            ],
          ),
        ),
      ),
    );
  }
}

```

# Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

# Authors

We are [Ronit Rameja](https://github.com/master-wayne7) and [Kunal Prajapat](https://github.com/TheKunal65), the developers behind this Flutter package. We're passionate about creating tools that make development easier and more enjoyable. If you have any questions, suggestions, or feedback, feel free to reach out. You can find us on LinkedIn [Ronit](https://www.linkedin.com/in/ronit-rameja-8a708b252/) and [Kunal](https://www.linkedin.com/in/kunal-prajapat-487079263/).

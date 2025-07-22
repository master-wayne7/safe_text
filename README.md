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

Safe Text is a Flutter package designed to filter out offensive and abusive language from text inputs within your application. With its easy-to-use interface, you can integrate powerful profanity filtering capabilities to ensure a safer and more inclusive user experience. Simply integrate SafeText into your Flutter project to automatically detect and replace inappropriate language with asterisks (\*) or customize it to suit your application's needs. The package also includes advanced phone number detection that supports various formats.

## Features

- **Profanity Filtering**: Automatically detects and filters out offensive language from text inputs.
- **Advanced Phone Number Detection**: Detects phone numbers in various formats including digits, words, mixed formats, and multiplier words.
- **Customizable**: Customize the filtering behavior and replacement characters to suit your application's requirements.
- **Easy Integration**: Simple integration with Flutter projects, making it seamless to implement the profanity filtering functionality.
- **Enhanced User Experience**: Promotes a safer and more inclusive user experience by removing inappropriate language from text inputs.
- **Multi-threaded Processing**: Phone number detection runs in separate isolates to avoid blocking the main thread.

## Getting started

To use the `SafeText` class for filtering out bad words from your text inputs, follow these steps:

1. Add the SafeText package to your `pubspec.yaml` file:

   ```yaml
   dependencies:
     safe_text: ^1.0.8 # Replace with the latest version
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
     excludedWords: ["exclude", "these"],
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

5. Use the `containsBadWord` method to check if your text contains any bad words. This method runs in a separate thread to avoid blocking the main thread.

   ```dart
   // Example usage of containsBadWord
   Future<void> checkTextForBadWords() async {
     bool containsBadWord = await SafeText.containsBadWord(
       text: "Your input text here",
       extraWords: ["extra", "bad", "words"], // Optional
       excludedWords: ["exclude", "these"], // Optional
       useDefaultWords: true, // Defaults to true
     );
   
     if (containsBadWord) {
       print("The text contains inappropriate content.");
     } else {
       print("The text is clean.");
     }
   }
   ```

6. Use the `containsPhoneNumber` method to check if your text contains any phone number, whether it's in digits, words, mixed formats, or with multiplier words. You can also specify the minimum and maximum length of the phone number.

   ```dart
   // Example usage of containsPhoneNumber for various formats
   void detectPhoneNumbers() {
     String text1 = "Call me at 987 six 543210";
     String text2 = "My number is nine eight seven six five four three two one zero";
     String text3 = "Contact: 1234 five six seven eight nine";
     String text4 = "My number is nine 7 eight 3 triple four";

     bool containsPhone1 = SafeText.containsPhoneNumber(
       text: text1,
       minLength: 7, // Minimum length for a valid phone number
       maxLength: 15, // Maximum length for a valid phone number
     );

     bool containsPhone2 = SafeText.containsPhoneNumber(
       text: text2,
       minLength: 7,
       maxLength: 15,
     );

     bool containsPhone3 = SafeText.containsPhoneNumber(
       text: text3,
       minLength: 7,
       maxLength: 15,
     );

     bool containsPhone4 = SafeText.containsPhoneNumber(
       text: text4,
       minLength: 7,
       maxLength: 15,
     );

     print(containsPhone1); // true, detects "9876543210"
     print(containsPhone2); // true, detects "9876543210"
     print(containsPhone3); // true, detects "123456789"
     print(containsPhone4); // true, detects "9783444" (triple four → 444)
   }

7. Enjoy a safer and more inclusive user experience by filtering out offensive language from your application's text inputs!

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
      title: 'SafeText Demo',
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
          'these'
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
        title: const Text('SafeText Demo'),
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

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

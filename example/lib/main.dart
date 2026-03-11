import 'package:flutter/material.dart';
import 'package:safe_text/safe_text.dart';

void main() async {
  // Ensure Flutter binding is initialized for asset loading
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-initialize with English by default
  await SafeTextFilter.init(language: Language.english);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeText 2.0 Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SafeTextDemo(),
    );
  }
}

class SafeTextDemo extends StatefulWidget {
  const SafeTextDemo({super.key});

  @override
  State<SafeTextDemo> createState() => _SafeTextDemoState();
}

class _SafeTextDemoState extends State<SafeTextDemo> {
  String _textInput = '';
  String _filteredText = '';
  bool _isLoading = false;

  final List<Language> _selectedLanguages = [Language.english];

  // We'll show a subset of common languages for the demo
  final List<Language> _displayLanguages = [
    Language.english,
    Language.hindi,
    Language.spanish,
    Language.french,
    Language.german,
    Language.italian,
  ];

  Future<void> _updateLanguages() async {
    setState(() => _isLoading = true);

    // Re-initialize with the selected list
    await SafeTextFilter.init(languages: _selectedLanguages);

    if (mounted) {
      setState(() => _isLoading = false);
      _filterText(); // Re-apply filter with new Trie
    }
  }

  void _filterText() {
    setState(() {
      _filteredText = SafeTextFilter.filterText(
        text: _textInput,
        fullMode: true,
        obscureSymbol: '*',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeText 2.0 (Aho-Corasick)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  "Select Languages to Filter:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _displayLanguages.map((lang) {
                    final isSelected = _selectedLanguages.contains(lang);
                    return FilterChip(
                      label: Text(
                          lang.name[0].toUpperCase() + lang.name.substring(1)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedLanguages.add(lang);
                          } else {
                            if (_selectedLanguages.length > 1) {
                              _selectedLanguages.remove(lang);
                            }
                          }
                        });
                        _updateLanguages();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _textInput = value;
                    });
                  },
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Type something with profanity...',
                    border: OutlineInputBorder(),
                    labelText: 'Input Text',
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _filterText,
                    icon: const Icon(Icons.filter_alt),
                    label: const Text('Filter Text'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Filtered Result:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Text(
                    _filteredText.isEmpty
                        ? "No filter applied yet."
                        : _filteredText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),
                const Divider(),
                const Text(
                  "Stats",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("Enabled Languages: ${_selectedLanguages.length}"),
                const Text("Algorithm: Aho-Corasick (O(N) Complexity)"),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Rebuilding search Trie...",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("This happens instantly via Aho-Corasick")
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

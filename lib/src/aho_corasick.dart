class TrieNode {
  final Map<int, TrieNode> children = {};
  TrieNode? fail;
  final List<String> outputs = [];
}

class AhoCorasick {
  final TrieNode _root = TrieNode();

  void addWord(String word) {
    if (word.isEmpty) return;
    TrieNode current = _root;
    final codeUnits = word.toLowerCase().runes.toList();
    for (final rune in codeUnits) {
      current = current.children.putIfAbsent(rune, () => TrieNode());
    }
    current.outputs.add(word.toLowerCase());
  }

  void buildFailureLinks() {
    final queue = <TrieNode>[];

    // Initialize root's children and put them in queue
    for (final child in _root.children.values) {
      child.fail = _root;
      queue.add(child);
    }

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      current.children.forEach((rune, child) {
        queue.add(child);
        TrieNode? failNode = current.fail;

        while (failNode != null && !failNode.children.containsKey(rune)) {
          failNode = failNode.fail;
        }

        if (failNode == null) {
          child.fail = _root;
        } else {
          child.fail = failNode.children[rune];
          if (child.fail != null) {
            child.outputs.addAll(child.fail!.outputs);
          }
        }
      });
    }
  }

  /// Finds all matches in the text.
  /// Returns a map where the key is the string index where the match ENDS
  /// and the value is a list of matching words.
  Map<int, List<String>> search(String text) {
    final matches = <int, List<String>>{};
    TrieNode? current = _root;
    final textLower = text.toLowerCase();
    final units = textLower.codeUnits;

    for (int i = 0; i < units.length; i++) {
      final rune = units[i];

      while (current != null && !current.children.containsKey(rune)) {
        current = current.fail;
      }

      if (current == null) {
        current = _root;
        continue;
      }

      current = current.children[rune]!;

      if (current.outputs.isNotEmpty) {
        matches.putIfAbsent(i, () => []).addAll(current.outputs);
      }
    }

    return matches;
  }
}

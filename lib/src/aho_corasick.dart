/// A single node in the Aho-Corasick trie.
///
/// Each node represents a prefix of one or more patterns that have been
/// inserted via [AhoCorasick.addWord].
class TrieNode {
  /// Maps a Unicode code point to the child [TrieNode] for that character.
  final Map<int, TrieNode> children = {};

  /// Failure (fallback) link — points to the node representing the longest
  /// proper suffix of the current path that is also a valid prefix in the trie.
  ///
  /// Set on all non-root nodes by [AhoCorasick.buildFailureLinks].
  TrieNode? fail;

  /// Patterns that terminate at this node.
  ///
  /// After [AhoCorasick.buildFailureLinks] is called, this list also includes
  /// patterns inherited from nodes reachable via [fail] links (the "dictionary
  /// suffix links" of the classic algorithm).
  final List<String> outputs = [];
}

/// An implementation of the Aho-Corasick multi-pattern string search algorithm.
///
/// Aho-Corasick finds all occurrences of a set of patterns in a text in a
/// single linear pass — O(n + m + z), where n is the text length, m is the
/// total length of all patterns, and z is the number of matches. This makes
/// it well-suited for profanity filtering with large word lists.
///
/// ## Usage
///
/// ```dart
/// final ac = AhoCorasick();
/// ac.addWord('bad');
/// ac.addWord('worse');
/// ac.buildFailureLinks(); // must be called before search
///
/// final matches = ac.search('this is bad and worse');
/// // {10: ['bad'], 20: ['worse']}
/// ```
///
/// **Important:** always call [buildFailureLinks] after adding all words and
/// before calling [search]. Omitting this step produces incorrect results.
class AhoCorasick {
  final TrieNode _root = TrieNode();

  /// Inserts [word] into the trie.
  ///
  /// The word is lowercased before insertion so that [search] can operate on
  /// pre-lowercased input. Empty strings are silently ignored.
  ///
  /// Call this for every pattern you want to detect, then call
  /// [buildFailureLinks] once before any calls to [search].
  void addWord(String word) {
    if (word.isEmpty) return;
    TrieNode current = _root;
    final codeUnits = word.toLowerCase().runes.toList();
    for (final rune in codeUnits) {
      current = current.children.putIfAbsent(rune, () => TrieNode());
    }
    current.outputs.add(word.toLowerCase());
  }

  /// Constructs failure links for all nodes in the trie using a BFS traversal.
  ///
  /// This is the preprocessing phase of the Aho-Corasick algorithm. It must
  /// be called **once**, after all words have been added via [addWord] and
  /// before any calls to [search].
  ///
  /// Failure links allow the search to fall back to the longest matching
  /// suffix instead of restarting from the root on a mismatch, which keeps
  /// the search complexity linear in the length of the input.
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

  /// Searches [text] for all patterns previously added via [addWord].
  ///
  /// Returns a [Map] where each key is the **zero-based end index** (inclusive)
  /// of a match within [text], and the corresponding value is the list of
  /// pattern strings that end at that position.
  ///
  /// The search is case-insensitive — [text] is lowercased internally before
  /// matching.
  ///
  /// [buildFailureLinks] must have been called before invoking this method.
  ///
  /// ```dart
  /// final ac = AhoCorasick()
  ///   ..addWord('he')
  ///   ..addWord('she')
  ///   ..addWord('hers')
  ///   ..buildFailureLinks();
  ///
  /// final result = ac.search('ushers');
  /// // Keys represent end indices; values are matched words at that position.
  /// ```
  ///
  /// Returns an empty map if no patterns match.
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

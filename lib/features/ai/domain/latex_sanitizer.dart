/// Converts LaTeX-heavy AI responses into plain, markdown-friendly text.
///
/// DeepSeek frequently ignores prompt instructions to avoid LaTeX when
/// answering math questions, so we strip and transform LaTeX constructs
/// deterministically before handing the content to the markdown renderer.
///
/// The sanitizer is lossy by design — it aims for readable plain text,
/// not faithful math typesetting.
class LatexSanitizer {
  LatexSanitizer._();

  static String sanitize(String input) {
    var text = input;

    // 1. Matrix environments — do this first, before any other backslash
    //    processing, because matrices use `\\` as row separators and `&`
    //    as cell separators.
    text = _convertMatrices(text);

    // 2. Display and inline math delimiters — strip them, keep content.
    //    \[ ... \]  →  content on its own paragraph
    //    \( ... \)  →  content inline
    text = text.replaceAllMapped(
      RegExp(r'\\\[(.*?)\\\]', dotAll: true),
      (m) => '\n${m.group(1)!.trim()}\n',
    );
    text = text.replaceAllMapped(
      RegExp(r'\\\((.*?)\\\)', dotAll: true),
      (m) => m.group(1)!.trim(),
    );

    // 3. Text-style wrappers: \text{foo} → foo, same for similar wrappers.
    text = text.replaceAllMapped(
      RegExp(r'\\(?:text|mathrm|mathbf|mathit|mathsf|operatorname)\{([^{}]*)\}'),
      (m) => m.group(1)!,
    );

    // 4. Fractions: \frac{a}{b} → (a/b). Run a few passes for simple nesting.
    final fracRe = RegExp(r'\\frac\s*\{([^{}]*)\}\s*\{([^{}]*)\}');
    for (var i = 0; i < 4 && fracRe.hasMatch(text); i++) {
      text = text.replaceAllMapped(
        fracRe,
        (m) => '(${m.group(1)}/${m.group(2)})',
      );
    }

    // 5. Square roots: \sqrt{x} → sqrt(x).
    text = text.replaceAllMapped(
      RegExp(r'\\sqrt\s*\{([^{}]*)\}'),
      (m) => 'sqrt(${m.group(1)})',
    );

    // 6. Greek letters (lowercase + capital) → word form.
    //    `var`-prefixed variants normalise to the base name.
    const greek = <String, String>{
      'alpha': 'alpha', 'beta': 'beta', 'gamma': 'gamma', 'delta': 'delta',
      'epsilon': 'epsilon', 'varepsilon': 'epsilon', 'zeta': 'zeta',
      'eta': 'eta', 'theta': 'theta', 'vartheta': 'theta', 'iota': 'iota',
      'kappa': 'kappa', 'lambda': 'lambda', 'mu': 'mu', 'nu': 'nu',
      'xi': 'xi', 'pi': 'pi', 'varpi': 'pi', 'rho': 'rho', 'varrho': 'rho',
      'sigma': 'sigma', 'varsigma': 'sigma', 'tau': 'tau', 'upsilon': 'upsilon',
      'phi': 'phi', 'varphi': 'phi', 'chi': 'chi', 'psi': 'psi', 'omega': 'omega',
      'Alpha': 'Alpha', 'Beta': 'Beta', 'Gamma': 'Gamma', 'Delta': 'Delta',
      'Epsilon': 'Epsilon', 'Zeta': 'Zeta', 'Eta': 'Eta', 'Theta': 'Theta',
      'Iota': 'Iota', 'Kappa': 'Kappa', 'Lambda': 'Lambda', 'Mu': 'Mu',
      'Nu': 'Nu', 'Xi': 'Xi', 'Pi': 'Pi', 'Rho': 'Rho', 'Sigma': 'Sigma',
      'Tau': 'Tau', 'Upsilon': 'Upsilon', 'Phi': 'Phi', 'Chi': 'Chi',
      'Psi': 'Psi', 'Omega': 'Omega',
    };
    greek.forEach((cmd, word) {
      text = text.replaceAll(RegExp('\\\\$cmd\\b'), word);
    });

    // 7. Common math operators and symbols → plain ASCII.
    //    Listed longest-first so e.g. `\cdots` is handled before `\cdot`.
    //    Letter commands use word-boundary regex so `\cdot` does not eat
    //    the first four chars of `\cdots`. Symbol commands match literally.
    const ops = <String, String>{
      // Dots first (longer → shorter).
      r'\cdots': '...',
      r'\ldots': '...',
      r'\vdots': ':',
      r'\ddots': '...',
      r'\dots': '...',
      // Comparisons (longer → shorter).
      r'\leq': '<=',
      r'\geq': '>=',
      r'\neq': '!=',
      r'\le': '<=',
      r'\ge': '>=',
      r'\ne': '!=',
      r'\approx': '~=',
      r'\equiv': '==',
      r'\sim': '~',
      // Arrows.
      r'\Leftrightarrow': '<=>',
      r'\Rightarrow': '=>',
      r'\Leftarrow': '<=',
      r'\rightarrow': '->',
      r'\leftarrow': '<-',
      r'\to': '->',
      // Infinity before \in / \int.
      r'\infty': 'infinity',
      r'\int': 'integral',
      r'\in': ' in ',
      r'\notin': ' not in ',
      // Set ops.
      r'\subseteq': ' subset of ',
      r'\subset': ' subset of ',
      r'\cup': ' union ',
      r'\cap': ' intersect ',
      // Big operators.
      r'\sum': 'sum',
      r'\prod': 'product',
      r'\partial': 'd',
      r'\nabla': 'grad',
      // Binary ops. Use middle dot (U+00B7) for multiplication rather
      // than `*` because the markdown renderer treats `*` as italic.
      r'\cdot': '\u00B7',
      r'\times': '\u00D7',
      r'\div': '/',
      r'\pm': '+/-',
      r'\mp': '-/+',
      r'\propto': ' prop to ',
      // Quantifiers.
      r'\forall': 'for all',
      r'\exists': 'exists',
      // Spacing.
      r'\quad': '  ',
      r'\qquad': '    ',
      // Symbol (non-letter) commands — these end in punctuation so they
      // can't collide with other letter commands.
      r'\,': ' ',
      r'\;': ' ',
      r'\:': ' ',
      r'\!': '',
      r'\%': '%',
      r'\_': '_',
      r'\#': '#',
      r'\&': '&',
      r'\{': '{',
      r'\}': '}',
    };
    final letterEnd = RegExp(r'[a-zA-Z]$');
    ops.forEach((cmd, replacement) {
      if (letterEnd.hasMatch(cmd)) {
        // Word-boundary match so `\cdot` doesn't eat `\cdots`.
        text = text.replaceAll(
          RegExp('${RegExp.escape(cmd)}\\b'),
          replacement,
        );
      } else {
        text = text.replaceAll(cmd, replacement);
      }
    });

    // LaTeX line break `\\` → newline. Run AFTER the escaped-brace handling
    // so we don't accidentally collapse `\{`/`\}` pairs.
    text = text.replaceAll(r'\\', '\n');

    // 8. Superscripts and subscripts: ^{abc} → ^(abc), _{abc} → _(abc).
    text = text.replaceAllMapped(
      RegExp(r'\^\{([^{}]*)\}'),
      (m) => '^(${m.group(1)})',
    );
    text = text.replaceAllMapped(
      RegExp(r'_\{([^{}]*)\}'),
      (m) => '_(${m.group(1)})',
    );

    // 9. Fallback: any remaining \command → strip the backslash.
    //    Catches anything we didn't explicitly map.
    text = text.replaceAllMapped(
      RegExp(r'\\([a-zA-Z]+)'),
      (m) => m.group(1)!,
    );

    // 10. Markdown-conflict cleanup. The markdown renderer treats `*` as
    //     italic/bold and `_` as italic. Math-style uses of these break
    //     rendering, so we neutralise them here WITHOUT touching genuine
    //     markdown emphasis (**bold**, *italic phrase*, __underline__).
    text = _neutraliseMathPunctuation(text);

    // 11. Collapse runs of 3+ newlines down to 2 (paragraph break).
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text;
  }

  /// Converts inline math-style punctuation into markdown-safe equivalents.
  ///
  /// - `a*b` (alphanumeric-bracketed asterisk) → `a·b`
  ///   but leaves `**bold**` and standalone `*italic*` phrases alone.
  /// - `x_1` (letter followed by `_` and alphanumeric) → escaped `x\_1`
  ///   so the markdown renderer shows a literal underscore instead of
  ///   starting an italic run.
  ///
  /// Fenced code regions (``` ... ``` and inline `...`) are left untouched
  /// so snake_case identifiers and pointer syntax survive intact.
  static String _neutraliseMathPunctuation(String input) {
    final fenceRe = RegExp(r'```[\s\S]*?```|`[^`\n]*`');
    final buffer = StringBuffer();
    var lastEnd = 0;
    for (final match in fenceRe.allMatches(input)) {
      buffer.write(_rewriteMath(input.substring(lastEnd, match.start)));
      buffer.write(match.group(0)); // fenced block kept verbatim
      lastEnd = match.end;
    }
    buffer.write(_rewriteMath(input.substring(lastEnd)));
    return buffer.toString();
  }

  static String _rewriteMath(String text) {
    // Two multiplication forms to catch:
    //   (1) `a*b` — no whitespace either side.
    //   (2) `a * b` — exactly one space on each side.
    // Both have word chars (or `·` from a previous pass) touching or
    // symmetrically bracketing the `*`.
    //
    // Asymmetric cases (`*italic`, `text*`, `d *i`) are left alone — those
    // are either markdown italic delimiters or ambiguous, and converting
    // them risks eating real emphasis.
    //
    // Each pattern runs twice to handle chains like `a*b*c` / `a * b * c`.
    var out = text;
    for (var i = 0; i < 2; i++) {
      out = out.replaceAllMapped(
        RegExp('([A-Za-z0-9\\)\u00B7])\\*([A-Za-z0-9\\(])'),
        (m) => '${m.group(1)}\u00B7${m.group(2)}',
      );
    }
    for (var i = 0; i < 2; i++) {
      out = out.replaceAllMapped(
        RegExp('([A-Za-z0-9\\)\u00B7]) \\* ([A-Za-z0-9\\(])'),
        (m) => '${m.group(1)}\u00B7${m.group(2)}',
      );
    }

    // Escape subscript underscores: `x_1`, `a_ij`, `v_x` etc.
    out = out.replaceAllMapped(
      RegExp(r'([A-Za-z])_([A-Za-z0-9])'),
      (m) => '${m.group(1)}\\_${m.group(2)}',
    );

    return out;
  }

  /// Converts \begin{bmatrix}...\end{bmatrix} and friends into plain-text rows.
  static String _convertMatrices(String input) {
    final envRe = RegExp(
      r'\\begin\{(bmatrix|pmatrix|vmatrix|Vmatrix|matrix|array)\}(.*?)\\end\{\1\}',
      dotAll: true,
    );
    return input.replaceAllMapped(envRe, (m) {
      final body = m.group(2)!;
      final rows = body
          .split(r'\\')
          .map((row) => row.trim())
          .where((row) => row.isNotEmpty);
      final lines = rows.map((row) {
        final cells = row.split('&').map((c) => c.trim()).toList();
        return '| ${cells.join('  ')} |';
      }).join('\n');
      return '\n$lines\n';
    });
  }
}

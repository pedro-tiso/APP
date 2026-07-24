String normalizeNf(Object? value) {
  if (value == null) return '';
  var text = value.toString().trim().toUpperCase();
  if (text.endsWith('.0')) text = text.substring(0, text.length - 2);
  text = text.replaceAll(RegExp(r'\s+'), '');
  text = text.split('-').first;
  var digits = text.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('00')) digits = digits.substring(2);
  digits = digits.replaceFirst(RegExp(r'^0+'), '');
  return digits.isEmpty && text.contains(RegExp(r'\d')) ? '0' : digits;
}

String normalizeHeader(Object? value) {
  return _withoutAccents(value?.toString() ?? '')
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-Z0-9]'), '');
}

String normalizeStatus(Object? value) {
  return _withoutAccents(value?.toString() ?? '')
      .toUpperCase()
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _withoutAccents(String input) {
  const from = 'ÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  const to = 'AAAAAEEEEIIIIOOOOOUUUUC';
  var output = input;
  for (var index = 0; index < from.length; index++) {
    output = output.replaceAll(from[index], to[index]);
    output = output.replaceAll(from[index].toLowerCase(), to[index].toLowerCase());
  }
  return output;
}

String extractBestNf(String recognizedText, Set<String> knownNfs) {
  final source = recognizedText.toUpperCase().replaceAll('O', '0');
  final anchoredRegex = RegExp(
    r'(?:NF\s*-?E?|NFE|N[º°O])\D{0,15}([0-9O]{5,10})',
    caseSensitive: false,
  );
  final generalRegex = RegExp(r'(?<!\d)(\d{5,10})(?!\d)');

  final candidates = <String, int>{};

  void addCandidate(String raw, {required bool anchored}) {
    final nf = normalizeNf(raw);
    if (nf.length < 5 || nf.length > 8) return;
    var score = anchored ? 30 : 0;
    if (nf.length == 7) score += 20;
    if (nf.startsWith('18')) score += 8;
    if (knownNfs.contains(nf)) score += 100;
    final previous = candidates[nf];
    if (previous == null || score > previous) candidates[nf] = score;
  }

  for (final match in anchoredRegex.allMatches(source)) {
    addCandidate(match.group(1) ?? '', anchored: true);
  }
  for (final match in generalRegex.allMatches(source)) {
    addCandidate(match.group(1) ?? '', anchored: false);
  }

  if (candidates.isEmpty) return '';
  final entries = candidates.entries.toList()
    ..sort((a, b) {
      final scoreOrder = b.value.compareTo(a.value);
      if (scoreOrder != 0) return scoreOrder;
      return b.key.length.compareTo(a.key.length);
    });
  return entries.first.key;
}

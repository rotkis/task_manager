/// Utilitário para comparação semântica de versões (major.minor.patch).
///
/// Remove automaticamente o prefixo "v" (ex: "v1.2.3" → "1.2.3").
/// Retorna:
///   - `-1` se [a] < [b]
///   -  `0` se [a] == [b]
///   -  `1` se [a] > [b]
int compareVersion(String a, String b) {
  final cleanedA = a.replaceFirst(RegExp(r'^v'), '');
  final cleanedB = b.replaceFirst(RegExp(r'^v'), '');

  final partsA = cleanedA.split('.');
  final partsB = cleanedB.split('.');

  final maxLen = partsA.length > partsB.length ? partsA.length : partsB.length;

  for (int i = 0; i < maxLen; i++) {
    final numA = i < partsA.length ? int.tryParse(partsA[i]) ?? 0 : 0;
    final numB = i < partsB.length ? int.tryParse(partsB[i]) ?? 0 : 0;

    if (numA < numB) return -1;
    if (numA > numB) return 1;
  }

  return 0;
}

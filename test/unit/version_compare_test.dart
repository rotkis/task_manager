import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/core/utils/version_compare.dart';

void main() {
  group('compareVersion', () {
    // ─── Igual ───────────────────────────────────────────────────
    test('versões iguais retorna 0', () {
      expect(compareVersion('1.2.3', '1.2.3'), 0);
    });

    test('versões iguais com v prefixo retorna 0', () {
      expect(compareVersion('v1.2.3', '1.2.3'), 0);
      expect(compareVersion('1.2.3', 'v1.2.3'), 0);
      expect(compareVersion('v1.2.3', 'v1.2.3'), 0);
    });

    // ─── Maior ───────────────────────────────────────────────────
    test('remote maior que local retorna 1', () {
      expect(compareVersion('2.0.0', '1.0.0'), 1);
    });

    test('remote minor maior retorna 1', () {
      expect(compareVersion('1.3.0', '1.2.0'), 1);
    });

    test('remote patch maior retorna 1', () {
      expect(compareVersion('1.2.4', '1.2.3'), 1);
    });

    test('remote maior com v prefixo retorna 1', () {
      expect(compareVersion('v2.0.0', '1.0.0'), 1);
    });

    // ─── Menor ───────────────────────────────────────────────────
    test('remote menor que local retorna -1', () {
      expect(compareVersion('0.9.0', '1.0.0'), -1);
    });

    test('remote minor menor retorna -1', () {
      expect(compareVersion('1.1.0', '1.2.0'), -1);
    });

    test('remote patch menor retorna -1', () {
      expect(compareVersion('1.2.2', '1.2.3'), -1);
    });

    // ─── Formatos variados ───────────────────────────────────────
    test('major sozinho funciona (1 vs 2)', () {
      expect(compareVersion('1', '2'), -1);
      expect(compareVersion('2', '1'), 1);
    });

    test('comprimentos diferentes (1.0 vs 1.0.1)', () {
      expect(compareVersion('1.0', '1.0.1'), -1);
    });

    test('partes não numéricas são tratadas como 0', () {
      expect(compareVersion('1.2.x', '1.2.3'), -1);
      expect(compareVersion('1.2.3', '1.2.x'), 1);
    });
  });
}

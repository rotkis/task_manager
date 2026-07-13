import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/core/utils/recurrence_parser.dart';

void main() {
  group('RecurrenceParser', () {
    group('parseRecurrenceRule', () {
      test('null retorna none', () {
        final rule = parseRecurrenceRule(null);
        expect(rule.type, RecurrenceType.none);
      });

      test('string vazia retorna none', () {
        final rule = parseRecurrenceRule('');
        expect(rule.type, RecurrenceType.none);
      });

      test('"daily" retorna daily', () {
        final rule = parseRecurrenceRule('daily');
        expect(rule.type, RecurrenceType.daily);
        expect(rule.weekDays, isEmpty);
        expect(rule.intervalDays, 1);
      });

      test('"weekly:MO,WE,FR" retorna weekly com dias 1,3,5', () {
        final rule = parseRecurrenceRule('weekly:MO,WE,FR');
        expect(rule.type, RecurrenceType.weekly);
        expect(rule.weekDays, [1, 3, 5]); // MO=1, WE=3, FR=5
        expect(rule.intervalDays, 1);
      });

      test('"weekly:MO,TU,WE,TH,FR,SA,SU" retorna weekly com dias 1-7', () {
        final rule = parseRecurrenceRule('weekly:MO,TU,WE,TH,FR,SA,SU');
        expect(rule.type, RecurrenceType.weekly);
        expect(rule.weekDays, [1, 2, 3, 4, 5, 6, 7]);
      });

      test('"weekly:" (sem dias) retorna none', () {
        final rule = parseRecurrenceRule('weekly:');
        expect(rule.type, RecurrenceType.none);
      });

      test('"every:3" retorna everyNDays com intervalo 3', () {
        final rule = parseRecurrenceRule('every:3');
        expect(rule.type, RecurrenceType.everyNDays);
        expect(rule.intervalDays, 3);
        expect(rule.weekDays, isEmpty);
      });

      test('"every:0" retorna none (inválido)', () {
        final rule = parseRecurrenceRule('every:0');
        expect(rule.type, RecurrenceType.none);
      });

      test('"every:" (sem número) retorna none', () {
        final rule = parseRecurrenceRule('every:');
        expect(rule.type, RecurrenceType.none);
      });

      test('string inválida retorna none', () {
        final rule = parseRecurrenceRule('invalid');
        expect(rule.type, RecurrenceType.none);
      });
    });

    group('serializeRecurrenceRule', () {
      test('none → string vazia', () {
        const rule = RecurrenceRule(type: RecurrenceType.none);
        expect(serializeRecurrenceRule(rule), '');
      });

      test('daily → "daily"', () {
        const rule = RecurrenceRule(type: RecurrenceType.daily);
        expect(serializeRecurrenceRule(rule), 'daily');
      });

      test('weekly → "weekly:MO,WE,FR"', () {
        final rule = RecurrenceRule(
          type: RecurrenceType.weekly,
          weekDays: [1, 3, 5],
        );
        expect(serializeRecurrenceRule(rule), 'weekly:MO,WE,FR');
      });

      test('every:N → "every:3"', () {
        const rule = RecurrenceRule(
          type: RecurrenceType.everyNDays,
          intervalDays: 3,
        );
        expect(serializeRecurrenceRule(rule), 'every:3');
      });
    });

    group('displayName', () {
      test('none', () {
        const rule = RecurrenceRule(type: RecurrenceType.none);
        expect(rule.displayName, 'Não repete');
      });

      test('daily', () {
        const rule = RecurrenceRule(type: RecurrenceType.daily);
        expect(rule.displayName, 'Diária');
      });
    });

    group('generateDates', () {
      final ref = DateTime(2026, 7, 13); // Monday

      test('daily gera todos os dias a partir da ref', () {
        const rule = RecurrenceRule(type: RecurrenceType.daily);
        final start = DateTime(2026, 7, 13);
        final end = DateTime(2026, 7, 15);
        final dates = rule.generateDates(
          referenceDate: ref,
          start: start,
          end: end,
        );
        expect(dates.length, 3);
        expect(dates[0], DateTime(2026, 7, 13));
        expect(dates[1], DateTime(2026, 7, 14));
        expect(dates[2], DateTime(2026, 7, 15));
      });

      test('daily não gera antes da referência', () {
        const rule = RecurrenceRule(type: RecurrenceType.daily);
        final start = DateTime(2026, 7, 10);
        final end = DateTime(2026, 7, 12);
        // ref é 13/07, então a partir de 13/07 começa a gerar
        final dates = rule.generateDates(
          referenceDate: ref,
          start: start,
          end: end,
        );
        expect(dates, isEmpty);
      });

      test('weekly gera apenas dias específicos', () {
        // MON (1), WED (3), FRI (5)
        final rule = RecurrenceRule(
          type: RecurrenceType.weekly,
          weekDays: [1, 3, 5],
        );
        // 2026-07-13 = Monday, 14 = Tuesday, 15 = Wednesday
        final start = DateTime(2026, 7, 13);
        final end = DateTime(2026, 7, 19); // Sunday
        final dates = rule.generateDates(
          referenceDate: ref,
          start: start,
          end: end,
        );
        expect(dates.length, 3);
        expect(dates[0], DateTime(2026, 7, 13)); // Mon
        expect(dates[1], DateTime(2026, 7, 15)); // Wed
        expect(dates[2], DateTime(2026, 7, 17)); // Fri
      });

      test('every:3 gera a cada 3 dias', () {
        const rule = RecurrenceRule(
          type: RecurrenceType.everyNDays,
          intervalDays: 3,
        );
        final start = DateTime(2026, 7, 13);
        final end = DateTime(2026, 7, 22);
        final dates = rule.generateDates(
          referenceDate: ref,
          start: start,
          end: end,
        );
        // 13, 16, 19, 22
        expect(dates.length, 4);
        expect(dates[0], DateTime(2026, 7, 13));
        expect(dates[1], DateTime(2026, 7, 16));
        expect(dates[2], DateTime(2026, 7, 19));
        expect(dates[3], DateTime(2026, 7, 22));
      });
    });

    group('weekDay helpers', () {
      test('weekDayName retorna nomes corretos', () {
        expect(RecurrenceRule.weekDayName(1), 'Seg');
        expect(RecurrenceRule.weekDayName(7), 'Dom');
        expect(RecurrenceRule.weekDayName(0), '?');
      });

      test('weekDayAbbr retorna abreviações corretas', () {
        expect(RecurrenceRule.weekDayAbbr(1), 'MO');
        expect(RecurrenceRule.weekDayAbbr(7), 'SU');
        expect(RecurrenceRule.weekDayAbbr(0), '??');
      });

      test('parseWeekDayAbbr converte corretamente', () {
        expect(RecurrenceRule.parseWeekDayAbbr('MO'), 1);
        expect(RecurrenceRule.parseWeekDayAbbr('SU'), 7);
        expect(RecurrenceRule.parseWeekDayAbbr('XX'), isNull);
        expect(RecurrenceRule.parseWeekDayAbbr('mo'), 1); // case insensitive
      });

      test('round-trip parseWeekDayAbbr / weekDayAbbr', () {
        for (int i = 1; i <= 7; i++) {
          final abbr = RecurrenceRule.weekDayAbbr(i);
          expect(RecurrenceRule.parseWeekDayAbbr(abbr), i);
        }
      });
    });
  });
}

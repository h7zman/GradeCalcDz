import 'package:flutter_test/flutter_test.dart';

import 'package:gradecalcprodz/models/grade_models.dart';

Module _module({
  String td = '',
  String tp = '',
  String exam = '',
  String coeff = '1',
  int examPercentage = 60,
  int ccPercentage = 40,
}) {
  return Module(
    id: 'm1',
    name: 'M1',
    coeff: coeff,
    td: td,
    tp: tp,
    exam: exam,
    examPercentage: examPercentage,
    ccPercentage: ccPercentage,
    splitMode: 'custom',
  );
}

void main() {
  test('CC computation: TD + TP', () {
    final calc = ModuleCalc.fromModule(_module(td: '12', tp: '16'));
    expect(calc.cc, 14);
  });

  test('CC computation: only TD', () {
    final calc = ModuleCalc.fromModule(_module(td: '10'));
    expect(calc.cc, 10);
  });

  test('CC computation: only TP', () {
    final calc = ModuleCalc.fromModule(_module(tp: '8'));
    expect(calc.cc, 8);
  });

  test('CC computation: none', () {
    final calc = ModuleCalc.fromModule(_module());
    expect(calc.cc, isNull);
  });

  test('Final grade uses percentages', () {
    final calc = ModuleCalc.fromModule(
      _module(td: '12', exam: '10', examPercentage: 60, ccPercentage: 40),
    );
    expect(calc.finalGrade, closeTo(10.8, 0.0001));
  });

  test('Missing CC error when exam exists', () {
    final calc = ModuleCalc.fromModule(_module(exam: '14'));
    expect(calc.errors, contains('Missing CC (no TD/TP)'));
  });

  test('No CC required when split is 100/0', () {
    final calc = ModuleCalc.fromModule(
      _module(exam: '14', examPercentage: 100, ccPercentage: 0),
    );
    expect(calc.errors, isNot(contains('Missing CC (no TD/TP)')));
    expect(calc.finalGrade, closeTo(14, 0.0001));
  });

  test('Split must equal 100', () {
    final calc = ModuleCalc.fromModule(
      _module(td: '10', exam: '10', examPercentage: 70, ccPercentage: 20),
    );
    expect(calc.errors, contains('Split must equal 100'));
  });

  test('Grade validation', () {
    final calc = ModuleCalc.fromModule(_module(td: '30'));
    expect(calc.errors, contains('TD must be 0..20'));
  });

  test('Semester average weighted by coefficient', () {
    final s = Semester(
      id: 's1',
      name: 'S1',
      modules: [
        _module(td: '10', exam: '10', coeff: '2'),
        _module(td: '14', exam: '10', coeff: '1'),
      ],
    );
    final calc = SemesterCalc.fromSemester(s);
    expect(calc.average, closeTo(10.5333, 0.0001));
    expect(calc.gradedModules, 2);
  });
}

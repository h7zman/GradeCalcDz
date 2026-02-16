import 'dart:math';

class Module {
  Module({
    required this.id,
    required this.name,
    required this.coeff,
    required this.td,
    required this.tp,
    required this.exam,
    required this.examPercentage,
    required this.ccPercentage,
    required this.splitMode,
    this.isLocked = false,
    this.isCollapsed = false,
  });

  String id;
  String name;
  String coeff;
  String td;
  String tp;
  String exam;
  int examPercentage;
  int ccPercentage;
  String splitMode;
  bool isLocked;
  bool isCollapsed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'coeff': coeff,
    'td': td,
    'tp': tp,
    'exam': exam,
    'examPercentage': examPercentage,
    'ccPercentage': ccPercentage,
    'splitMode': splitMode,
    'isLocked': isLocked,
    'isCollapsed': isCollapsed,
  };

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'Module',
      coeff: (json['coeff'] as String?) ?? '',
      td: (json['td'] as String?) ?? '',
      tp: (json['tp'] as String?) ?? '',
      exam: (json['exam'] as String?) ?? '',
      examPercentage: (json['examPercentage'] as int?) ?? 60,
      ccPercentage: (json['ccPercentage'] as int?) ?? 40,
      splitMode: (json['splitMode'] as String?) ?? '60_40',
      isLocked: (json['isLocked'] as bool?) ?? false,
      isCollapsed: (json['isCollapsed'] as bool?) ?? false,
    );
  }
}

class Semester {
  Semester({required this.id, required this.name, required this.modules});

  String id;
  String name;
  List<Module> modules;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'modules': modules.map((m) => m.toJson()).toList(),
  };

  factory Semester.fromJson(Map<String, dynamic> json) {
    final modules = (json['modules'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Module.fromJson)
        .toList();
    return Semester(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? 'S1',
      modules: modules,
    );
  }
}

class ModuleCalc {
  const ModuleCalc({
    required this.coefficient,
    required this.td,
    required this.tp,
    required this.exam,
    required this.cc,
    required this.finalGrade,
    required this.errors,
    required this.percentagesValid,
  });

  final double? coefficient;
  final double? td;
  final double? tp;
  final double? exam;
  final double? cc;
  final double? finalGrade;
  final List<String> errors;
  final bool percentagesValid;

  bool get hasValidFinal => finalGrade != null;

  static ModuleCalc fromModule(Module module) {
    final errors = <String>[];
    final coefficient = _parseCoefficient(module.coeff, errors);
    final td = _parseGrade(module.td, errors, 'TD');
    final tp = _parseGrade(module.tp, errors, 'TP');
    final exam = _parseGrade(module.exam, errors, 'Exam');

    final percentagesValid =
        (module.examPercentage + module.ccPercentage) == 100;
    if (!percentagesValid) {
      errors.add('Split must equal 100');
    }

    double? cc;
    if (td != null && tp != null) {
      cc = (td + tp) / 2;
    } else if (td != null) {
      cc = td;
    } else if (tp != null) {
      cc = tp;
    }

    final requiresExam = module.examPercentage > 0;
    final requiresCc = module.ccPercentage > 0;

    if (exam != null && cc == null && requiresCc) {
      errors.add('Missing CC (no TD/TP)');
    }

    double? finalGrade;
    final hasExamForFinal = !requiresExam || exam != null;
    final hasCcForFinal = !requiresCc || cc != null;
    if (hasExamForFinal && hasCcForFinal && percentagesValid) {
      finalGrade =
          ((exam ?? 0) * module.examPercentage / 100) +
          ((cc ?? 0) * module.ccPercentage / 100);
    }

    return ModuleCalc(
      coefficient: coefficient,
      td: td,
      tp: tp,
      exam: exam,
      cc: cc,
      finalGrade: finalGrade,
      errors: errors,
      percentagesValid: percentagesValid,
    );
  }
}

class SemesterCalc {
  const SemesterCalc({
    required this.average,
    required this.totalModules,
    required this.gradedModules,
    required this.passedModules,
    required this.totalCoefficients,
    required this.gradedCoefficients,
  });

  final double? average;
  final int totalModules;
  final int gradedModules;
  final int passedModules;
  final double totalCoefficients;
  final double gradedCoefficients;

  static SemesterCalc fromSemester(Semester semester) {
    var totalModules = semester.modules.length;
    var gradedModules = 0;
    var passedModules = 0;
    var totalCoefficients = 0.0;
    var gradedCoefficients = 0.0;
    var weightedSum = 0.0;

    for (final module in semester.modules) {
      final calc = ModuleCalc.fromModule(module);
      if (calc.coefficient != null) {
        totalCoefficients += max(0.0, calc.coefficient!);
      }
      if (calc.finalGrade != null &&
          calc.coefficient != null &&
          calc.coefficient! > 0) {
        gradedModules += 1;
        gradedCoefficients += calc.coefficient!;
        weightedSum += calc.finalGrade! * calc.coefficient!;
        if (calc.finalGrade! >= 10) {
          passedModules += 1;
        }
      }
    }

    final average = gradedCoefficients > 0
        ? weightedSum / gradedCoefficients
        : null;

    return SemesterCalc(
      average: average,
      totalModules: totalModules,
      gradedModules: gradedModules,
      passedModules: passedModules,
      totalCoefficients: totalCoefficients,
      gradedCoefficients: gradedCoefficients,
    );
  }
}

class OverallCalc {
  const OverallCalc({
    required this.average,
    required this.totalModules,
    required this.gradedModules,
    required this.passedModules,
    required this.totalCoefficients,
    required this.gradedCoefficients,
  });

  final double? average;
  final int totalModules;
  final int gradedModules;
  final int passedModules;
  final double totalCoefficients;
  final double gradedCoefficients;

  static OverallCalc fromSemesters(List<Semester> semesters) {
    var totalModules = 0;
    var gradedModules = 0;
    var passedModules = 0;
    var totalCoefficients = 0.0;
    var gradedCoefficients = 0.0;
    var weightedSum = 0.0;

    for (final semester in semesters) {
      for (final module in semester.modules) {
        final calc = ModuleCalc.fromModule(module);
        totalModules += 1;

        if (calc.coefficient != null) {
          totalCoefficients += max(0.0, calc.coefficient!);
        }

        if (calc.finalGrade != null &&
            calc.coefficient != null &&
            calc.coefficient! > 0) {
          gradedModules += 1;
          gradedCoefficients += calc.coefficient!;
          weightedSum += calc.finalGrade! * calc.coefficient!;
          if (calc.finalGrade! >= 10) {
            passedModules += 1;
          }
        }
      }
    }

    final average = gradedCoefficients > 0
        ? weightedSum / gradedCoefficients
        : null;

    return OverallCalc(
      average: average,
      totalModules: totalModules,
      gradedModules: gradedModules,
      passedModules: passedModules,
      totalCoefficients: totalCoefficients,
      gradedCoefficients: gradedCoefficients,
    );
  }
}

double? _parseOptionalNumber(String raw, List<String> errors, String label) {
  final cleaned = raw.trim();
  if (cleaned.isEmpty) {
    return null;
  }
  final value = double.tryParse(cleaned.replaceAll(',', '.'));
  if (value == null) {
    errors.add('$label is invalid');
    return null;
  }
  return value;
}

double? _parseGrade(String raw, List<String> errors, String label) {
  final value = _parseOptionalNumber(raw, errors, label);
  if (value == null) {
    return null;
  }
  if (value < 0 || value > 20) {
    errors.add('$label must be 0..20');
    return null;
  }
  return value;
}

double? _parseCoefficient(String raw, List<String> errors) {
  final cleaned = raw.trim();
  if (cleaned.isEmpty) {
    errors.add('Coeff required');
    return null;
  }
  final value = _parseOptionalNumber(raw, errors, 'Coeff');
  if (value == null) {
    return null;
  }
  if (value < 1) {
    errors.add('Coeff must be >= 1');
    return null;
  }
  return value;
}

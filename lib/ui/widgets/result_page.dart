import 'package:flutter/material.dart';
import 'package:gradecalcprodz/models/grade_models.dart';
import 'package:gradecalcprodz/theme/app_theme.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.semesters});

  final List<Semester> semesters;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);

    final overall = OverallCalc.fromSemesters(widget.semesters);
    final overallAvg = overall.average ?? 0.0;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Overall: ${overallAvg.toStringAsFixed(2)}/20',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: overallAvg >= 10
                  ? tokens.success.withValues(alpha: 0.1)
                  : tokens.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              overallAvg >= 10 ? 'Admitted' : 'Not Admitted',
              style: theme.textTheme.labelLarge?.copyWith(
                color: overallAvg >= 10 ? tokens.success : tokens.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Semester Breakdown
        Text(
          'Semester Breakdown',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.semesters.map((s) {
          final calc = SemesterCalc.fromSemester(s);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tokens.fieldBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${s.modules.length} Modules',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
                Text(
                  calc.average != null
                      ? calc.average!.toStringAsFixed(2)
                      : '--',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: calc.average != null && calc.average! >= 10
                        ? tokens.success
                        : tokens.danger,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

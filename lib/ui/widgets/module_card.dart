import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/grade_models.dart';
import '../../theme/app_theme.dart';

typedef ModuleUpdater =
    void Function({
      String? name,
      String? coeff,
      String? td,
      String? tp,
      String? exam,
      int? examPercentage,
      int? ccPercentage,
      String? splitMode,
      bool? isLocked,
      bool? isCollapsed,
    });

class ModuleCard extends StatefulWidget {
  const ModuleCard({
    super.key,
    required this.module,
    required this.calc,
    required this.onUpdate,
    required this.onDelete,
  });

  final Module module;
  final ModuleCalc calc;
  final ModuleUpdater onUpdate;
  final VoidCallback onDelete;

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _coeffController;
  late final TextEditingController _tdController;
  late final TextEditingController _tpController;
  late final TextEditingController _examController;
  late final TextEditingController _examPercentController;
  late final TextEditingController _ccPercentController;
  bool _hasEdits = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.module.name);
    _coeffController = TextEditingController(text: widget.module.coeff);
    _tdController = TextEditingController(text: widget.module.td);
    _tpController = TextEditingController(text: widget.module.tp);
    _examController = TextEditingController(text: widget.module.exam);
    _examPercentController = TextEditingController(
      text: widget.module.examPercentage.toString(),
    );
    _ccPercentController = TextEditingController(
      text: widget.module.ccPercentage.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant ModuleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(_nameController, widget.module.name);
    _syncController(_coeffController, widget.module.coeff);
    _syncController(_tdController, widget.module.td);
    _syncController(_tpController, widget.module.tp);
    _syncController(_examController, widget.module.exam);
    _syncController(
      _examPercentController,
      widget.module.examPercentage.toString(),
    );
    _syncController(
      _ccPercentController,
      widget.module.ccPercentage.toString(),
    );
    if (widget.module.isCollapsed || widget.module.isLocked) {
      _hasEdits = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _coeffController.dispose();
    _tdController.dispose();
    _tpController.dispose();
    _examController.dispose();
    _examPercentController.dispose();
    _ccPercentController.dispose();
    super.dispose();
  }

  void _syncController(TextEditingController controller, String text) {
    if (controller.text == text) return;
    controller.value = controller.value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange.empty,
    );
  }

  void _markEdited() {
    if (_hasEdits || widget.module.isLocked) {
      return;
    }
    setState(() => _hasEdits = true);
  }

  void _saveAndCollapse({bool lock = false}) {
    widget.onUpdate(
      isCollapsed: true,
      isLocked: lock ? true : widget.module.isLocked,
    );
    if (_hasEdits) {
      setState(() => _hasEdits = false);
    }
  }

  String _displayOrDash(String raw) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? '--' : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);
    final avg = widget.calc.finalGrade;
    final avgText = avg == null ? '--' : avg.toStringAsFixed(2);
    final avgColor = avg == null
        ? tokens.textMuted
        : avg >= 10
        ? tokens.success
        : tokens.danger;
    final isLocked = widget.module.isLocked;
    final isCollapsed = widget.module.isCollapsed;

    if (isCollapsed) {
      return _buildCollapsedCard(
        context,
        tokens,
        theme,
        avgText,
        avgColor,
        isLocked,
      );
    }
    return _buildExpandedCard(
      context,
      tokens,
      theme,
      avgText,
      avgColor,
      isLocked,
    );
  }

  Widget _buildCollapsedCard(
    BuildContext context,
    AppThemeTokens tokens,
    ThemeData theme,
    String avgText,
    Color avgColor,
    bool isLocked,
  ) {
    final moduleName = _displayOrDash(widget.module.name);
    final coeffText = _displayOrDash(widget.module.coeff);
    final tdText = _displayOrDash(widget.module.td);
    final tpText = _displayOrDash(widget.module.tp);
    final examText = _displayOrDash(widget.module.exam);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: tokens.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  moduleName == '--' ? 'Module' : moduleName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ModuleStateChip(
                label: isLocked ? 'Locked' : 'Saved',
                color: isLocked ? tokens.danger : tokens.success,
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final metricWidth = (constraints.maxWidth - 16) / 3;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: metricWidth,
                    child: _CollapsedMetric(
                      label: 'Coeff',
                      value: coeffText,
                      valueColor: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(
                    width: metricWidth,
                    child: _CollapsedMetric(
                      label: 'Avg',
                      value: avgText,
                      valueColor: avgColor,
                    ),
                  ),
                  SizedBox(
                    width: metricWidth,
                    child: _CollapsedMetric(
                      label: 'Exam',
                      value: examText,
                      valueColor: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(
                    width: metricWidth,
                    child: _CollapsedMetric(
                      label: 'TD',
                      value: tdText,
                      valueColor: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(
                    width: metricWidth,
                    child: _CollapsedMetric(
                      label: 'TP',
                      value: tpText,
                      valueColor: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (isLocked)
                OutlinedButton.icon(
                  onPressed: () =>
                      widget.onUpdate(isLocked: false, isCollapsed: false),
                  icon: const Icon(Icons.lock_open_rounded, size: 18),
                  label: const Text('Unlock'),
                )
              else
                FilledButton.tonalIcon(
                  onPressed: () => widget.onUpdate(isCollapsed: false),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              if (!isLocked)
                OutlinedButton.icon(
                  onPressed: () =>
                      widget.onUpdate(isLocked: true, isCollapsed: true),
                  icon: const Icon(Icons.lock_outline_rounded, size: 18),
                  label: const Text('Lock'),
                ),
              TextButton.icon(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: tokens.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedCard(
    BuildContext context,
    AppThemeTokens tokens,
    ThemeData theme,
    String avgText,
    Color avgColor,
    bool isLocked,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.cardRadius),
        border: Border.all(color: tokens.fieldBorder),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  enabled: !isLocked,
                  onChanged: (value) {
                    _markEdited();
                    widget.onUpdate(name: value);
                  },
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Module name',
                    hintStyle: theme.textTheme.titleMedium?.copyWith(
                      color: tokens.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: tokens.danger,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!isLocked)
                FilledButton.tonalIcon(
                  onPressed: () => _saveAndCollapse(lock: false),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text(_hasEdits ? 'Save & shrink' : 'Shrink'),
                ),
              if (!isLocked)
                OutlinedButton.icon(
                  onPressed: () => _saveAndCollapse(lock: true),
                  icon: const Icon(Icons.lock_outline_rounded, size: 18),
                  label: const Text('Lock'),
                ),
              if (isLocked)
                OutlinedButton.icon(
                  onPressed: () =>
                      widget.onUpdate(isLocked: false, isCollapsed: false),
                  icon: const Icon(Icons.lock_open_rounded, size: 18),
                  label: const Text('Unlock to edit'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _FieldLabel(label: 'COEFF', color: tokens.textMuted),
              _FieldLabel(
                label: 'TD (${widget.module.ccPercentage}%)',
                color: tokens.textMuted,
              ),
              _FieldLabel(
                label: 'TP (${widget.module.ccPercentage}%)',
                color: tokens.textMuted,
              ),
              _FieldLabel(
                label: 'EXAM (${widget.module.examPercentage}%)',
                color: tokens.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _SmallField(
                controller: _coeffController,
                hint: '1',
                enabled: !isLocked,
                onChanged: (value) {
                  _markEdited();
                  widget.onUpdate(coeff: value);
                },
              ),
              _SmallField(
                controller: _tdController,
                hint: '--',
                enabled: !isLocked,
                onChanged: (value) {
                  _markEdited();
                  widget.onUpdate(td: value);
                },
              ),
              _SmallField(
                controller: _tpController,
                hint: '--',
                enabled: !isLocked,
                onChanged: (value) {
                  _markEdited();
                  widget.onUpdate(tp: value);
                },
              ),
              _SmallField(
                controller: _examController,
                hint: '--',
                enabled: !isLocked,
                onChanged: (value) {
                  _markEdited();
                  widget.onUpdate(exam: value);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Split (Exam/CC)',
            style: theme.textTheme.labelSmall?.copyWith(
              color: tokens.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SplitChip(
                label: '60/40 Exam/CC',
                selected: widget.module.splitMode == '60_40',
                enabled: !isLocked,
                onTap: () {
                  _markEdited();
                  widget.onUpdate(
                    splitMode: '60_40',
                    examPercentage: 60,
                    ccPercentage: 40,
                  );
                },
              ),
              _SplitChip(
                label: '50/50 Exam/CC',
                selected: widget.module.splitMode == '50_50',
                enabled: !isLocked,
                onTap: () {
                  _markEdited();
                  widget.onUpdate(
                    splitMode: '50_50',
                    examPercentage: 50,
                    ccPercentage: 50,
                  );
                },
              ),
              _SplitChip(
                label: '40/60 Exam/CC',
                selected: widget.module.splitMode == '40_60',
                enabled: !isLocked,
                onTap: () {
                  _markEdited();
                  widget.onUpdate(
                    splitMode: '40_60',
                    examPercentage: 40,
                    ccPercentage: 60,
                  );
                },
              ),
              _SplitChip(
                label: 'Custom',
                selected: widget.module.splitMode == 'custom',
                enabled: !isLocked,
                onTap: () {
                  _markEdited();
                  widget.onUpdate(splitMode: 'custom');
                },
              ),
            ],
          ),
          if (widget.module.splitMode == 'custom') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _FieldLabel(label: 'EXAM %', color: tokens.textMuted),
                _FieldLabel(label: 'CC %', color: tokens.textMuted),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _SmallField(
                  controller: _examPercentController,
                  hint: '60',
                  enabled: !isLocked,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      _markEdited();
                      widget.onUpdate(examPercentage: parsed);
                    }
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                _SmallField(
                  controller: _ccPercentController,
                  hint: '40',
                  enabled: !isLocked,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      _markEdited();
                      widget.onUpdate(ccPercentage: parsed);
                    }
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const Spacer(),
              ],
            ),
          ],
          if (widget.calc.errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final error in widget.calc.errors)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  error,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Average: $avgText',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: avgColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _SmallField extends StatelessWidget {
  const _SmallField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.enabled = true,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: tokens.field,
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          border: Border.all(color: tokens.fieldBorder),
        ),
        child: TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: inputFormatters,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: tokens.textMuted,
              fontWeight: FontWeight.w600,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

class _SplitChip extends StatelessWidget {
  const _SplitChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: enabled ? (_) => onTap() : null,
    );
  }
}

class _ModuleStateChip extends StatelessWidget {
  const _ModuleStateChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tokens.fieldBorder),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CollapsedMetric extends StatelessWidget {
  const _CollapsedMetric({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.field,
        borderRadius: BorderRadius.circular(tokens.fieldRadius),
        border: Border.all(color: tokens.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: tokens.textMuted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

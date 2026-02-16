import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/grade_models.dart';
import '../../theme/app_theme.dart';

class ModernModuleCard extends StatelessWidget {
  const ModernModuleCard({
    super.key,
    required this.module,
    required this.moduleIndex,
    this.isHeld = false,
    this.onEdit,
    required this.onDelete,
    required this.onToggleLock,
  });

  final Module module;
  final int moduleIndex;
  final bool isHeld;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleLock;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);
    final calc = ModuleCalc.fromModule(module);
    final avg = calc.finalGrade;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      transform: isHeld
          ? Matrix4.translationValues(0, -6, 0)
          : Matrix4.identity(),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: isHeld
            ? Color.alphaBlend(
                tokens.accent.withValues(alpha: 0.1),
                tokens.card,
              )
            : tokens.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHeld
              ? tokens.accent.withValues(alpha: 0.58)
              : Colors.transparent,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.shadow.withValues(alpha: isHeld ? 0.62 : 0.45),
            blurRadius: isHeld ? 30 : 24,
            offset: Offset(0, isHeld ? 14 : 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Module $moduleIndex: ',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      TextSpan(
                        text: module.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Coeff: ${module.coeff.trim().isEmpty ? '--' : module.coeff}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: 'Avg: ',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: avg == null ? '--' : _formatNumber(avg),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: avg == null
                              ? theme.colorScheme.onSurface
                              : (avg >= 10 ? tokens.success : tokens.danger),
                        ),
                      ),
                      TextSpan(
                        text: '/20',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null) ...[
                _ActionButton(
                  icon: FontAwesomeIcons.penToSquare,
                  label: 'Edit',
                  onTap: onEdit!,
                  color: tokens.accent,
                ),
                const SizedBox(width: 10),
              ],
              _ActionButton(
                icon: module.isLocked
                    ? FontAwesomeIcons.lockOpen
                    : FontAwesomeIcons.lock,
                label: module.isLocked ? 'Unlock' : 'Lock',
                onTap: onToggleLock,
                color: tokens.accent,
              ),
              const SizedBox(width: 10),
              _ActionButton(
                icon: FontAwesomeIcons.trashCan,
                label: 'Delete',
                onTap: onDelete,
                color: tokens.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    final one = value.toStringAsFixed(1);
    return one.endsWith('.0') ? one.substring(0, one.length - 2) : one;
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
